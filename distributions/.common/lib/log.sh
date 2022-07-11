#!/usr/bin/env bash

: ${ELI_LOG_PREFIX:="ELI"}

declare -A log_colors
log_colors[white]="30"
log_colors[blue]="34"
log_colors[green]="32"
log_colors[yellow]="33"
log_colors[red]="31"

function color {
  printf "\033[${log_colors[$1]}m"
}

function log {
  local date="$(date -Iseconds)"

  printf "%s" "$date" 1>&2
  printf " $@" 1>&2
  printf "\n" 1>&2
}

function log_pipe {
  while IFS= read -r line; do
    log "$1" "$line"
  done
}

function _log_level {
  set +x

  local color="$1"
  local level="$2"
  shift 2

  printf "\033[${log_colors[$color]}m" 1>&2
  log "[$ELI_LOG_PREFIX] [%s] - \033[0m%s" "$level" "$(printf "%s " $@)"

  if [ -n "$ELI_TRACE" ]; then
    set -x
  fi
}

function log_debug {
  if [ -n "$ELI_DEBUG" ]; then
    _log_level "blue" "DEBUG" $@
  fi
}

function log_info {
  _log_level "green" "INFO" $@
}

function log_warn {
  _log_level "yellow" "WARN" $@
}

function log_error {
  _log_level "red" "ERROR" $@
}

function log_fatal {
  local exit_code="${?:1}"

  _log_level "red" "FATAL" "$@"
  _log_level "red" "FATAL" "stacktrace:"
  stacktrace

  exit $exit_code
}

function stacktrace {
  local frame=0 LINE SUB FILE
  while read LINE SUB FILE < <(caller "$frame"); do
    printf "\t\033[${log_colors[red]}m%s()\n\t\t%s:%s\033[0m\n" "$SUB" "$FILE" "$LINE" 1>&2
    ((frame++))
  done
}
