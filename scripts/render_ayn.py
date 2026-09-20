"""Build Muslingo's articulated Ayn mascot and render deterministic animation loops.

Blender 5.2: blender --background --python scripts/render_ayn.py -- --preview
Full export: blender --background --python scripts/render_ayn.py -- --render
Then use scripts/export_ayn.sh to encode the PNG frames as animated WebP.
"""
import bpy
import math
import os
import sys
from mathutils import Vector

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "design", "ayn")
os.makedirs(OUT, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def mat(name, color, rough=.48, metallic=0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (*color, 1)
    p.inputs['Roughness'].default_value = rough
    p.inputs['Metallic'].default_value = metallic
    return m

blue = mat('Ayn soft cyan', (.12, .62, .85))
blue_dark = mat('Whisker blue', (.025, .24, .34))
pink = mat('Warm pink', (.96, .38, .45))
cream = mat('Ivory cotton', (.96, .93, .81), .75)
seam = mat('Ivory seam', (.79, .77, .67), .7)
ink = mat('Midnight frames', (.016, .065, .086), .3)
white = mat('Eye porcelain', (1, 1, .97), .22)
book_mat = mat('Teal book', (.017, .15, .22), .35)
gold = mat('Satin gold', (.95, .66, .15), .32, .3)

def empty(name, loc, parent=None):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.location = loc
    obj.parent = parent
    return obj

def uv(name, loc, scale, material, parent=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=20, location=(0,0,0))
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = loc
    obj.scale = scale
    obj.data.materials.append(material)
    for p in obj.data.polygons: p.use_smooth = True
    return obj

def cube(name, loc, scale, material, parent=None, bevel=.06):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj=bpy.context.object
    obj.name=name
    obj.scale=scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.parent=parent
    obj.location=loc
    obj.data.materials.append(material)
    mod=obj.modifiers.new('Soft handmade edges', 'BEVEL')
    mod.width=bevel
    mod.segments=4
    obj.modifiers.new('Weighted normals', 'WEIGHTED_NORMAL')
    return obj

def line(name, points, radius, material, parent=None, cyclic=False):
    data=bpy.data.curves.new(name, 'CURVE')
    data.dimensions='3D'
    data.resolution_u=16
    data.bevel_depth=radius
    data.bevel_resolution=3
    s=data.splines.new('BEZIER')
    s.bezier_points.add(len(points)-1)
    for p, co in zip(s.bezier_points, points):
        p.co=co
        p.handle_left_type='AUTO'
        p.handle_right_type='AUTO'
    s.use_cyclic_u=cyclic
    obj=bpy.data.objects.new(name,data)
    bpy.context.collection.objects.link(obj)
    obj.parent=parent
    data.materials.append(material)
    return obj

body=empty('Breathing torso', (0,0,.9))
bpy.ops.mesh.primitive_cone_add(vertices=64,radius1=.68,radius2=.47,depth=1.40)
robe=bpy.context.object; robe.name='Tailored ivory tunic'; robe.parent=body
robe.location=(0,0,.09); robe.scale.y=.74
robe.data.materials.append(cream)
edge=robe.modifiers.new('Rounded cotton hem','BEVEL'); edge.width=.13; edge.segments=5
robe.modifiers.new('Soft fabric normals','WEIGHTED_NORMAL')
for p in robe.data.polygons: p.use_smooth=True
uv('Cyan neck',(0,0,.87),(.28,.25,.24),blue,body)
uv('Ivory collar',(0,-.02,.77),(.32,.28,.095),cream,body)
cube('Tunic placket',(0,-.385,.50),(.10,.035,.51),seam,body,.02)
for z in (.35,.52,.69): uv('Tunic button',(0,-.411,z),(.033,.022,.033),cream,body)
for x in (-.3,.3):
    uv('Paw foot',(x,-.11,.16),(.26,.32,.15),blue)
    for dx in (-.07,.07):
        line('Toe crease',[(x+dx,-.407,.13),(x+dx,-.414,.19)],.009,blue_dark)

tail=empty('Tail joint',(-.50,.14,-.10),body)
line('Curled tail',[(0,0,0),(-.43,0,.13),(-.60,0,.46),(-.53,0,.68)],.125,blue,tail)

head=empty('Head joint',(0,-.02,1.07),body)
uv('Cyan round face',(0,0,.51),(.87,.57,.72),blue,head)
ears=[]
for side in (-1,1):
    ear=empty('Ear joint',(.61*side,0,1.00),head)
    ob=uv('Rounded ear',(0,0,.19),(.22,.18,.4),blue,ear)
    ob.rotation_euler[1]=side*-.25
    uv('Pink inner ear',(0,-.152,.23),(.126,.048,.245),pink,ear)
    ears.append(ear)

# Soft continuous turban crown with folded seams following its curved surface.
uv('Turban crown',(0,.015,1.03),(.87,.56,.43),cream,head)
for index in range(4):
    points=[]
    for i in range(20):
        x=-.83+1.66*i/19
        z=.85+.12*index+.15*x
        yy=max(.006,1-(x/.91)**2-((z-1.03)/.48)**2)
        y=.015-.565*math.sqrt(yy)
        points.append((x,y,z))
    line('Wrapped turban fold',points,.028,cream,head)
    line('Fine turban stitching',[(x,y-.006,z-.028) for x,y,z in points],.006,seam,head)

eyes=[]
for side in (-1,1):
    x=.34*side
    eye=empty('Blink eyelid rig',(x,-.516,.54),head)
    uv('White of eye',(0,0,0),(.235,.063,.265),white,eye)
    uv('Pupil',(side*.012,-.055,.008),(.123,.037,.175),ink,eye)
    uv('Large catchlight',(-.040,-.085,.078),(.040,.016,.049),white,eye)
    uv('Small catchlight',(.037,-.089,-.048),(.017,.013,.020),white,eye)
    eyes.append(eye)
    ring=[(x+.267*math.cos(t),-.585,.54+.29*math.sin(t)) for t in [i*2*math.pi/36 for i in range(36)]]
    line('Round glasses',ring,.026,ink,head,True)
    line('Glasses temple',[(x+side*.265,-.57,.57),(side*.79,-.35,.61)],.025,ink,head)
    line('Kind eyebrow',[(x-.11,-.49,.94),(x,-.50,.985),(x+.11,-.49,.96)],.036,blue_dark,head)
    for n in range(2):
        line('Soft whisker',[(side*.64,-.445,.30-n*.11),(side*.80,-.39,.33-n*.14)],.017,blue_dark,head)
line('Glasses bridge',[(-.074,-.583,.55),(0,-.60,.58),(.074,-.583,.55)],.025,ink,head)
uv('Pink nose',(0,-.60,.305),(.085,.045,.060),pink,head)
line('Smile left',[(0,-.565,.255),(-.06,-.563,.19),(-.14,-.55,.235)],.018,ink,head)
line('Smile right',[(0,-.565,.255),(.06,-.563,.19),(.14,-.55,.235)],.018,ink,head)

arms=[]
for side in (-1,1):
    arm=empty('Shoulder joint',(.48*side,-.01,.62),body)
    uv('Robe sleeve',(.15*side,0,-.23),(.235,.27,.39),cream,arm)
    uv('Cyan hand',(.20*side,-.02,-.51),(.18,.21,.20),blue,arm)
    for d in (-.055,.045):
        line('Paw fingers',[(side*.20+d,-.224,-.54),(side*.20+d,-.227,-.46)],.009,blue_dark,arm)
    arms.append(arm)

book=empty('Book joint',(.39,-.48,-.22),arms[1])
cube('Book pages',(0,0,0),(.55,.11,.71),cream,book,.035)
cube('Book cover',(0,-.075,0),(.60,.035,.77),book_mat,book,.045)
cube('Book back',(0,.075,0),(.60,.03,.77),book_mat,book,.045)
border=line('Gold book border',[(-.245,-.100,-.325),(.245,-.100,-.325),(.245,-.100,.325),(-.245,-.100,.325)],.009,gold,book,True)
for point in border.data.splines[0].bezier_points:
    point.handle_left_type='VECTOR'; point.handle_right_type='VECTOR'
# Gold crescent is real curved geometry with no solid disk hiding behind it.
verts=[]
for i in range(33):
    a=math.radians(60+240*i/32)
    verts.append((-.03+.16*math.cos(a),-.106,.16*math.sin(a)))
for i in range(33):
    a=math.radians(300-240*i/32)
    verts.append((.025+.13*math.cos(a),-.107,.132*math.sin(a)))
mesh=bpy.data.meshes.new('Crescent mesh')
mesh.from_pydata(verts,[],[list(range(len(verts)))])
obj=bpy.data.objects.new('Gold crescent',mesh)
bpy.context.collection.objects.link(obj)
obj.parent=book
obj.data.materials.append(gold)
star=[]
for i in range(10):
    a=math.pi/2+i*math.pi/5
    r=.052 if i%2==0 else .023
    star.append((.13+r*math.cos(a),-.11,.035+r*math.sin(a)))
mesh=bpy.data.meshes.new('Star mesh'); mesh.from_pydata(star,[],[list(range(10))])
obj=bpy.data.objects.new('Gold star',mesh); bpy.context.collection.objects.link(obj)
obj.parent=book; obj.data.materials.append(gold)

scene=bpy.context.scene
scene.render.engine='CYCLES'
scene.cycles.samples=20
scene.cycles.use_denoising=True
scene.render.resolution_x=384
scene.render.resolution_y=384
scene.render.resolution_percentage=100
scene.render.film_transparent=True
scene.render.image_settings.file_format='PNG'
scene.render.image_settings.color_mode='RGBA'
scene.render.fps=16
scene.frame_start=1; scene.frame_end=32
scene.world.color=(.35,.35,.35)
scene.view_settings.view_transform='AgX'
scene.view_settings.look='AgX - Medium High Contrast'
scene.view_settings.exposure=.4

def area(name,loc,power,size):
    bpy.ops.object.light_add(type='AREA',location=loc)
    light=bpy.context.object; light.name=name; light.data.energy=power; light.data.shape='DISK'; light.data.size=size
    light.rotation_euler=(Vector((0,0,1.6))-light.location).to_track_quat('-Z','Y').to_euler()
area('Large softbox',(-3,-4,6),450,5)
area('Soft fill',(3,-2,3),220,4)
area('Warm rim',(1,3,4),350,3)
bpy.ops.object.camera_add(location=(.20,-10,3.45))
camera=bpy.context.object; camera.name='Portrait camera'
camera.rotation_euler=(Vector((0,-.02,1.85))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO'; camera.data.ortho_scale=4.12; scene.camera=camera

def pose(mood,frame):
    t=(frame-1)/32
    wave=math.sin(t*math.tau)
    body.scale=(1+.004*wave,1+.007*wave,1+.008*wave)
    head.rotation_euler=(0,0,0)
    head.rotation_euler[1]=.025*wave
    tail.rotation_euler[2]=.06*wave
    for n,e in enumerate(ears): e.rotation_euler[1]=(-1 if n==0 else 1)*.025*math.sin(t*math.tau+.8)
    for a in arms: a.rotation_euler=(0,0,0)
    # A quick asymmetric blink, never squash the glasses or entire character.
    blink=max(.06,1-.96*math.exp(-((t-.72)/.037)**2))
    for e in eyes: e.scale.z=blink
    if mood=='greet':
        arms[0].rotation_euler[1]=1.8+.18*math.sin(t*math.tau*2)
        arms[0].rotation_euler[0]=-.16
        head.rotation_euler[1]=-.06+.025*wave
    elif mood=='success':
        arms[0].rotation_euler[1]=2.10+.10*wave
        head.rotation_euler[0]=.035+.055*wave
        for e in eyes: e.scale.z=.82*blink
        ears[0].rotation_euler[1]=-.09; ears[1].rotation_euler[1]=.09
    elif mood=='praise':
        arms[0].rotation_euler[1]=1.28+.10*wave
        head.rotation_euler[0]=.06*math.sin(t*math.tau*2)
        for e in eyes: e.scale.z=.9*blink
    elif mood=='thinking':
        arms[0].rotation_euler[1]=-2.15
        arms[0].rotation_euler[0]=-.35
        head.rotation_euler[1]=-.12+.025*wave
        head.rotation_euler[2]=.06
    elif mood=='error':
        head.rotation_euler[0]=.12
        head.rotation_euler[2]=.035*wave
        ears[0].rotation_euler[1]=-.16; ears[1].rotation_euler[1]=.16
        arms[0].rotation_euler[0]=-.35
    elif mood=='learning':
        head.rotation_euler[0]=.16+.025*wave
        arms[1].rotation_euler[0]=-.20
        arms[0].rotation_euler[0]=-.45
        arms[0].rotation_euler[1]=-.48
    elif mood=='prayer':
        head.rotation_euler[0]=.18+.015*wave
        for e in eyes: e.scale.z=.055
        arms[0].rotation_euler[0]=-.76
        arms[0].rotation_euler[1]=-.46
        arms[1].rotation_euler[0]=-.76
        arms[1].rotation_euler[1]=.46
    book.hide_render=mood=='prayer'
    for child in book.children: child.hide_render=mood=='prayer'

moods=['idle','greet','thinking','success','error','prayer','learning','praise']
saved_actions={obj: [] for obj in [body,head,tail,*ears,*arms,*eyes]}
for mood in moods:
    scene.timeline_markers.new(mood,frame=1+moods.index(mood)*40)
# Store editable joint actions and arrange the eight performances on the NLA timeline.
for mood in moods:
    for frame in range(1,33):
        pose(mood,frame)
        for obj in [body,head,tail,*ears,*arms,*eyes]:
            obj.keyframe_insert(data_path='rotation_euler',frame=frame)
            obj.keyframe_insert(data_path='scale',frame=frame)
    for obj in [body,head,tail,*ears,*arms,*eyes]:
        action=obj.animation_data.action
        action.name=f'Ayn / {mood} / {obj.name}'
        action.use_fake_user=True
        saved_actions[obj].append(action)
        obj.animation_data_clear()
pose('idle',1)
for obj,actions in saved_actions.items():
    obj.animation_data_create()
    track=obj.animation_data.nla_tracks.new()
    track.name='Ayn emotional performances'
    for index,action in enumerate(actions):
        strip=track.strips.new(moods[index],1+index*40,action)
        strip.extrapolation='NOTHING'
for child in book.children:
    for index,mood in enumerate(moods):
        child.hide_render=mood=='prayer'
        child.hide_viewport=mood=='prayer'
        child.keyframe_insert(data_path='hide_render',frame=1+index*40)
        child.keyframe_insert(data_path='hide_viewport',frame=1+index*40)
    child.hide_render=False
    child.hide_viewport=False
scene.frame_end=312
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'ayn_articulated.blend'))
for obj in saved_actions: obj.animation_data_clear()
for child in book.children: child.animation_data_clear()
if '--preview' in sys.argv:
    pose('greet',1)
    scene.render.filepath=os.path.join(OUT,'preview.png')
    bpy.ops.render.render(write_still=True)
if '--render' in sys.argv:
    selected=moods
    if '--moods' in sys.argv:
        selected=sys.argv[sys.argv.index('--moods')+1].split(',')
    for mood in selected:
        folder=os.path.join(OUT,'frames',mood); os.makedirs(folder,exist_ok=True)
        for frame in range(1,33):
            pose(mood,frame)
            scene.render.filepath=os.path.join(folder,f'{frame:03d}.png')
            bpy.ops.render.render(write_still=True)
