(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload '(:with-user-abort) :silent t)
  (ql:quickload '(:adopt) :silent t)
  (ql:quickload '(:log4cl) :silent t)
  (asdf:load-system :uiop))

(defpackage :eli
  (:use :cl)
  (:export :toplevel *ui*))

(in-package :eli)

(define-condition user-error (error)
  ((message :initarg :message
            :accessor user-error-message
            :initform nil
            :documentation "Text message indicating why user inputs is invalid.")
   (error-code :initarg :error-code
               :accessor user-error-code
               :initform 1
               :documentation "Code representing the error type, it is also used as exit code.")))

(defun is-installed (cmd)
  "Returns true if CMD is installed"
  (handler-case
      ;; POSIX way to check if cmd exists
    (uiop:run-program (list "sh" "-c" (concatenate 'string "command -v " cmd)))
    (uiop:subprocess-error (e)
                           (declare (ignore e))
                           nil)
    (:no-error (&rest _)
               (declare (ignore _))
               t)))

(defconstant +required-cmds+ (list "buildah" "mount" "umount" "chroot" "mktemp" "mkdir" "cp")
  "List of required commands.")

(defun required-cmds-are-installed ()
  "Signal a user-error with error code 99 if one of +REQUIRED-CMDS+ is not installed."
  (dolist (cmd +required-cmds+)
          (if (not (is-installed cmd))
              (error 'user-error
                     :error-code 99
                     :message (format nil "missing required command: ~a" cmd)))))

(defun join-pathstring (&rest pathstrings)
  "Joins all the PATHSTRINGS with a /."
  (let ((result "")
        (sep (string (uiop:directory-separator-for-host))))
    (dolist (path pathstrings)
            (setf result
                  (concatenate 'string
                               (string-right-trim sep result)
                               sep
                               (string-trim sep path))))
    result))
;(format nil 
; (concatenate 'string "~{~A~^" (string (uiop:directory-separator-for-host)) "~}") pathstrings)

(defun run-program (cmd &rest rp-args)
  "Log CMD at the debug level and execute it."
  (log:debug "executing: \"~{~a~^ ~}\"" cmd)
  (apply #'uiop:run-program cmd rp-args))

(defun buildah (args &key (output *standard-output*) (error-output *error-output*))
  "Execute buildah command with the given ARGS."
  (let ((cmd (push "buildah" args)))
    (run-program cmd :output output :error-output error-output)))

(defun buildah-run (ctr args &rest rp-args)
  "Execute ARGS command in buildah CTR."
  (let ((cmd (push ctr args)))
    (apply #'buildah (push "run" cmd) rp-args)))

(defun new-tmp-dir ()
  "Create a temporary directory and a function to delete it."
  (let* ((tmp-dir (run-program (list "mktemp" "-d") :output '(:string :stripped t)))
         (rm-tmp (lambda () (run-program (list "rm" "-rf" tmp-dir)))))
    (values tmp-dir rm-tmp)))

(defun mount-squashfs (ctr src dst)
  "Mount SRC at the given DST path."
  (run-program (list "mount" "-t" "squashfs" "-o" "ro,loop" src dst)))

(defun kernel-version ()
  "Returns a string containing linux kernel version numbers."
  (uiop:run-program (list "uname" "-r") :output '(:string :stripped t)))

(defun kernel-installed (version)
  "Check that kernel VERSION is installed."
  ;; TODO
  t)

(defconstant +kver+ (kernel-version)
  "Active linux kernel version.")

(defun create-container (image-name)
  "Create a container based on IMAGE-NAME and returns its name."
  (log:info "creating container using \"~a\" image." image-name)
  (let ((ctr (buildah (list "from" image-name) :output '(:string :stripped t))))
    (log:info "container \"~a\" created." ctr)
    ctr))

(defun remove-container (ctr)
  (log:info "removing container \"~a\"..." ctr)
  (buildah (list "rm" ctr))
  (log:info "container \"~a\" removed." ctr))

(defun setup-container (image-name)
  "Create and setup container based on IMAGE-NAME. Returns the name of container and its mountpoint."
  ;; Create the container
  (let* ((ctr (create-container image-name))
         (ctr-rootfs)
         (clean (lambda () (destroy-container ctr ctr-rootfs))))
    (handler-case
        (progn
         ;; Create /boot in CTR
         (buildah-run ctr (list "mkdir" "-p" "/boot"))

         ;; Mount it on host
         (log:info "mounting container ~a on host..." ctr)
         (setf ctr-rootfs (buildah (list "mount" ctr) :output '(:string :stripped t)))
         (log:info "container \"~a\" mounted at \"~a\"." ctr ctr-rootfs)

         ;; Bind mount /proc /dev /sys directories in CTR-ROOTFS
         (dolist (dir (list "proc" "dev"))
                 (let ((host-dir (join-pathstring "" dir))
                       (ctr-dir (join-pathstring ctr-rootfs dir)))
                   (log:info "binding mount \"~a\" in \"~a\"..." host-dir ctr ctr-dir)
                   (run-program (list "mkdir" "-p" ctr-dir))
                   (run-program (list "mount" "--bind" host-dir ctr-dir))
                   (log:info "\"~a\" mounted in \"~a\"." host-dir ctr ctr-dir))))

      (error (e)
             (log:error "~a" e)
             (funcall clean)
             (error 'error e)))
    (values ctr ctr-rootfs)))

(defun destroy-container (ctr ctr-rootfs)
  "Remove in a clean way CTR setted up by SETUP-CONTAINER."
  (if (not ctr-rootfs)
      (dolist (dir (list "proc" "dev"))
              (let ((ctr-dir (join-pathstring ctr-rootfs dir)))
                (log:info "unmounting \"/~a\" from \"~a\"..." dir ctr)
                (run-program (list "umount" "-l" ctr-dir))
                (log:info "\"/~a\" unmounted from \"~a\"." dir ctr))))
  (remove-container ctr))

(defun generate-squashfs (ctr kver)
  "Generate a squashfs file in CTR."
  (let ((dst (format nil "/boot/rootfs-~a.sqsh" kver)))
    (log:info "generating squashfs at \"~a\"..." dst)
    (buildah-run ctr (list "mksquashfs" "/" dst "-noappend" "-reproducible" "-e" "dev" "proc" "sys" "run" "boot"))
    (log:info "squashfs generated.")
    dst))

(defun generate-initramfs (ctr squashfs kver)
  "Generate an initramfs in CTR at DST."
  (let* ((dst (format nil "/boot/initramfs-~a.img" kver))
         (cmd (format nil "SQUASHFS_IMG=\"~a\" INITRAMFS_DEST=\"~a\" KERNEL_VERSION=\"~a\" /eli/mkinitramfs"
                      squashfs dst kver))
         (modules-volume (format nil "/lib/modules/~a:/lib/modules/~a:ro" kver kver)))

    (log:info "generating initramfs at \"~a\"..." dst)
    (buildah (list "run" "--volume" modules-volume ctr "/bin/sh" "-c" cmd))
    (log:info "initramfs generated.")
    dst))

; (defun generate-grub-config (ctr install-dir kver)
;   (let ((dst (format nil "~a/grub/grub-~a.cfg" install-dir kver)))
;     (log:info "generating grub config at \"~a\"..." dst)

;     ;; Mounting container
;     (log:info "mounting \"~a\" on host..." ctr)
;     (let* ((ctr-fs (buildah (list "mount" ctr) :output '(:string :stripped t)))
;            (ctr-squashfs (format nil "~a/~a" ctr-fs squashfs))
;            (tmpdir)
;            (tmpdir-lower)
;            (tmpdir-upper)
;            (tmpdir-work)
;            (tmpdir-merged))
;       (log:info "\"~a\" mounted at \"~a\"." ctr ctr-fs)

;       (handler-case
;           (progn
;            (setf tmpdir (run-program (list "mktemp" "-d") :output '(:string :stripped t))
;                  tmpdir-lower (format nil "~a/lower" tmpdir)
;                  tmpdir-upper (format nil "~a/upper" tmpdir)
;                  tmpdir-work (format nil "~a/work" tmpdir)
;                  tmpdir-merged (format nil "~a/merged" tmpdir))

;            ;; Mounting tmpfs overlay
;            (log:info "mounting tmpfs at \"~a\"..." tmpdir)
;            (run-program (list "mount" "-t" "tmpfs" "none" tmpdir))
;            (log:info "tmpfs mounted at \"~a\"." tmpdir)

;            ;; Creating sub directories
;            (run-program (list "mkdir" "-p" tmpdir-lower tmpdir-upper tmpdir-work tmpdir-merged))

;            ;; Mounting generated squashfs
;            (log:info "mounting squashfs at \"~a\"..." tmpdir-lower)
;            (run-program (list "mount" ctr-squashfs tmpdir-lower "-t" "squashfs" "-o" "loop"))
;            (log:info "squashfs mounted at \"~a\"." tmpdir-lower)

;            ;; Mounting unionfs
;            (log:info "mounting tmpfs as overlay at \"~a\"..." tmpdir-merged)
;            (run-program (list "mount" "-t" "overlay"
;                               "-o" (format nil "lowerdir=~a,upperdir=~a,workdir=~a" tmpdir-lower tmpdir-upper tmpdir-work)
;                               "overlay" tmpdir-merged))
;            (log:info "tmpfs mounted as overlay at \"~a\"." tmpdir-merged)

;            ;; Mounting /proc in the overlay
;            ;; /proc is required as it contains the mtab file
;            (let ((tmpdir-proc (format nil "~a/proc" tmpdir-merged)))
;              (log:info "mounting /proc at \"~a\"..." tmpdir-proc)
;              (run-program (list "mkdir" "-p" tmpdir-proc))
;              (run-program (list "mount" "--bind" "/proc" tmpdir-proc))
;              (log:info "/proc mounted at \"~a\"" tmpdir-proc)

;              ;; Generating grub config from within the squashfs
;              (log:info "chrooting into \"~a\" and generating grub config..." tmpdir-merged)
;              (run-program (list "chroot" tmpdir-merged "grub-mkconfig"))
;              (log:info "grub config generated.")))

;         (error (e)
;                (log:error "~a" e)
;                (run-program (list "umount" "-Rl" tmpdir))
;                (run-program (list "rm" "-rf" tmpdir))
;                (error 'error e))

;         (:no-error (&rest returns)
;                    (run-program (list "umount" "-Rl" tmpdir))
;                    (run-program (list "rm" "-rf" tmpdir))
;                    returns)))))

(defun linux-install (image-name install-dir kver)
  (multiple-value-bind (ctr ctr-rootfs) (setup-container image-name)
    (log:info "creating install directory \"~a\"..." install-dir)
    (run-program (list "sh" "-c"
                       (concatenate 'string "test -d " install-dir " ||  mkdir -p " install-dir)))
    (log:info "install directory \"~a\" created." install-dir)

    (let ((clean (lambda ()
                   (if (not (gethash 'no-clean *options*))
                       (destroy-container ctr ctr-rootfs)))))
      (handler-case
          (let* ((install-dir (join-pathstring install-dir image-name))
                 (ctr-boot (join-pathstring ctr-rootfs "/boot"))
                 (squashfs (generate-squashfs ctr kver))
                 (initramfs (generate-initramfs ctr squashfs kver)))
            (log:info "copying initramfs in \"~a\"..." install-dir)
            (run-program (list "cp" "-r" ctr-boot install-dir))
            (log:info "initramfs copied in \"~a\"." install-dir)
            ; (grub-config (generate-grub-config ctr kver))

            ; Grub.d file that generate entry for eli installs.
          )

        (error (e)
               (log:error "~a" e)
               (funcall clean)
               (error 'error e))

        (:no-error (&rest returns)
                   (funcall clean)
                   returns)))))

(defun eli (images)
  (let ((install-dir (gethash 'install-dir *options*))
        (kver (gethash 'kernel-version *options*)))
    (handler-case
        (dolist (image-name images)
                (linux-install image-name install-dir kver))
      (uiop:subprocess-error (e) e))))

(defconstant +option-help+
  (adopt:make-option 'help
                     :help "Display help and exit."
                     :long "help"
                     :short #\h
                     :reduce (constantly t)))

(defconstant +option-install-dir+
  (adopt:make-option 'install-dir
                     :help "Installation destination directory."
                     :initial-value "/boot/eli/"
                     :long "install-dir"
                     :short #\i
                     :parameter "/boot/eli/"
                     :reduce (lambda (_ opt)
                               (declare (ignore _))
                               opt)))

(defconstant +option-kver+
  (adopt:make-option 'kernel-version
                     :help "Kernel version of the install."
                     :initial-value +kver+
                     :long "kver"
                     :short #\k
                     :parameter +kver+
                     :reduce (lambda (_ opt)
                               (declare (ignore _))
                               opt)))

(defconstant +option-no-clean+
  (adopt:make-option 'no-clean
                     :help "Prevent cleaning of the container."
                     :initial-value nil
                     :long "no-clean"
                     :short #\C
                     :reduce (constantly t)))

(defun run (arguments)
  ; Log options at debug level
  (log:debug "OPTIONS:")
  (maphash (lambda (k v)
             (log:debug "  ~a: ~a" k v))
           *options*)
  (log:debug "ARGUMENTS:")
  (dolist (arg arguments)
          (log:debug "  ~a" arg))

  (eli arguments))

(defmacro exit-on-ctrl-c (&body body)
  `(handler-case (with-user-abort:with-user-abort (progn ,@body))
     (with-user-abort:user-abort () (adopt:exit 130))))

(defvar *ui*
  (adopt:make-interface
   :name "eli"
   :summary "Eli is a CLI tool that facilitate installation and management of linux distributions."
   :usage "usage"
   :help "abcd"
   :contents (list +option-help+ +option-install-dir+ +option-kver+ +option-no-clean+)))

(defvar *options* nil
  "Map of CLI options.")

(defun toplevel ()
  ; (sb-ext:disable-debugger)
  ;; Logs on stdout
  (log:config :debug :pattern "%d [%p] %m%n")
  (exit-on-ctrl-c
   (multiple-value-bind (arguments *options*) (adopt:parse-options-or-exit *ui*)
     (handler-case (cond
                    ((gethash 'help *options*) (adopt:print-help-and-exit *ui*))
                    (t (progn
                        (required-cmds-are-installed)
                        (run arguments))))
       (user-error (e)
                   (log:error "~a" (user-error-message e))
                   (log:error "exiting with status ~a~%" (user-error-code e))
                   (adopt:exit :code (user-error-code e)))))))
