#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function install_at {
  local boot_dev="/dev/mapper/vg_void-lv_archbook1"
  local rootfs_dev="/dev/mapper/vg_void-lv_archbook2"
  local bootloader_target="x86_64-efi"

  log_info "installing image at \"$2\"..."

  # TODO write a custom ctr_chroot to use support image ENV VARS (e.g. source /etc/environments)
  ELI_ROOTFS_DEVICE="$rootfs_dev" \
  ELI_BOOTLOADER_DEVICE="$boot_dev" \
  ELI_BOOTLOADER_TARGET="$bootloader_target" \
    sudo -E chroot $1 /eli/scripts/install
  log_info "image installed at \"$2\"."
}

function main {
  local img=$1
  # local dst=$2

  if [ -z "$img" ]; then
    log_error "missing IMG option."
    stacktrace=n exit 1
  fi

  # if [ -z "$dst" ]; then
  #   log_error "missing DST option."
  #   stacktrace=n exit 1
  # fi

  # if [ ! -e "$dst" ]; then
  #   log_info "destination file \"$dst\" don't exist, creating it..."
  #   mkdir -p "$dst"
  #   log_info "destination file \"$dst\" created."
  # fi

  # if [ ! -w "$dst" ]; then
  #   log_error "can't write to destination file: \"$dst\""
  #   stacktrace=n exit 1
  # fi

  # if [ ! -d "$dst" ]; then
  #   log_error "\"$dst\" isn't a directory."
  #   stacktrace=n exit 1
  # fi
  # shift 2

  log_info "preparing container for image \"$img\"..."
  local prep=($(prepare_ctr_from $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "container \"$ctr\" based on image \"$img\" ready for install."

  install_at $ctr_dir $dst
  destroy_ctr $ctr
}
