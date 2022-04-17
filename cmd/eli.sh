#!/usr/bin/env bash

function print_help {
  cat <<EOF
eli - Linux distribution management and install made easy.

OPTIONS:

COMMANDS:

EOF
}

function main {
  if [ "$1" = "-h" -o "$1" = "--help" ]; then
    print_help
    exit 0
  fi

  if [ ! -x "$SCRIPT_DIR/cmd/$1.sh" ]; then
    log_error "unknown command: \"$1\""
    stacktrace="n" exit 1
  fi
  
  source "$SCRIPT_DIR/cmd/$1.sh"
  shift
  main $@
}
