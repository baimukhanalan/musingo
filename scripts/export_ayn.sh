#!/bin/sh
# Encode Blender RGBA frames as compact animation assets and motion-free stills.
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
for mood in idle greet thinking success error prayer learning praise; do
  set -- "$project_dir/design/ayn/frames/$mood/"*.png
  if [ "$#" -ne 32 ]; then
    printf 'Expected 32 frames for %s, found %s\n' "$mood" "$#" >&2
    exit 1
  fi
  # Preserving transparent RGB prevents block-shaped halos around the character.
  img2webp -loop 0 -lossy -q 82 -m 5 -exact -d 63 "$@" \
    -o "$project_dir/assets/images/ayn_$mood.webp"
  cwebp -quiet -q 86 -exact \
    "$project_dir/design/ayn/frames/$mood/001.png" \
    -o "$project_dir/assets/images/ayn_${mood}_still.webp"
done
