#!/usr/bin/env bash

set -e

function print_help {
  cat <<EOF
$cmdname install-iso - install/generate an ISO from an OCI/Docker image.

USAGE:
  $cmdname  -- eli/archlinux /dev/sda
  $cmdname  -- eli/archlinux /home/$USER/image.iso

OPTIONS:
  -h, --help                   print this menu
  -o, --option custom          option that will be passed to the image install script
  -p, --persistent-partiton    add a persistent partiton to the destination if it's a block file (default: true)
  -P, --no-persistent-partiton prevents the addition of a persistent partition
  -v, --volume-id              custom volume id (default: image name)

EOF
}

function generate_iso_at {  
  local ctr="$1"
  local dst="$2"
  shift 2

  log_info "generating ISO image at \"$dst\"..."
  ctr_chroot $ctr \
    $@ \
    /eli/scripts/install-iso
  log_info "ISO image successfully generated at \"$dst\"."
}

function main {
  local options=()

  while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;

      -o|--option)
        shift
        local key="$(cut -d '=' -f 1 <<< "ELI_$1" | tr 'a-z' 'A-Z' | tr -d '\n' | tr -c '[:alnum:]' '_')"
        local value="$(cut -d '=' -f 2 <<< "$1")"
        options+=("$key=$value")
        shift
        ;;

      -p|--persistent-partition)
        options+=("ELI_PERSISTENT_PART=y")
        shift
        ;;

      -P|--no-persistent-partition)
        options+=("ELI_PERSISTENT_PART=n")
        shift
        ;;

      -v|--volume-id)
        shift
        options+=("ELI_VOLUME_ID=$1")
        shift
        ;;

      --)
        shift
        break
        ;;

      -*|--*)
        log_error "unknown option: $1"
        log_error "run \"$cmdname install-iso --help\" to see the list of availables options."
        stacktrace=n exit 1
        ;;
      
      *)
        break
        ;;
    esac
  done

  # Image to install
  local img=$1
  if [ -z "$img" ]; then
    log_error "missing IMG option."
    stacktrace=n exit 1
  fi

  # ISO destination
  local dst=$2
  if [ -z "$dst" ]; then
    log_error "missing DST option."
    stacktrace=n exit 1
  fi

  if [ ! -e "$dst" ]; then
    log_info "destination file \"$dst\" don't exist, creating it..."
    touch "$dst"
    log_info "destination file \"$dst\" created."
  fi

  if [ ! -w "$dst" ]; then
    log_error "can't write to destination file: \"$dst\""
    stacktrace=n exit 1
  fi

  if [ -d "$dst" ]; then
    log_error "\"$dst\" is a directory."
    stacktrace=n exit 1
  fi
  shift 2

  if [ $# -gt 0 ]; then
    log_error "unexpected option(s): $@"
    stacktrace=n exit 1
  fi

  log_info "preparing container for image \"$img\"..."
  local prep=($(prepare_ctr_from $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "container \"$ctr\" based on image \"$img\" ready for install."

  # Mount destination file
  touch $ctr_dir/eli/iso.iso
  mount --bind $dst $ctr_dir/eli/iso.iso

  generate_iso_at $ctr $dst ${options[@]}
  destroy_ctr $ctr
}
