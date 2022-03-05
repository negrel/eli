(in-package :asdf-user)

(defsystem "eli"
  :description "Linux distribution management made easy."
  :version "0.0.1"
  :author "Alexandre Negrel <negrel.dev@protonmail.com>"
  :license "Apache-2.0 License"
  :class :package-inferred-system
  :depends-on ("with-user-abort" "adopt" "log4cl")
  :components ((:file "eli.lisp"))
  :in-order-to ((test-op (load-op "eli/test/all")))
  :perform (test-op (o c) (symbol-call :test/all :test-suite)))

(defsystem "eli/test"
  :depends-on ("eli/test/all"))

(register-system-packages "eli/test/all" '(:test/all))
