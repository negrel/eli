#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function copy_iso {
  log_info "copying iso to \"$2\"..."
  run dd if="$1/boot/eli.iso" of="$2" bs=4M status=progress > >(log_pipe "[COPY] %s") 2>&1 
  run sync > >(log_pipe "[COPY] %s") 2>&1 
  log_info "iso copied to \"$2\"."
}

function main {
  local img=$1
  local dst=$2

  if [ -z "$img" ]; then
    log_error "missing IMG option"
    stacktrace=n exit 1
  fi

  if [ -z "$dst" ]; then
    log_error "missing DST option"
    stacktrace=n exit 1
  fi

  log_info "preparing image \"$img\" for install..."
  local prep=($(create_and_mount_ctr $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}

  generate_squashfs $ctr
  generate_initramfs $ctr
  generate_iso $ctr
  log_info "image \"$img\" ready for install."

  log_info "installing ISO of \"$img\" on \"$dst\"..."
  copy_iso $ctr_dir $dst
  destroy_ctr $ctr
  log_info "ISO of \"$img\" installed on \"$dst\"."
}
