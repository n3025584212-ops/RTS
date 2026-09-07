import argparse
import os
import sys
import bpy
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--source",required=True)
ap.add_argument("--output",required=True)
ns=ap.parse_args(argv())

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=os.path.abspath(ns.source))

# Remove animation data first so this proof is a true static render asset.
for obj in bpy.data.objects:
    if obj.animation_data:
        obj.animation_data_clear()
for action in list(bpy.data.actions):
    bpy.data.actions.remove(action)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
if not meshes:
    raise SystemExit("STATIC_SANITIZE_NO_MESH")

# Bake modifiers / armatures into visual mesh at current pose.
for obj in list(meshes):
    bpy.ops.object.select_all(action="DESELECT")
    obj.hide_set(False)
    obj.hide_render=False
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    try:
        bpy.ops.object.convert(target="MESH")
    except Exception as exc:
        print("FRONTLINE_STATIC_CONVERT_WARN",obj.name,exc)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]

# Detach from armatures/empties while preserving world transform.
for obj in meshes:
    world=obj.matrix_world.copy()
    obj.parent=None
    obj.matrix_world=world

# Remove all non-mesh hierarchy after baking.
for obj in list(bpy.data.objects):
    if obj.type!="MESH":
        bpy.data.objects.remove(obj,do_unlink=True)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
for obj in meshes:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    try:
        bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    except Exception as exc:
        print("FRONTLINE_STATIC_APPLY_WARN",obj.name,exc)

mins=[1e30,1e30,1e30]
maxs=[-1e30,-1e30,-1e30]
for obj in meshes:
    for c in obj.bound_box:
        p=obj.matrix_world@Vector(c)
        for axis in range(3):
            mins[axis]=min(mins[axis],p[axis])
            maxs[axis]=max(maxs[axis],p[axis])

cx=(mins[0]+maxs[0])*0.5
cy=(mins[1]+maxs[1])*0.5
ground=mins[2]
for obj in meshes:
    obj.location.x-=cx
    obj.location.y-=cy
    obj.location.z-=ground

print("FRONTLINE_STATIC_BOUNDS",mins,maxs,"center",cx,cy,"ground",ground)
for obj in meshes:
    mats=[slot.material.name if slot.material else "NONE" for slot in obj.material_slots]
    print("FRONTLINE_STATIC_MESH",obj.name,"materials",mats)

os.makedirs(os.path.dirname(os.path.abspath(ns.output)),exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active=meshes[0]
bpy.ops.export_scene.gltf(
    filepath=os.path.abspath(ns.output),
    export_format="GLB",
    use_selection=True,
    export_apply=True,
    export_cameras=False,
    export_lights=False,
    export_animations=False,
)
print("FRONTLINE_STATIC_EXPORT",ns.output)
