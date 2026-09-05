import bpy, os, re, sys, argparse
from mathutils import Vector

def args_after_dash():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--out", required=True)
ns=ap.parse_args(args_after_dash())
out=os.path.abspath(ns.out)
os.makedirs(out, exist_ok=True)

def sanitize(name):
    s=re.sub(r"[^A-Za-z0-9_-]+","_",name).strip("_")
    return s[:64] or "building"

def descendants(root):
    result=[]
    stack=[root]
    while stack:
        o=stack.pop()
        result.append(o)
        stack.extend(list(o.children))
    return result

def has_mesh(group):
    return any(o.type=="MESH" for o in group)

roots=[o for o in bpy.context.scene.objects if o.parent is None and o.type not in {"CAMERA","LIGHT"}]
groups=[]
for r in roots:
    g=descendants(r)
    if has_mesh(g):
        groups.append((r.name,g))
if len(groups)<=1:
    groups=[(o.name,[o]) for o in bpy.context.scene.objects if o.type=="MESH"]

print("FRONTLINE_SPLIT_GROUP_COUNT",len(groups))
exported=0
for idx,(name,group) in enumerate(groups):
    mesh_objs=[o for o in group if o.type=="MESH"]
    if not mesh_objs:
        continue
    pts=[]
    for o in mesh_objs:
        mw=o.matrix_world
        for c in o.bound_box:
            pts.append(mw @ Vector(c))
    if not pts:
        continue
    minx=min(p.x for p in pts); maxx=max(p.x for p in pts)
    miny=min(p.y for p in pts); maxy=max(p.y for p in pts)
    minz=min(p.z for p in pts)
    shift=Vector((-(minx+maxx)*0.5, -(miny+maxy)*0.5, -minz))

    members=set(group)
    top=[o for o in group if o.parent not in members]
    original={o.name:o.matrix_world.copy() for o in top}
    for o in top:
        m=o.matrix_world.copy()
        m.translation = m.translation + shift
        o.matrix_world=m

    bpy.ops.object.select_all(action="DESELECT")
    for o in group:
        if o.name in bpy.context.view_layer.objects:
            o.select_set(True)
    if mesh_objs:
        bpy.context.view_layer.objects.active=mesh_objs[0]
    path=os.path.join(out, f"{idx:02d}_{sanitize(name)}.glb")
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_cameras=False,
        export_lights=False
    )
    for o in top:
        o.matrix_world=original[o.name]
    if os.path.getsize(path)>4096:
        exported+=1
        print("FRONTLINE_SPLIT_BUILDING",path)

if exported < 2:
    raise SystemExit(f"Expected >=2 independently exportable building groups, got {exported}")
print("FRONTLINE_SPLIT_BUILDINGS_PASS",exported)
