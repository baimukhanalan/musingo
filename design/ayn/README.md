# Ayn articulated mascot

`ayn_articulated.blend` is the editable Blender 5.2 source. The character is built
from independent head, eyelid, ear, shoulder and tail joints. Animation actions
are retained in the file with the prefix `Ayn / <mood> / <joint>`.

Eight two-second loops cover idle, greeting, thinking, success, encouragement
after an error, prayer, learning and praise. The character stays anchored in the
layout; blinks, head tilts and paw gestures provide movement.

Rebuild with Blender's bundled Python:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --threads 6 --python scripts/render_ayn.py -- --preview --render
sh scripts/export_ayn.sh
```

The export uses the standard `img2webp` and `cwebp` utilities from libwebp.

The render uses transparent 384×384 frames at 16 fps, a fixed orthographic camera,
three soft lights, 20 Cycles samples and denoising. Rendering is CPU-bounded to six
threads. Intermediate PNG frames can be regenerated and are not release assets.

The app consumes animated WebP files from `assets/images/`. A matching static
poster is used when reduced motion is requested, a route is inactive, the app
is backgrounded, or the character is a small repeated avatar under 64 logical
pixels. The original 2D mascot assets are retained as design references.
