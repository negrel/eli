#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/buildah.sh"

function prepare_ctr_from {
  log_info "creating container from image \"$1\"..."
  local ctr=$(buildah_from $1)
  log_info "container \"$ctr\" created from image \"$1\"."

  log_info "mounting container \"$ctr\" on host..."
  mnt_dir=$(buildah_mount $ctr)
  log_info "container \"$ctr\" mounted on host."

  log_info "preparing container \"$ctr\"..."

  # Mounting /proc /dev /sys and /run
  log_info "mounting \"/dev\" \"/proc\" \"/sys\" \"/run\" directories..."
  for d in dev proc sys run; do
    log_debug "mounting \"$d\" in container..."
    mount --rbind /$d "$mnt_dir/$d"
    mount --make-rslave "$mnt_dir/$d"
    log_debug "\"$d\" mounted."
  done
  log_info "directories \"/dev\" \"/proc\" \"/sys\" \"/run\" mounted."

  local eli_image="${ELI_IMAGE:-$1}"
  buildah config --env ELI_IMAGE="$eli_image" $ctr
  add_image_env $1 $ctr $mnt_dir
  log_info "container \"$ctr\" ready."

  echo $ctr $mnt_dir
}

function destroy_ctr {
  log_info "removing container \"$1\"..."
  buildah_rm $1 2> >(log_pipe "[BUILDAH] %s")
  log_info "container $1 removed."
}

function ctr_chroot {
  local ctr_mnt="$(buildah mount $1)"
  shift

  chroot $ctr_mnt /bin/sh -e -c "$*"
}
