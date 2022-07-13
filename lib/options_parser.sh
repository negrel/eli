#!/usr/bin/env bash

function parse_option_key {
  cut -d '=' -f 1 <<< "ELI_$1" | tr 'a-z' 'A-Z' | tr -d '\n' | tr -c '[:alnum:]' '_'
}

function parse_option_value {
  cut -d '=' -f 2- <<< "$1"
}

function parse_option {
  local key=$(parse_option_key $1)
  local value=$(parse_option_value $1)

  options+=("$key=$value")
}

function parse_option_file {
  if [ ! -r "$1" ]; then
    log_error "can't read option file: \"$1\""
    stacktrace=n exit 1
  fi
  
  while IFS= read -r line; do
    parse_option $line
  done < "$1"
}