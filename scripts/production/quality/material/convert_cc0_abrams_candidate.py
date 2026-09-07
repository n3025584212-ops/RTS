import argparse
import os
import sys
import bpy
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--output",required=True)
ns=ap.parse_args(argv())

# The .blend is already opened by Blender on startup. Keep renderable mesh objects only.
for obj in list(bpy.context.scene.objects):
    if obj.type not in {"MESH","CURVE"}:
        bpy.data.objects.remove(obj,do_unlink=True)

# Convert curves if any.
for obj in list(bpy.context.scene.objects):
    if obj.type == "CURVE":
        bpy.context.view_layer.objects.active=obj
        obj.select_set(True)
        bpy.ops.object.convert(target="MESH")
        obj.select_set(False)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
if not meshes:
    raise SystemExit("FRONTLINE_CC0_ABRAMS_NO_MESH")

# Apply object transforms so export bounds are deterministic.
for obj in meshes:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    try:
        bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    except Exception as exc:
        print("FRONTLINE_CC0_ABRAMS_TRANSFORM_WARN",obj.name,exc)

# Compute world bounds; center horizontal axes and ground Z.
mins=[1e30,1e30,1e30]
maxs=[-1e30,-1e30,-1e30]
for obj in meshes:
    for c in obj.bound_box:
        p=obj.matrix_world@Vector(c)
        for i in range(3):
            mins[i]=min(mins[i],p[i]); maxs[i]=max(maxs[i],p[i])
cx=(mins[0]+maxs[0])*0.5
cy=(mins[1]+maxs[1])*0.5
gz=mins[2]
for obj in meshes:
    obj.location.x-=cx
    obj.location.y-=cy
    obj.location.z-=gz

print("FRONTLINE_CC0_ABRAMS_BOUNDS",mins,maxs)
print("FRONTLINE_CC0_ABRAMS_MESH_COUNT",len(meshes))
for obj in meshes[:120]:
    mats=[slot.material.name if slot.material else "" for slot in obj.material_slots]
    print("FRONTLINE_CC0_ABRAMS_MESH",obj.name,"materials",mats)

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
print("FRONTLINE_CC0_ABRAMS_EXPORT",ns.output)
