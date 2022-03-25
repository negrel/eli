#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function generate_iso_at {  
  log_info "generating ISO in container \"$1\" at \"$2\"..."
  buildah_run --mount type=bind,source="$2",destination=/eli/iso.iso \
    -t --user root \
    --isolation chroot --cap-add=CAP_SYS_ADMIN --cap-add=CAP_MKNOD \
    $1 /eli/scripts/mkiso > >(log_pipe "[MKISO] %s") 2>&1
  log_info "ISO image generated at \"$2\" in container \"$1\"."
}

function main {
  local img=$1
  local dst=$2

  if [ -z "$img" ]; then
    log_error "missing IMG option."
    stacktrace=n exit 1
  fi

  if [ -z "$dst" ]; then
    log_error "missing DST option."
    stacktrace=n exit 1
  fi

  if [ ! -e "$dst" ]; then
    log_info "destination file \"$dst\" don't exist, creating it..."
    touch "$dst"
    log_info "destination file \"$dst\" created."
  fi

  if [ ! -w "$dst" -a]; then
    log_error "can't write to destination file: \"$dst\""
    stacktrace=n exit 1
  fi

  if [ -d "$dst" ]; then
    log_error "\"$dst\" is a directory."
    stacktrace=n exit 1
  fi

  log_info "preparing image \"$img\" for install..."
  local prep=($(create_and_mount_ctr $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "image \"$img\" ready for install, starting installation..."

  add_image_env $img $ctr_dir
  generate_squashfs $ctr
  generate_initramfs $ctr
  generate_iso_at $ctr $dst
  destroy_ctr $ctr

  log_info "ISO installed successfully."
}
