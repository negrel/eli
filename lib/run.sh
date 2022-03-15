#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"

function run {
  if [ "$#" = "0" ]; then
    log_fatal "missing CMD argument"
  fi
  
  log_debug "executing: $@"
  $@
}
