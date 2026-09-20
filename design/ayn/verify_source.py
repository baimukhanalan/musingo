"""Run with Blender -b design/ayn/ayn_articulated.blend --python this_file."""
import bpy

scene = bpy.context.scene
assert scene.render.fps == 24
assert scene.render.engine == 'BLENDER_EEVEE'
assert scene.eevee.taa_render_samples == 32
assert scene.camera is not None and scene.camera.data.type == 'ORTHO'
assert scene.render.film_transparent
assert len(scene.timeline_markers) == 8
book = bpy.data.objects['Book joint']
for marker in scene.timeline_markers:
    scene.frame_set(marker.frame + 31)
    hidden = marker.name == 'prayer'
    assert all(child.hide_render == hidden for child in book.children), marker.name
    assert all(child.hide_viewport == hidden for child in book.children), marker.name
    assert not book.hide_render, 'The parent must never keep the book permanently hidden'
    assert bpy.data.objects['Breathing torso'].animation_data.nla_tracks
    assert bpy.data.objects['Gaze joint'].animation_data.nla_tracks
    assert bpy.data.objects['Wrist joint'].animation_data.nla_tracks
scene.frame_set(1)
for marker in scene.timeline_markers:
    if marker.name not in {'greet', 'success', 'error', 'praise'}:
        continue
    scene.frame_set(marker.frame)
    initial = tuple(bpy.data.objects['Shoulder joint'].rotation_euler)
    scene.frame_set(marker.frame + 71)
    final = tuple(bpy.data.objects['Shoulder joint'].rotation_euler)
    assert all(abs(a-b) < 1e-5 for a,b in zip(initial, final)), marker.name
scene.frame_set(1)
print('Ayn source verified: 8 NLA performances, EEVEE32, 24 fps, camera, alpha, prayer book visibility, settled reaction endings.')
