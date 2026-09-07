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

# The source .blend is opened by Blender on startup.
# Keep renderable building geometry only; remove cameras/lights/helpers.
for obj in list(bpy.context.scene.objects):
    if obj.type not in {"MESH","CURVE"}:
        bpy.data.objects.remove(obj,do_unlink=True)

for obj in list(bpy.context.scene.objects):
    if obj.type=="CURVE":
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.convert(target="MESH")
        obj.select_set(False)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
if not meshes:
    raise SystemExit("FRONTLINE_HOUSE_V14_NO_MESH")

# Remove tiny isolated helper meshes only; retain architectural/interior pieces.
kept=[]
for obj in meshes:
    dims=obj.dimensions
    volume=max(float(dims.x*dims.y*dims.z),0.0)
    if volume < 1e-8:
        bpy.data.objects.remove(obj,do_unlink=True)
        continue
    kept.append(obj)
meshes=kept
if not meshes:
    raise SystemExit("FRONTLINE_HOUSE_V14_NO_VALID_MESH")

for obj in meshes:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    try:
        bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    except Exception as exc:
        print("FRONTLINE_HOUSE_V14_TRANSFORM_WARN",obj.name,exc)

    # Give truly material-less objects a neutral authored fallback so GLB export
    # never turns structural parts into emissive/white debug surfaces.
    if len(obj.data.materials)==0:
        m=bpy.data.materials.new("V14NeutralStructure")
        m.use_nodes=True
        bsdf=m.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            bsdf.inputs["Base Color"].default_value=(0.42,0.40,0.35,1.0)
            bsdf.inputs["Roughness"].default_value=0.78
        obj.data.materials.append(m)

mins=[1e30,1e30,1e30]
maxs=[-1e30,-1e30,-1e30]
for obj in meshes:
    for c in obj.bound_box:
        p=obj.matrix_world@Vector(c)
        for ax in range(3):
            mins[ax]=min(mins[ax],p[ax])
            maxs[ax]=max(maxs[ax],p[ax])

cx=(mins[0]+maxs[0])*0.5
cy=(mins[1]+maxs[1])*0.5
ground=mins[2]
for obj in meshes:
    obj.location.x-=cx
    obj.location.y-=cy
    obj.location.z-=ground

print("FRONTLINE_HOUSE_V14_BOUNDS",mins,maxs,"center",cx,cy,"ground",ground)
print("FRONTLINE_HOUSE_V14_MESH_COUNT",len(meshes))
for obj in meshes[:160]:
    mats=[slot.material.name if slot.material else "" for slot in obj.material_slots]
    print("FRONTLINE_HOUSE_V14_MESH",obj.name,"dims",tuple(round(float(v),4) for v in obj.dimensions),"materials",mats)

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
print("FRONTLINE_HOUSE_V14_EXPORT",ns.output)
