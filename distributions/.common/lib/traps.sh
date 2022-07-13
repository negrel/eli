#!/usr/bin/env bash

source "$SCRIPT_DIR/lib/log.sh"

function exit_trap {
  local exit_code="$?"
  local stacktrace=${stacktrace:="y"}

  if [ "$exit_code" != "0" ] && [ "$stacktrace" = "y" ]; then
    log_error "exit code $exit_code trapped, stacktrace:"
    stacktrace
  fi

  local log="log_info"
  if [ "$exit_code" != "0" ]; then
    local log="log_error"
  fi

  "$log" "exit with status code of $exit_code"
  exit $exit_code
}

function clean_exit {
  local stacktrace="n"
  exit ${1:-0}
}