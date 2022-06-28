#!/usr/bin/env bash

ELI_LOG_PREFIX="$(basename $0 | tr 'a-z' 'A-Z')"
source /eli/lib/log.sh

set -e

if [ -n "$ELI_TRACE" ]; then
  set -x
fi

if [ "$ELI_INSTALL_TYPE" = "iso" ]; then
  log_info "skipping swap entry in fstab (ISO install type)".
  exit 0
fi

if [ -z "$ELI_SWAP_DEVICE" ]; then
  log_warn "no swap id specified, skipping swap device preparation"
  exit 0
fi

log_info "setting up swap device..."

mkswap "$ELI_SWAP_DEVICE"

log_debug "adding $ELI_SWAP_DEVICE swap entry to fstab..."
echo "$ELI_SWAP_DEVICE	none	swap	sw	0	0" >> /etc/fstab
log_debug "$ELI_SWAP_DEVICE swap entry added to fstab."

log_info "swap device successfully setted up."
