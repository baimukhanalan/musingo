#!/bin/sh
# Encode Blender RGBA frames as compact animation assets and motion-free stills.
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
total_bytes=0
if [ "$#" -eq 0 ]; then
  set -- idle greet thinking success error prayer learning praise
fi
mood_count=$#
for mood in "$@"; do
  case "$mood" in
    idle|greet|thinking|success|error|prayer|learning|praise) ;;
    *) printf 'Unknown Ayn mood: %s\n' "$mood" >&2; exit 2 ;;
  esac
  frame_dir="$project_dir/design/ayn/frames_24fps/$mood"
  set -- "$frame_dir/"*.png
  if [ "$#" -ne 72 ]; then
    printf 'Expected 72 frames for %s, found %s\n' "$mood" "$#" >&2
    exit 1
  fi
  loop_count=0
  poster=001
  case "$mood" in
    greet|success|error|praise) loop_count=1; poster=032 ;;
  esac
  # Preserving transparent RGB prevents block-shaped halos around the character.
  set -- -loop "$loop_count" -lossy -q 78 -m 5 -exact
  frame_index=0
  for frame in "$frame_dir/"*.png; do
    duration=42
    if [ "$((frame_index % 3))" -eq 2 ]; then duration=41; fi
    set -- "$@" -d "$duration" "$frame"
    frame_index=$((frame_index + 1))
  done
  # 42 + 42 + 41 ms per 3 frames gives exactly 3000 ms for 72 frames.
  img2webp "$@" -o "$project_dir/assets/images/ayn_$mood.webp"
  clip_bytes=$(wc -c < "$project_dir/assets/images/ayn_$mood.webp")
  total_bytes=$((total_bytes + clip_bytes))
  cwebp -quiet -q 86 -exact \
    "$frame_dir/$poster.png" \
    -o "$project_dir/assets/images/ayn_${mood}_still.webp"
done
printf '%s animation clips: %s bytes (budget: 6000000)\n' "$mood_count" "$total_bytes"
if [ "$total_bytes" -gt 6000000 ]; then
  printf 'Animation bundle exceeds its mobile download budget.\n' >&2
  exit 1
fi
