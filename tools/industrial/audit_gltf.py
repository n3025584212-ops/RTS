"""Inspect only requested hero and workshop payloads. Emits reproducible asset evidence."""
import json,struct,hashlib,math,sys
from pathlib import Path
root=Path(__file__).resolve().parents[2]
def parse(path):
 if path.suffix=='.gltf':return json.loads(path.read_text()),None
 b=path.read_bytes();n=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+n]);return g,b[28+n:]
def audit(path):
 g,b=parse(path);prims=[p for m in g.get('meshes',[]) for p in m['primitives']];acc=g['accessors']
 missing=[];tri=0;verts=0
 for p in prims:
  tri+=(acc[p['indices']]['count'] if 'indices' in p else acc[p['attributes']['POSITION']]['count'])//3
  verts+=acc[p['attributes']['POSITION']]['count']
  for k in ['POSITION','NORMAL','TEXCOORD_0','TANGENT']:
   if k not in p['attributes']:missing.append(k)
 for img in g.get('images',[]):
  if 'uri' in img and not img['uri'].startswith('data:'):assert (path.parent/img['uri']).is_file(),img['uri']
 return {'file':path.relative_to(root).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size,'meshes':len(g.get('meshes',[])),'primitives':len(prims),'triangles':tri,'vertices':verts,'materials':len(g.get('materials',[])),'textures':len(g.get('images',[])),'missing_vertex_attributes':sorted(set(missing)),'material_maps':[{'name':m.get('name'),'normal':bool(m.get('normalTexture')),'orm':bool(m.get('pbrMetallicRoughness',{}).get('metallicRoughnessTexture')),'ao':bool(m.get('occlusionTexture'))} for m in g.get('materials',[])]}
paths=[root/'assets/visual_slice'/p for p in ['abrams.glb','hero_house_ruined.glb','hero_house_ruined_hf.glb','house_intact.glb','house_damaged.glb','hero_v2/abrams_v2.glb','hero_v2/urban_ruin/urban_ruin.gltf']]
paths+=sorted((root/'assets/visual_slice/industrial_workshop').glob('repair_workshop_lod*.glb'))
result=[audit(p) for p in paths];dest=root/'artifacts/industrial_workshop';dest.mkdir(parents=True,exist_ok=True);(dest/'asset_audit.json').write_text(json.dumps(result,indent=2))
for r in result:print(r['file'],r['triangles'],r['materials'],r['missing_vertex_attributes'])
