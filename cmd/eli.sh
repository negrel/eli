#!/usr/bin/env bash

function print_help {
  cat <<EOF
eli - Front-end CLI to install OCI/Docker images.

USAGE:
  $cmdname [options] subcommands [subcommands options]
  $cmdname -h
  $cmdname install --help
  $cmdname install-iso --help

OPTIONS:
  -h, --help print this menu

COMMANDS:
  install     install an OCI/Docker image on disk
  install-iso generate an ISO from the given OCI/Docker image

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
