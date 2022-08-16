#!/usr/bin/env bash

function print_help {
  cat <<EOF
$cmdname install - install OCI/Docker image on disk.

USAGE:
  $cmdname install -a i386-pc -o bootloader-overwrite=y --option custom-option=value -- eli/archlinux /dev/sda1 /dev/sda2

OPTIONS:
  --debug                       enable debug logs
  -i, --initramfs-overwrite     overwrite initramfs if one is already present in the image
  -I, --no-initramfs-overwrite  prevent initramfs overwrite
  -h, --help                    print this menu
  -o, --option                  custom option that will be passed to the image install script
  -O, --option-file             custom option file (default: .eli)
  -r, --rootfs-overwrite        overwrite the root filesystem device (default: true)
  -R, --no-rootfs-overwrite     prevent overwriting of the root filesystem partition
  --trace                       enable tracing

EOF
}

function main {
  local options=()
  if [ -r ".eli" ]; then
    parse_option_file ".eli"
  fi

  while [ $# -gt 0 ]; do
    case $1 in
      -i|--initramfs-overwrite)
        options+=("ELI_INITRAMFS_OVERWRITE=y")
        shift
        ;;

      -I|--no-initramfs-overwrite)
        options+=("ELI_INITRAMFS_OVERWRITE=n")
        shift
        ;;

      --debug)
        ELI_DEBUG=y
        shift
        options+=("ELI_DEBUG=y")
        ;;

      -h|--help)
        print_help
        exit 0
        ;;

      -o|--option)
        shift
        parse_option "$1"
        shift
        ;;
      
      -O|--option-file)
        shift
        parse_option_file "$1"
        shift
        ;;

      -r|--overwrite-rootfs)
        options+=("ELI_ROOTFS_OVERWRITE=y")
        shift
        ;;

      -R|--no-overwrite-rootfs)
        options+=("ELI_ROOTFS_OVERWRITE=n")
        shift
        ;;

      --trace)
        shift
        options+=("ELI_TRACE=y")
        ;;

      --)
        shift
        break
        ;;

      -*|--*)
        log_error "unknown option: $1"
        log_error "run \"$cmdname install --help\" to see the list of availables options."
        clean_exit 1
        ;;
      
      *)
        break
        ;;
    esac
  done

  # Image to install
  local img="$1"
  if [ -z "$img" ]; then
    log_error "missing IMG option."
    clean_exit 1
  fi

  # Boot device
  local boot_dev="$2"
  if [ -z "$boot_dev" ]; then
    log_error "missing BOOT_DEVICE option."
    clean_exit 1
  fi

  if [ ! -w "$boot_dev" ]; then
    log_error "can't write to boot device: \"$boot_dev\""
    clean_exit 1
  fi

  # Root filesystem device
  local rootfs_dev="$3"

  if [ -z "$rootfs_dev" ]; then
    log_error "missing ROOTFS_DEVICE option."
    clean_exit 1
  fi

  if [ ! -w "$rootfs_dev" ]; then
    log_error "can't write to rootfs device: \"$rootfs_dev\""
    clean_exit 1
  fi
  shift 3

  if [ $# -gt 0 ]; then
    log_error "unexpected option(s): $@"
    clean_exit 1
  fi

  log_info "setting up container to install image \"$img\"..."
  local ctr="$(setup_ctr $img)"
  log_info "container \"$ctr\" based on image \"$img\" ready for installation."

  log_info "installing image..."
  ctr_chroot $ctr \
    ELI_ROOTFS_DEVICE="$rootfs_dev" \
    ELI_BOOTLOADER_DEVICE="$boot_dev" \
    ELI_INSTALL_TYPE="" \
    ${options[@]} \
    /eli/scripts/install \
  || (
    log_error "image installation failed.";
    destroy_ctr $ctr;
    clean_exit 1
  )

  log_info "image successfully installed."
  destroy_ctr $ctr
}
