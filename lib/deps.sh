#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/buildah.sh"

function are_dependencies_installed {
  local run_cmd="$1"
  shift

  if [ -z "$run_cmd" ]; then
    log_fatal "missing RUN_CMD argument"
  fi

  if [ "$#" = "0" ]; then
    log_fatal "missing dependencies arguments"
  fi

  for dep in $@; do
    local cmd=$(printf "$run_cmd 'command -v %s'" $dep)
    $cmd > /dev/null
  done
}

function are_host_dependencies_installed  {
  are_dependencies_installed run $@
}

function are_ctr_dependencies_installed {
  local ctr="$1"
  shift

  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi

  are_dependencies_installed "buildah_run $ctr bash -c" $@
}