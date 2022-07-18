#!/usr/bin/env bash

function print_help {
  cat <<EOF
$cmdname install-iso - install/generate an ISO from an OCI/Docker image.

USAGE:
  $cmdname  -- eli/archlinux /dev/sda
  $cmdname  -- eli/archlinux /home/$USER/image.iso

OPTIONS:
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

  log_info "preparing container for image \"$img\"..."
  local prep=($(prepare_ctr_from $img))
  local ctr=${prep[0]}
  local ctr_dir=${prep[1]}
  log_info "container \"$ctr\" based on image \"$img\" ready for install."

  # Mount destination file
  touch $ctr_dir/eli/iso.iso
  mount --bind $dst $ctr_dir/eli/iso.iso

  log_info "generating ISO image at \"$dst\"..."
  ctr_chroot $ctr \
    ELI_INSTALL_TYPE="iso" \
    ${options[@]} \
    /eli/scripts/install-iso \
  || (
    log_error "ISO image generation failed.";
    destroy_ctr $ctr;
    clean_exit 1
  )

  log_info "ISO image successfully generated at \"$dst\"."
  destroy_ctr $ctr
}
