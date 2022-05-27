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
  log_info "directories\"/dev\" \"/proc\" \"/sys\" \"/run\" mounted."

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

function _env_ociv1 {
  buildah_inspect $1 | jq -r '.OCIv1.config.Env|@sh' || true
}

function _env_docker_cfg {
  buildah_inspect $1 | jq -r '.Docker.config.Env|@sh' || true
}

function _env_docker_ctr_cfg {
  buildah_inspect $1 | jq -r '.Docker.container_config.Env|@sh' || true
}

function _image_env {
  declare -a result
  result=($(_env_ociv1 $1))
  if [ "${#result[@]}" != "0" ]; then
    echo "${result[@]}"
    return 0
  fi

  result=($(_env_docker_cfg $1))
  if [ "${#result[@]}" != "0" ]; then
    echo "${result[@]}"
    return 0
  fi

  result=($(_env_docker_ctr_cfg $1))
  if [ "${#result[@]}" != "0" ]; then
    echo "${result[@]}"
    return 0
  fi
}

function image_env {
  local envs=($(_image_env $1))

  for i in ${!envs[@]}; do
    envs[i]="$(_unquote_string ${envs[$i]})"
  done

  echo "${envs[@]}"
}

function _unquote_string {
  result=${1#"'"}
  result=${result%"'"}
  echo "$result"
}

function add_image_env {
  local img="$1"
  local ctr="$2"
  local ctr_dir="$3"

  log_info "adding \"$img\" image environment variable to installation..."

  for envvar in $(image_env $1); do
    local env="$(_unquote_string $envvar)"
    log_debug "adding \"$env\" environment variable..."

    if [ "${env##ELI_}" != "$env" ]; then
      log_debug "\"$env\" contains \"ELI_\" prefix, skipping it."
      continue
    fi

    ctr_chroot $ctr /eli/scripts/set_env $envvar

    log_debug "\"$env\" environment variable added."
  done
  log_info "\"$1\" image environment variable added."
}

function ctr_chroot {
  local ctr_mnt="$(buildah mount $1)"
  local ctr_env=($(image_env $1))
  shift

  chroot $ctr_mnt /bin/sh -e -c "${ctr_env[*]}; $*"
}
