import argparse, os, re, sys
import bpy

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

def texture_from_obj(obj_path):
    base=os.path.dirname(obj_path)
    mtls=[]
    with open(obj_path,"r",encoding="utf-8",errors="ignore") as f:
        for line in f:
            if line.lower().startswith("mtllib "):
                mtls.append(os.path.join(base,line.split(None,1)[1].strip()))
    for mtl in mtls:
        if not os.path.isfile(mtl):
            continue
        with open(mtl,"r",encoding="utf-8",errors="ignore") as f:
            for line in f:
                if line.lower().startswith("map_kd "):
                    p=line.split(None,1)[1].strip().strip('"')
                    p=os.path.normpath(os.path.join(os.path.dirname(mtl),p))
                    if os.path.isfile(p):
                        return p
    stem=os.path.basename(obj_path).lower().replace("_baked.obj","")
    imgs=[]
    for root,_,files in os.walk(base):
        for name in files:
            low=name.lower()
            if not low.endswith((".png",".jpg",".jpeg")):
                continue
            score=0
            if stem in low:
                score+=120
            if "baked" in low:
                score+=70
            if any(token in low for token in ("diff","albedo","basecolor","base_color","color","colour","texture","tex_")):
                score+=110
            if any(token in low for token in ("ao_","_ao","ambient","normal","_nor","rough","metal","spec","height","disp")):
                score-=220
            imgs.append((-score,os.path.join(root,name),score))
    imgs.sort()
    for item in imgs[:12]:
        print("FRONTLINE_V20_TEXTURE_CANDIDATE",item[2],item[1])
    return imgs[0][1] if imgs and imgs[0][2] > 0 else None

ap=argparse.ArgumentParser()
ap.add_argument("--source",required=True)
ap.add_argument("--output",required=True)
ns=ap.parse_args(argv())
source=os.path.abspath(ns.source)
output=os.path.abspath(ns.output)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
if hasattr(bpy.ops.wm,"obj_import"):
    bpy.ops.wm.obj_import(filepath=source)
else:
    bpy.ops.import_scene.obj(filepath=source)

tex_path=texture_from_obj(source)
if tex_path is None:
    raise SystemExit("V20 baked OBJ texture not found: "+source)
image=bpy.data.images.load(tex_path,check_existing=True)
print("FRONTLINE_V20_BAKED_TEXTURE",source,tex_path)

for obj in bpy.context.scene.objects:
    if obj.type!="MESH":
        continue
    if len(obj.data.materials)==0:
        obj.data.materials.append(bpy.data.materials.new("V20Baked"))
    for mat in obj.data.materials:
        if mat is None:
            continue
        mat.use_nodes=True
        nodes=mat.node_tree.nodes
        links=mat.node_tree.links
        bsdf=next((n for n in nodes if n.type=="BSDF_PRINCIPLED"),None)
        if bsdf is None:
            continue
        tex=nodes.new("ShaderNodeTexImage")
        tex.image=image
        links.new(tex.outputs["Color"],bsdf.inputs["Base Color"])
        bsdf.inputs["Roughness"].default_value=0.76

os.makedirs(os.path.dirname(output),exist_ok=True)
bpy.ops.export_scene.gltf(
    filepath=output,export_format="GLB",export_apply=True,export_yup=True,
    export_cameras=False,export_lights=False
)
if not os.path.isfile(output) or os.path.getsize(output)<1024:
    raise SystemExit("V20 textured GLB export failed")
print("FRONTLINE_V20_TEXTURED_EXPORT",output,os.path.getsize(output))
