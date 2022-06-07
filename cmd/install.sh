#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF
$cmdname install - install OCI/Docker image on disk.

USAGE:
  $cmdname install -a i386-pc -o bootloader-overwrite=y --option custom-option=value -- eli/archlinux /dev/sda1 /dev/sda2

OPTIONS:
  -a, --arch                    bootloader target architecture to use for installation (default: x86_64-efi)
  --debug                       enable debug logs
  -i, --initramfs-overwrite     overwrite initramfs if one is already present in the image
  -I, --no-initramfs-overwrite  prevent initramfs overwrite
  -h, --help                    print this menu
  -o, --option                  custom option that will be passed to the image install script
  -r, --rootfs-overwrite        overwrite the root filesystem device (default: true)
  -R, --no-rootfs-overwrite     prevent overwriting of the root filesystem partition
  --trace                       enable tracing

EOF
}

function install_at {
  local ctr="$1"
  local boot_dev="$2"
  local rootfs_dev="$3"
  shift 3

  log_info "installing image..."

  ctr_chroot $ctr \
    ELI_ROOTFS_DEVICE="$rootfs_dev" \
    ELI_BOOTLOADER_DEVICE="$boot_dev" \
    $@ \
    /eli/scripts/install

  log_info "image successfully installed."
}

function main {
  local options=()
  
  while [ $# -gt 0 ]; do
    case $1 in
      -a|--arch)
        shift
        options+=("ELI_ARCH=$1")
        shift
        ;;

      -i|--initramfs-overwrite)
        options+=("ELI_INITRAMFS_OVERWRITE=y")
        shift
        ;;

      -I|--no-initramfs-overwrite)
        options+=("ELI_INITRAMFS_OVERWRITE=n")
        shift
        ;;

      --debug)
        shift
        options+=("ELI_DEBUG=y")
        ;;

      -h|--help)
        print_help
        exit 0
        ;;

      -o|--option)
        shift
        local key="$(cut -d '=' -f 1 <<< "ELI_$1" | tr 'a-z' 'A-Z' | tr -d '\n' | tr -c '[:alnum:]' '_')"
        local value="$(cut -d '=' -f 2 <<< "$1")"
        options+=("$key=$value")
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
        stacktrace=n exit 1
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
    stacktrace=n exit 1
  fi

  # Boot device
  local boot_dev="$2"
  if [ -z "$boot_dev" ]; then
    log_error "missing BOOT_DEVICE option."
    stacktrace=n exit 1
  fi

  if [ ! -w "$boot_dev" ]; then
    log_error "can't write to boot device: \"$boot_dev\""
    stacktrace=n exit 1
  fi

  # Root filesystem device
  local rootfs_dev="$3"

  if [ -z "$rootfs_dev" ]; then
    log_error "missing ROOTFS_DEVICE option."
    stacktrace=n exit 1
  fi

  if [ ! -w "$rootfs_dev" ]; then
    log_error "can't write to rootfs device: \"$rootfs_dev\""
    stacktrace=n exit 1
  fi
  shift 3

  if [ $# -gt 0 ]; then
    log_error "unexpected option(s): $@"
    stacktrace=n exit 1
  fi

  log_info "preparing container to install image \"$img\"..."
  local prep=($(prepare_ctr_from $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "container \"$ctr\" based on image \"$img\" ready for installation."

  install_at $ctr $boot_dev $rootfs_dev ${options[@]}
  destroy_ctr $ctr
}
