: ${SCRIPT_DIR=$(dirname $(dirname $(readlink -f "${BASH_SOURCE[0]}")))}

source "$SCRIPT_DIR/lib/log4bash/lib.sh"

if [ -n "${ELI_TRACE:-""}" ]; then
  set -x
fi
