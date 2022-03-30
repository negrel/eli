#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/buildah.sh"

function create_and_mount_ctr {
  log_info "creating container from image \"$1\"..."
  local ctr=$(buildah_from $1 2> >(log_pipe "[BUILDAH] %s"))
  log_info "container \"$ctr\" created from image \"$1\"."

  log_info "mounting container \"$ctr\" on host..."
  mnt_dir=$(buildah_mount $ctr 2> >(log_pipe "[BUILDAH] %s"))
  log_info "container \"$ctr\" mounted on host."

  echo $ctr $mnt_dir
}

function destroy_ctr {
  log_info "removing container \"$1\"..."
  buildah_rm $1 2> >(log_pipe "[BUILDAH] %s")
  log_info "container $1 removed."
}

function generate_squashfs {
  log_info "generating squashfs in container \"$1\"..."
  buildah_run --user root $1 /eli/scripts/mksquashfs 2> >(log_pipe "[MKSQUASHFS] %s")
  log_info "squashfs generated in container \"$1\"."
}

function generate_initramfs {
  log_info "generating initramfs in \"$1\"..."
  buildah_run --user root $1 /eli/scripts/mkinitramfs 2> >(log_pipe "[MKINITRAMFS] %s") 
  log_info "initramfs generated in \"$1\"."
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

function image_env {
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

function _unquote_string {
  result=${1#"'"}
  result=${result%"'"}
  echo "$result"
}

function add_image_env {
  log_info "adding \"$1\" image environment variable to installation..."
  local envfile="$2/etc/environment.d/99-eli.conf"
  if [ ! -d "$2/etc/environment.d" ]; then
    envfile="$2/etc/environment"
  fi
  
  for envvar in $(image_env $1); do
    log_debug "adding \"$envvar\" environment variable..."

    if [ "${envvar##ELI_}" != "$envvar" ]; then
      log_debug "\"$envvar\" contains \"ELI_\" prefix, skipping it."
      continue
    fi
    echo "$(_unquote_string $envvar)" >> "$envfile"

    log_debug "\"$envvar\" environment variable added..."
  done
  log_info "\"$1\" image environment variable added."
}