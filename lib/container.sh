#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/buildah.sh"

function create_and_mount_ctr {
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

function generate_squashfs {
  log_info "generating squashfs in container \"$1\"..."
  buildah_run -t $1 /eli/scripts/mksquashfs > >(log_pipe "[MKSQUASHFS] %s") 2>&1
  log_info "squashfs generated in container \"$1\"."
}

function generate_initramfs {
  log_info "generating initramfs in \"$1\"..."
  buildah_run -t $1 /eli/scripts/mkinitramfs > >(log_pipe "[MKINITRAMFS] %s") 2>&1
  log_info "initramfs generated in \"$1\"."
}

function generate_iso {
  log_info "generating ISO in container \"$1\"..."
  # FIXME: use --add-cap only and remove chroot
  # Chroot because we need to setup some loop device
  buildah_run -t --isolation chroot --cap-add=CAP_SYS_ADMIN \
    $1 /eli/scripts/mkiso > >(log_pipe "[MKISO] %s") 2>&1
  log_info "ISO image generated in container \"$1\"."
}
