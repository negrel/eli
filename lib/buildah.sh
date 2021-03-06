#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"

function buildah_from {
  local img="$1"

  if [ -z "$img" ]; then
    log_fatal "missing IMG argument."
  fi

  run buildah from $img
}

function buildah_rm {
  local ctr="$1"

  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi

  run buildah rm $ctr
}

function buildah_run {
  local ctr="$1"
  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi
  shift

  local cmd="$@"
  if [ -z "$cmd" ]; then
    log_fatal "missing CMD argument"
  fi

  run buildah run \
    -e ELI_DEBUG="$ELI_DEBUG" \
    -e ELI_TRACE="$ELI_TRACE" \
    $ctr $cmd
}

function buildah_mount {
  local ctr="$1"
  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi
  shift


  run buildah mount $ctr
}

function buildah_inspect {
  local ctr="$1"
  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi
  shift


  run buildah inspect $@ $ctr
}

function buildah_commit {
  local ctr="$1"
  local img="$2"

  if [ -z "$ctr" ]; then
    log_fatal "missing CTR argument"
  fi

  if [ -z "$img" ]; then
    log_fatal "missing IMG argument"
  fi
  shift 2
  
  run buildah commit $@ $ctr $img
}
