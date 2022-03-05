#!/bin/sh

boot_part="${boot_part:-/boot}"

for dir in "$boot_part/eli/*"; do
  image_name="$(basename $dir)"
  cat << EOF >> /dev/stdout
EOF
done