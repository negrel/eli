#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF

EOF
}

function ctr_kver {
  buildah_run $ctr /eli/scripts/kver
}

function prepare_ctr {
  log_info "creating container from image \"$1\"..."
  local ctr=$(buildah_from $1)
  log_info "container \"$ctr\" created from image \"$1\"."

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

function commit_ctr {
  log_info "committing container \"$1\" as \"$2\"..."
  buildah_commit $1 $2 > >(log_pipe "[BUILDAH] %s") 2>&1
  log_info "container \"$1\" committed as \"$2\"."
}

function generate_squashfs {
  log_info "generating squashfs for \"$1\"..."
  buildah_run -t $1 /eli/scripts/mksquashfs > >(log_pipe "[MKSQUASHFS] %s") 2>&1
  log_info "squashfs generated for \"$1\"."
}

function generate_initramfs {
  log_info "generating initramfs for \"$1\"..."
  buildah_run -t $1 /eli/scripts/mkinitramfs > >(log_pipe "[MKINITRAMFS] %s") 2>&1
  log_info "initramfs generated for \"$1\"."
}

function build_iso {
  log_info "building ISO for image \"$1\"..."
  # Chroot because we need to setup some loop device
  # FIXME: use --add-cap instead of --isolation
  buildah_run -t --isolation chroot --cap-add=CAP_SYS_ADMIN \
    $2 /eli/scripts/mkiso > >(log_pipe "[MKISO] %s") 2>&1
  log_info "ISO for image \"$1\" built."
}

function build {
  local img="$1"

  if [ -z "$img" ]; then
    log_fatal "missing IMG argument"
  fi

  log_info "building image \"$img\"..."

  local prep=($(prepare_ctr $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}

  local kver=$(ctr_kver)

  generate_squashfs $ctr
  generate_initramfs $ctr

  build_iso $img $ctr

  local commit_img="$img:eli-$(date -Idate)"

  commit_ctr $ctr $commit_img
  destroy_ctr $ctr

  log_info "image \"$img\" built and committed as \"$commit_img\""

  echo $commit_img
}

function main {
  # TODO option to skip iso
  # TODO option to specify image name
  
  build $1
}
