#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function prepare_ctr {
  log_info "creating container from image \"$1\"..."
  local ctr=$(buildah_from $1)
  log_info "container \"$ctr\"created from image \"$1\"."

  log_info "mounting container \"$ctr\" on host..."
  mnt_dir=$(buildah_mount $ctr)
  log_info "container \"$ctr\" mounted on host."

  echo $ctr $mnt_dir
}

function destroy_ctr {
  log_info "removing container \"$1\"..."
  buildah_rm $1 2>&1 > >(log_pipe "[BUILDAH] %s")
  log_info "container $1 removed."
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

  local prep=($(prepare_ctr $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}

  copy_iso $ctr_dir $dst

  destroy_ctr $ctr
}