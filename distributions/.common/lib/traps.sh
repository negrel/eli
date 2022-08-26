#!/usr/bin/env bash

: ${SCRIPT_DIR=$(dirname $(dirname $(readlink -f "${BASH_SOURCE[0]}")))}

source "$SCRIPT_DIR/lib/log.sh"

function exit_trap {
  local exit_code="$?"

  # Non zero exit code
  # log level is debug or greater
  if [ "$exit_code" != "0" ] \
    && [ ${_log_level[$LOG_LEVEL]} -ge ${_log_level["debug"]} ]; then
    log_error "exit code $exit_code trapped, stacktrace:"
    _stacktrace
  fi

  log_info "exit with status code of $exit_code"
  exit $exit_code
}

function clean_exit {
  local stacktrace="n"
  exit ${1:-0}
}
