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
FPS = 24
FRAMES = 72
SEGMENT = 84
REACTIONS = {'greet', 'success', 'error', 'praise'}
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
pupils=[]
brows=[]
lids=[]
for side in (-1,1):
    x=.34*side
    eye=empty('Blink eyelid rig',(x,-.516,.54),head)
    uv('White of eye',(0,0,0),(.235,.063,.265),white,eye)
    gaze=empty('Gaze joint',(0,0,0),eye)
    uv('Pupil',(side*.012,-.055,.008),(.123,.037,.175),ink,gaze)
    uv('Large catchlight',(-.040,-.085,.078),(.040,.016,.049),white,gaze)
    uv('Small catchlight',(.037,-.089,-.048),(.017,.013,.020),white,gaze)
    pupils.append(gaze)
    eyes.append(eye)
    lid=empty('Closed eyelid joint',(x,-.605,.54),head)
    line('Closed eyelid',[(-.18,0,.025),(0,-.008,-.028),(.18,0,.025)],.018,blue_dark,lid)
    lids.append(lid)
    ring=[(x+.267*math.cos(t),-.585,.54+.29*math.sin(t)) for t in [i*2*math.pi/36 for i in range(36)]]
    line('Round glasses',ring,.026,ink,head,True)
    line('Glasses temple',[(x+side*.265,-.57,.57),(side*.79,-.35,.61)],.025,ink,head)
    brow=empty('Eyebrow joint',(x,-.49,.91),head)
    line('Kind eyebrow',[(-.11,0,0),(0,-.01,.04),(.11,0,.02)],.033,blue_dark,brow)
    brows.append(brow)
    for n in range(2):
        line('Soft whisker',[(side*.64,-.445,.30-n*.11),(side*.80,-.39,.33-n*.14)],.017,blue_dark,head)
line('Glasses bridge',[(-.074,-.583,.55),(0,-.60,.58),(.074,-.583,.55)],.025,ink,head)
uv('Pink nose',(0,-.60,.305),(.085,.045,.060),pink,head)
smile=empty('Smile joint',(0,-.565,.24),head)
line('Smile left',[(0,0,.015),(-.06,.002,-.05),(-.14,.015,-.005)],.018,ink,smile)
line('Smile right',[(0,0,.015),(.06,.002,-.05),(.14,.015,-.005)],.018,ink,smile)
joy=empty('Joyful mouth joint',(0,-.566,.185),head)
uv('Open joyful mouth',(0,0,0),(.17,.029,.061),ink,joy)
uv('Tongue',(0,-.027,-.027),(.094,.008,.022),pink,joy)

arms=[]
wrists=[]
for side in (-1,1):
    arm=empty('Shoulder joint',(.48*side,-.01,.62),body)
    uv('Robe sleeve',(.15*side,0,-.23),(.235,.27,.39),cream,arm)
    wrist=empty('Wrist joint',(.20*side,-.02,-.51),arm)
    uv('Cyan hand',(0,0,0),(.18,.21,.20),blue,wrist)
    for d in (-.055,.045):
        line('Paw fingers',[(d,-.204,-.03),(d,-.207,.05)],.009,blue_dark,wrist)
    arms.append(arm)
    wrists.append(wrist)

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
scene.render.engine='BLENDER_EEVEE'
scene.eevee.taa_render_samples=32
scene.eevee.shadow_ray_count=2
scene.render.use_persistent_data=True
scene.render.resolution_x=384
scene.render.resolution_y=384
scene.render.resolution_percentage=100
scene.render.film_transparent=True
scene.render.image_settings.file_format='PNG'
scene.render.image_settings.color_mode='RGBA'
scene.render.fps=FPS
scene.frame_start=1; scene.frame_end=FRAMES
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

def smoothstep(start,end,t):
    x=max(0,min(1,(t-start)/(end-start)))
    return x*x*(3-2*x)

def pose(mood,frame):
    t=(frame-1)/(FRAMES-1 if mood in REACTIONS else FRAMES)
    wave=math.sin(t*math.tau)
    # Reactions enter gently, hold their intent, then settle completely.
    gesture=smoothstep(.035,.24,t)*(1-smoothstep(.68,1,t))
    body.scale=(1+.003*wave,1+.005*wave,1+.005*wave)
    head.rotation_euler=(0,0,0)
    head.rotation_euler[1]=.014*wave
    tail.rotation_euler[2]=.045*wave
    for n,e in enumerate(ears): e.rotation_euler[1]=(-1 if n==0 else 1)*.025*math.sin(t*math.tau+.8)
    for a in arms: a.rotation_euler=(0,0,0)
    for wrist in wrists: wrist.rotation_euler=(0,0,0)
    for pupil in pupils: pupil.location=(0,0,0)
    for brow in brows:
        brow.rotation_euler=(0,0,0)
        brow.location.z=.91
    book.rotation_euler=(0,0,0)
    smile.scale=(1,1,1)
    joy.scale=(.001,.001,.001)
    # Eye whites close entirely; a curved eyelid replaces the old white slit.
    blink=max(.001,1-math.exp(-((t-.73)/.026)**2))
    for eye in eyes: eye.scale.z=blink
    closed=max(.001,1-smoothstep(.02,.38,blink))
    for lid in lids: lid.scale=(closed,1,closed)
    if mood=='greet':
        # A raised paw, two small wrist waves, a quiet pause and a soft return.
        wave_window=smoothstep(.22,.30,t)*(1-smoothstep(.53,.62,t))
        arms[0].rotation_euler[1]=1.85*gesture
        arms[0].rotation_euler[0]=-.16*gesture
        wrists[0].rotation_euler[1]=.26*math.sin((t-.24)*math.tau*5)*wave_window
        head.rotation_euler[1]=-.065*gesture+.014*wave
        for brow in brows: brow.location.z+=.025*gesture
        smile.scale.x=1+.13*gesture
    elif mood=='success':
        arms[0].rotation_euler[1]=2.10*gesture
        wrists[0].rotation_euler[1]=-.15*gesture
        head.rotation_euler[0]=-.065*gesture+.035*wave*gesture
        for eye in eyes: eye.scale.z=(1-.12*gesture)*blink
        for brow in brows: brow.location.z+=.033*gesture
        ears[0].rotation_euler[1]=-.10*gesture; ears[1].rotation_euler[1]=.10*gesture
        joy.scale=(gesture,gesture,gesture)
        smile.scale=(1-.9*gesture,1,1-.9*gesture)
    elif mood=='praise':
        arms[0].rotation_euler[1]=1.10*gesture
        arms[0].rotation_euler[0]=-.20*gesture
        head.rotation_euler[0]=.085*math.sin(t*math.tau*2)*gesture
        smile.scale.x=1+.25*gesture
        for brow in brows: brow.location.z+=.016*gesture
    elif mood=='thinking':
        arms[0].rotation_euler[1]=-2.15
        arms[0].rotation_euler[0]=-.35
        head.rotation_euler[1]=-.105+.016*wave
        head.rotation_euler[2]=.045
        for pupil in pupils: pupil.location=(-.04,0,.048)
        brows[0].location.z+=.035
        brows[1].rotation_euler[1]=-.15
        smile.scale=(.75,1,.8)
    elif mood=='error':
        head.rotation_euler[0]=.07*gesture
        head.rotation_euler[1]=.075*gesture
        ears[0].rotation_euler[1]=-.15*gesture; ears[1].rotation_euler[1]=.15*gesture
        arms[0].rotation_euler[0]=-.45*gesture
        arms[0].rotation_euler[1]=-.16*gesture
        for i,brow in enumerate(brows): brow.rotation_euler[1]=(-.16 if i==0 else .16)*gesture
        for pupil in pupils: pupil.location.z=-.024*gesture
        smile.scale.x=1-.22*gesture
    elif mood=='learning':
        head.rotation_euler[0]=.15+.018*wave
        head.rotation_euler[2]=-.035
        for pupil in pupils: pupil.location=(.042,0,-.045)
        arms[1].rotation_euler[0]=-.17
        arms[0].rotation_euler[0]=-.45
        arms[0].rotation_euler[1]=-.48
        book.rotation_euler[0]=-.06
        smile.scale.x=.85
    elif mood=='prayer':
        head.rotation_euler[0]=.16+.012*wave
        for eye in eyes: eye.scale.z=.001
        for lid in lids: lid.scale=(1,1,1)
        smile.scale=(.85,1,.7)
        arms[0].rotation_euler[0]=-1.50
        arms[0].rotation_euler[1]=-.70
        arms[1].rotation_euler[0]=-1.50
        arms[1].rotation_euler[1]=.70
        wrists[0].rotation_euler=(.35,0,.20)
        wrists[1].rotation_euler=(.35,0,-.20)
    for child in book.children:
        child.hide_render=mood=='prayer'
        child.hide_viewport=mood=='prayer'

moods=['idle','greet','thinking','success','error','prayer','learning','praise']
animated=[body,head,tail,book,smile,joy,*ears,*arms,*wrists,*eyes,*pupils,*brows,*lids]
saved_actions={obj: [] for obj in animated}
for mood in moods:
    scene.timeline_markers.new(mood,frame=1+moods.index(mood)*SEGMENT)
# Store editable joint actions and arrange the eight performances on the NLA timeline.
for mood in moods:
    for frame in range(1,FRAMES+1):
        pose(mood,frame)
        for obj in animated:
            obj.keyframe_insert(data_path='rotation_euler',frame=frame)
            obj.keyframe_insert(data_path='scale',frame=frame)
            obj.keyframe_insert(data_path='location',frame=frame)
    for obj in animated:
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
        strip=track.strips.new(moods[index],1+index*SEGMENT,action)
        strip.extrapolation='NOTHING'
for child in book.children:
    for index,mood in enumerate(moods):
        child.hide_render=mood=='prayer'
        child.hide_viewport=mood=='prayer'
        child.keyframe_insert(data_path='hide_render',frame=1+index*SEGMENT)
        child.keyframe_insert(data_path='hide_viewport',frame=1+index*SEGMENT)
    child.hide_render=False
    child.hide_viewport=False
scene.frame_end=(len(moods)-1)*SEGMENT+FRAMES
scene.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'ayn_articulated.blend'))
for obj in saved_actions: obj.animation_data_clear()
for child in book.children: child.animation_data_clear()
if '--preview' in sys.argv:
    pose('greet',32)
    scene.render.filepath=os.path.join(OUT,'preview.png')
    bpy.ops.render.render(write_still=True)
if '--contact' in sys.argv:
    for mood in ['greet','success','thinking','prayer']:
        pose(mood,32)
        scene.render.filepath=os.path.join(OUT,f'preview_{mood}.png')
        bpy.ops.render.render(write_still=True)
if '--render' in sys.argv:
    selected=moods
    if '--moods' in sys.argv:
        selected=sys.argv[sys.argv.index('--moods')+1].split(',')
    for mood in selected:
        folder=os.path.join(OUT,'frames_24fps',mood); os.makedirs(folder,exist_ok=True)
        for frame in range(1,FRAMES+1):
            pose(mood,frame)
            scene.render.filepath=os.path.join(folder,f'{frame:03d}.png')
            bpy.ops.render.render(write_still=True)
