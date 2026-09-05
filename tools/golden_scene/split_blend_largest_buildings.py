import bpy, os, sys, re, argparse
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--out", required=True)
ap.add_argument("--max", type=int, default=8)
ns=ap.parse_args(argv())
out=os.path.abspath(ns.out)
os.makedirs(out, exist_ok=True)

def clean(n):
    n=re.sub(r"[^A-Za-z0-9_-]+","_",n).strip("_")
    return n[:56] or "urban"

def descendants(root):
    result=[]; stack=[root]
    while stack:
        o=stack.pop(); result.append(o); stack.extend(list(o.children))
    return result

roots=[o for o in bpy.context.scene.objects if o.parent is None and o.type not in {"CAMERA","LIGHT"}]
groups=[]
for root in roots:
    group=descendants(root)
    meshes=[o for o in group if o.type=="MESH"]
    if not meshes: continue
    pts=[]
    for o in meshes:
        mw=o.matrix_world
        pts.extend([mw @ Vector(c) for c in o.bound_box])
    if not pts: continue
    minv=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)))
    maxv=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)))
    size=maxv-minv
    score=max(0.001,size.x*size.y*size.z)+max(size.x*size.y,size.x*size.z,size.y*size.z)*2.0
    groups.append((score,root.name,group,minv,maxv))

if len(groups)<2:
    groups=[]
    for o in bpy.context.scene.objects:
        if o.type!="MESH": continue
        pts=[o.matrix_world @ Vector(c) for c in o.bound_box]
        minv=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)))
        maxv=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)))
        size=maxv-minv
        score=max(0.001,size.x*size.y*size.z)+max(size.x*size.y,size.x*size.z,size.y*size.z)*2.0
        groups.append((score,o.name,[o],minv,maxv))

groups.sort(key=lambda x:x[0], reverse=True)
chosen=groups[:ns.max]
print("FRONTLINE_V10_SOURCE_GROUPS",len(groups),"CHOSEN",len(chosen))
exported=0
for idx,(score,name,group,minv,maxv) in enumerate(chosen):
    members=set(group)
    top=[o for o in group if o.parent not in members]
    saved={o.name:o.matrix_world.copy() for o in top}
    center=(minv+maxv)*0.5
    shift=Vector((-center.x,-center.y,-minv.z))
    for o in top:
        m=o.matrix_world.copy(); m.translation=m.translation+shift; o.matrix_world=m
    bpy.ops.object.select_all(action="DESELECT")
    active=None
    for o in group:
        try:
            o.select_set(True)
            if active is None and o.type=="MESH": active=o
        except Exception:
            pass
    if active is None: continue
    bpy.context.view_layer.objects.active=active
    path=os.path.join(out,f"{idx:02d}_{clean(name)}.glb")
    bpy.ops.export_scene.gltf(filepath=path,export_format="GLB",use_selection=True,export_apply=True,export_cameras=False,export_lights=False)
    for o in top: o.matrix_world=saved[o.name]
    if os.path.exists(path) and os.path.getsize(path)>8192:
        exported+=1
        print("FRONTLINE_V10_BUILDING",idx,name,score,path)
if exported<3:
    raise SystemExit(f"V10 expected >=3 independent urban buildings, got {exported}")
print("FRONTLINE_V10_SPLIT_PASS",exported)
