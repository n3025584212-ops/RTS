import argparse, os, re, sys
import bpy

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--source",required=True)
ap.add_argument("--output",required=True)
ap.add_argument("--target-tris",type=int,default=110000)
ns=ap.parse_args(argv())

# Start clean, import glTF.
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=os.path.abspath(ns.source))

for obj in list(bpy.data.objects):
    if obj.type in {"CAMERA","LIGHT"}:
        bpy.data.objects.remove(obj,do_unlink=True)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
if not meshes:
    raise SystemExit("V15 tree import produced no meshes")

# If explicit LOD objects exist, prefer the lowest-detail complete LOD group.
levels={}
for o in meshes:
    m=re.search(r"lod[ _.-]*(\d+)",o.name,re.I)
    if m:
        levels.setdefault(int(m.group(1)),[]).append(o)
if levels:
    level=max(levels)
    keep=set(levels[level])
    for o in list(meshes):
        if o not in keep:
            bpy.data.objects.remove(o,do_unlink=True)
    meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
    print("FRONTLINE_V15_LOD",level,len(meshes))

# Convert/evaluate modifiers before decimation.
bpy.ops.object.select_all(action="DESELECT")
for o in meshes:
    o.hide_set(False)
    o.hide_render=False
    o.select_set(True)
bpy.context.view_layer.objects.active=meshes[0]
try:
    bpy.ops.object.convert(target="MESH")
except Exception as e:
    print("FRONTLINE_V15_CONVERT_WARN",e)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
tris=sum(len(o.data.loop_triangles) if len(o.data.loop_triangles)>0 else len(o.data.polygons)*2 for o in meshes)
if tris<=0:
    tris=sum(len(o.data.polygons)*2 for o in meshes)
ratio=min(1.0,max(0.02,float(ns.target_tris)/float(max(1,tris))))
print("FRONTLINE_V15_TRIS_BEFORE",tris,"ratio",ratio)
if ratio < 0.98:
    for o in meshes:
        if len(o.data.polygons)<50:
            continue
        bpy.context.view_layer.objects.active=o
        o.select_set(True)
        mod=o.modifiers.new("FRONTLINE_LOD","DECIMATE")
        mod.ratio=ratio
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        except Exception as e:
            print("FRONTLINE_V15_DECIMATE_WARN",o.name,e)

# Ground and center.
from mathutils import Vector
mins=[1e30,1e30,1e30]; maxs=[-1e30,-1e30,-1e30]
for o in meshes:
    for c in o.bound_box:
        p=o.matrix_world@Vector(c)
        for a in range(3):
            mins[a]=min(mins[a],p[a]); maxs[a]=max(maxs[a],p[a])
cx=(mins[0]+maxs[0])*0.5
cy=(mins[1]+maxs[1])*0.5
gz=mins[2]
for o in bpy.context.scene.objects:
    if o.parent is None:
        o.location.x-=cx; o.location.y-=cy; o.location.z-=gz

os.makedirs(os.path.dirname(os.path.abspath(ns.output)),exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
for o in meshes: o.select_set(True)
bpy.context.view_layer.objects.active=meshes[0]
bpy.ops.export_scene.gltf(filepath=os.path.abspath(ns.output),export_format="GLB",use_selection=True,export_apply=True,export_cameras=False,export_lights=False)
print("FRONTLINE_V15_TREE_EXPORT",ns.output)
