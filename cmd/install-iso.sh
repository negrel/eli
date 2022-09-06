#!/usr/bin/env bash

function print_help {
  cat <<EOF
$cmdname install-iso - install/generate an ISO from an OCI/Docker image.

USAGE:
  $cmdname install-iso eli/archlinux /dev/sda
  $cmdname install-iso eli/archlinux /home/$USER/image.iso

OPTIONS:
  --debug                      enable debug logs
  -h, --help                   print this menu
  -o, --option                 custom option that will be passed to the image install script
  -O, --option-file            custom option file (default: .eli)
  -v, --volume-id              custom volume id (default: image name)

EOF
}

function main {
  local options=()
  if [ -r ".eli" ]; then
    parse_option_file ".eli"
  fi

  while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;

      --debug)
        ELI_DEBUG=y
        shift
        options+=("ELI_DEBUG=y")
        ;;

      -o|--option)
        shift
        parse_option "$1"
        shift
        ;;
      
      -O|--option-file)
        shift
        parse_option_file "$1"
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
        clean_exit 1
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
    clean_exit 1
  fi

  # ISO destination
  local dst=$2
  if [ -z "$dst" ]; then
    log_error "missing DST option."
    clean_exit 1
  fi

  if [ ! -e "$dst" ]; then
    log_info "destination file \"$dst\" don't exist, creating it..."
    touch "$dst"
    log_info "destination file \"$dst\" created."
  fi

  if [ ! -w "$dst" ]; then
    log_error "can't write to destination file: \"$dst\""
    clean_exit 1
  fi

  if [ -d "$dst" ]; then
    log_error "\"$dst\" is a directory."
    clean_exit 1
  fi
  shift 2

  if [ $# -gt 0 ]; then
    log_error "unexpected option(s): $@"
    clean_exit 1
  fi

  log_info "setting up container to install image \"$img\"..."
  local ctr="$(setup_ctr $img)"
  local ctr_dir=$(buildah mount $ctr)
  log_info "container \"$ctr\" based on image \"$img\" ready for installation."

  # Mount destination file
  touch $ctr_dir/eli/iso.iso
  mount --bind $dst $ctr_dir/eli/iso.iso

  log_info "generating ISO image at \"$dst\"..."
  ctr_chroot $ctr \
    ELI_IMAGE="$img"
    ELI_INSTALL_TYPE="iso" \
    ${options[@]} \
    /eli/bin/install-iso \
  || (
    log_error "ISO image generation failed.";
    destroy_ctr $ctr;
    clean_exit 1
  )

  log_info "ISO image successfully generated at \"$dst\"."
  destroy_ctr $ctr
}
