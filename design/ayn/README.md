# Ayn articulated mascot

`ayn_articulated.blend` is the editable Blender 5.2 source. The character is built
from independent head, eyelid, gaze, eyebrow, smile, ear, shoulder, wrist and tail joints. Animation actions
are retained in the file with the prefix `Ayn / <mood> / <joint>`.

Eight three-second performances cover idle, greeting, thinking, success,
encouragement after an error, prayer, learning and praise. Greeting, success,
encouragement and praise play once and settle into a calm pose; the other four
performances loop. The character stays anchored in the layout. Gaze, eyebrows,
smiles, curved closed eyelids, head tilts and articulated wrists make the
expressions distinct. The greeting lifts a paw, waves gently, pauses and returns.

Rebuild with Blender's bundled Python:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --threads 4 --python scripts/render_ayn.py -- --preview --render
sh scripts/export_ayn.sh
```

The export uses the standard `img2webp` and `cwebp` utilities from libwebp.

The render uses 72 transparent 384×384 frames at 24 fps, a fixed orthographic
camera, three soft lights and EEVEE with 32 temporal samples and two soft-shadow
rays. This preserves the matte, rounded character while rendering a frame in
about 1.3 seconds on the development Mac after the initial shader warm-up. Only
one Blender renderer is run at a time, with four CPU helper threads. Persistent
scene data is enabled. Cycles/Metal is not used for the release animation pass.
Intermediate PNGs live in `frames_24fps/`, can be regenerated, and are not release
assets. `--contact` renders representative facial/gesture previews. `--moods
greet,success` limits a render to selected performances.

WebP uses exact alpha edges at quality 78. Frame durations repeat 42, 42, 41 ms,
giving exactly 3000 ms over 72 frames. Reaction files use loop count 1; background
states use loop count 0. Reaction posters capture expressive frame 32; the other
posters use frame 1. All eight animation files target a combined size under 6 MB.

The saved Blender NLA timeline contains eight named performances separated by
12-frame pauses. Book geometry is visible normally and hidden during prayer in
both the viewport and render. The portrait camera is saved as the active camera.

The app consumes animated WebP files from `assets/images/`. A matching static
poster is used when reduced motion is requested, a route is inactive, the app
is backgrounded, or the character is a small repeated avatar under 64 logical
pixels. The original 2D mascot assets are retained as design references.
