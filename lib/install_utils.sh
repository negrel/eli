#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"

function create_ctr {
  log_debug "creating container from image \"$1\"..."
  local ctr=$(buildah from $1)
  log_debug "container \"$ctr\" created from image \"$1\"."

  echo $ctr
}

function remove_ctr {
  log_debug "removing container \"$1\"..."
  buildah rm $1
  log_debug "container \"$1\" removed."
}

function prepare_ctr {
  local ctr="$1"

  log_debug "mounting container \"$ctr\" on host..."
  local mnt_dir=$(buildah mount $ctr)
  log_debug "container \"$ctr\" mounted on host."

  # Mounting /proc /dev /sys and /run
  log_debug "mounting \"/dev\" \"/proc\" \"/sys\" \"/run\" directories..."
  mount --rbind /dev $mnt_dir/dev && mount --make-rslave $mnt_dir/dev
  mount --rbind -o ro /proc $mnt_dir/proc && mount --make-rslave $mnt_dir/proc
  mount --rbind -o ro /sys $mnt_dir/sys && mount --make-rslave $mnt_dir/sys
  mount --rbind /run $mnt_dir/run && mount --make-rslave $mnt_dir/run
  log_debug "directories \"/dev\" \"/proc\" \"/sys\" \"/run\" mounted."
}

function unprepare_ctr {
  local ctr="$1"
  local mnt_dir=$(buildah mount $ctr)

  log_debug "unmounting \"/dev\" \"/proc\" \"/sys\" \"/run\" directories..."
  umount -l $mnt_dir/dev $mnt_dir/proc $mnt_dir/sys $mnt_dir/run
  log_debug "directories \"/dev\" \"/proc\" \"/sys\" \"/run\" unmounted."

  log_debug "unmounting \"$ctr\"..."
  buildah umount $ctr
  log_debug "\"$ctr\" unmounted."
}

function setup_ctr {
  local ctr=$(create_ctr $1)
  prepare_ctr $ctr
  
  echo $ctr
}

function destroy_ctr {
  unprepare_ctr $1 || true
  remove_ctr $1
}

function ctr_chroot {
  local ctr_mnt="$(buildah mount $1)"
  shift

  chroot $ctr_mnt /bin/sh -e -c "$*"
}
