#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function install_at {
  local boot_dev="$3"
  local rootfs_dev="$4"

  log_info "installing image..."

  ctr_chroot $1 \
    ELI_ROOTFS_DEVICE="$rootfs_dev" \
    ELI_BOOTLOADER_DEVICE="$boot_dev" \
    /eli/scripts/install

  log_info "image successfully installed."
}

function main {
  local img="$1"
  local boot_dev="$2"
  local rootfs_dev="$3"

  if [ -z "$img" ]; then
    log_error "missing IMG option."
    stacktrace=n exit 1
  fi

  if [ -z "$boot_dev" ]; then
    log_error "missing BOOT_DEVICE option."
    stacktrace=n exit 1
  fi

  if [ ! -w "$boot_dev" ]; then
    log_error "can't write to boot device: \"$boot_dev\""
    stacktrace=n exit 1
  fi

  if [ -z "$rootfs_dev" ]; then
    log_error "missing ROOTFS_DEVICE option."
    stacktrace=n exit 1
  fi

  if [ ! -w "$rootfs_dev" ]; then
    log_error "can't write to rootfs device: \"$rootfs_dev\""
    stacktrace=n exit 1
  fi
  shift 3

  # TODO add flags to overwrite bootloader, overwrite rootfs, sets bootloader-arch, or add custom options

  log_info "preparing container for image \"$img\"..."
  local prep=($(prepare_ctr_from $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "container \"$ctr\" based on image \"$img\" ready for install."

  install_at $ctr $ctr_dir $boot_dev $rootfs_dev
  destroy_ctr $ctr
}
