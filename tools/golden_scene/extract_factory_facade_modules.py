import argparse, os, sys, math
import bpy
import bmesh
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--source",required=True)
ap.add_argument("--out",required=True)
ap.add_argument("--count",type=int,default=3)
ns=ap.parse_args(argv())

source=os.path.abspath(ns.source)
out=os.path.abspath(ns.out)
os.makedirs(out,exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=source)

for obj in list(bpy.data.objects):
    if obj.type in {"CAMERA","LIGHT"}:
        bpy.data.objects.remove(obj,do_unlink=True)

meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
if not meshes:
    raise SystemExit("V11 factory source has no meshes")

# Bake object transforms, then join the complete modular presentation into one
# material-preserving mesh so spatial cuts include brick, doors, windows and trim.
bpy.ops.object.select_all(action="DESELECT")
for o in meshes:
    o.select_set(True)
bpy.context.view_layer.objects.active=meshes[0]
bpy.ops.object.convert(target="MESH")
bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
bpy.ops.object.join()
base=bpy.context.active_object
base.name="factory_facade_source_joined"

coords=[]
for v in base.data.vertices:
    p=base.matrix_world @ v.co
    coords.append(p)
xmin=min(p.x for p in coords); xmax=max(p.x for p in coords)
ymin=min(p.y for p in coords); ymax=max(p.y for p in coords)
zmin=min(p.z for p in coords); zmax=max(p.z for p in coords)
width=xmax-xmin
print("FRONTLINE_V11_FACTORY_BOUNDS",xmin,xmax,ymin,ymax,zmin,zmax,"width",width)

# Use actual face-density quantiles rather than raw bbox fractions. The Poly
# Haven presentation contains empty lateral space, so bbox-only slicing can hit
# empty regions even though usable facade geometry exists elsewhere.
face_centers=[]
for poly in base.data.polygons:
    if not poly.vertices:
        continue
    xs=[base.data.vertices[i].co.x for i in poly.vertices]
    face_centers.append(sum(xs)/float(len(xs)))
face_centers.sort()
if len(face_centers)<32:
    raise SystemExit("V11 factory geometry too sparse for module extraction")

quantiles=[0.18,0.50,0.82]
centers=[]
for q in quantiles[:ns.count]:
    pos=int(round(q*float(len(face_centers)-1)))
    centers.append(face_centers[max(0,min(len(face_centers)-1,pos))])
slice_width=min(width*0.18,10.0)
print("FRONTLINE_V11_DENSITY_CENTERS",centers,"slice_width",slice_width)
exported=0

for idx,cx in enumerate(centers):
    lo=cx-slice_width*0.5
    hi=cx+slice_width*0.5

    dup=base.copy()
    dup.data=base.data.copy()
    bpy.context.collection.objects.link(dup)
    dup.name=f"factory_module_{idx:02d}"

    bm=bmesh.new()
    bm.from_mesh(dup.data)
    geom=list(bm.verts)+list(bm.edges)+list(bm.faces)
    bmesh.ops.bisect_plane(
        bm,geom=geom,dist=0.0001,
        plane_co=Vector((lo,0,0)),plane_no=Vector((1,0,0))
    )
    geom=list(bm.verts)+list(bm.edges)+list(bm.faces)
    bmesh.ops.bisect_plane(
        bm,geom=geom,dist=0.0001,
        plane_co=Vector((hi,0,0)),plane_no=Vector((1,0,0))
    )
    outside=[v for v in bm.verts if v.co.x < lo-0.001 or v.co.x > hi+0.001]
    if outside:
        bmesh.ops.delete(bm,geom=outside,context="VERTS")
    bm.to_mesh(dup.data)
    bm.free()
    dup.data.update()

    if len(dup.data.polygons)<8:
        bpy.data.objects.remove(dup,do_unlink=True)
        continue

    # Center the module and put its geometric bottom on z=0.
    pts=[dup.matrix_world @ Vector(c) for c in dup.bound_box]
    minv=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)))
    maxv=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)))
    center=(minv+maxv)*0.5
    dup.location.x-=center.x
    dup.location.y-=center.y
    dup.location.z-=minv.z

    bpy.ops.object.select_all(action="DESELECT")
    dup.select_set(True)
    bpy.context.view_layer.objects.active=dup
    path=os.path.join(out,f"factory_module_{idx:02d}.glb")
    bpy.ops.export_scene.gltf(
        filepath=path,export_format="GLB",use_selection=True,export_apply=True,
        export_cameras=False,export_lights=False
    )
    size=os.path.getsize(path) if os.path.exists(path) else 0
    print("FRONTLINE_V11_FACTORY_MODULE",idx,"slice",lo,hi,"polys",len(dup.data.polygons),"bytes",size,path)
    if size>32768:
        exported+=1
    bpy.data.objects.remove(dup,do_unlink=True)

if exported<3:
    raise SystemExit(f"V11 expected 3 usable factory modules, got {exported}")
print("FRONTLINE_V11_FACTORY_SPLIT_PASS",exported)
