"""Externalize/deduplicate glTF textures without changing mesh/PBR channel data.
All LOD GLBs reference one shared 4K JPEG library. No image color transforms.
"""
from pathlib import Path
import struct,json,hashlib,io,sys
from PIL import Image
root=Path(sys.argv[1]);folder=root/'textures';folder.mkdir(exist_ok=True)
manifest=root/'texture_processing.json';records=json.loads(manifest.read_text()) if manifest.exists() else {}
for path in sorted(root.glob('repair_workshop_lod*.glb')):
 b=path.read_bytes();size,typ=struct.unpack_from('<II',b,12);g=json.loads(b[20:20+size]);off=20+size;bin_size=struct.unpack_from('<I',b,off)[0];binary=b[off+8:off+8+bin_size]
 old_views=g['bufferViews'];image_views=set()
 for image in g.get('images',[]):
  if 'bufferView' not in image:
   assert (path.parent/image['uri']).is_file(),image['uri']
   continue
  i=image['bufferView'];image_views.add(i);view=old_views[i];data=binary[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
  im=Image.open(io.BytesIO(data));stream=io.BytesIO()
  # JPEG input, no alpha; keep exact 4K dimensions and avoid chroma subsampling in normals.
  im.convert('RGB').save(stream,format='JPEG',quality=92,subsampling=0)
  data=stream.getvalue();sha=hashlib.sha256(data).hexdigest();name=sha[:20]+'.jpg';(folder/name).write_bytes(data)
  records[name]={'sha256':sha,'bytes':len(data),'size':list(im.size),'source_image_name':image.get('name',''),'encoding':'JPEG quality 92, 4:4:4; no color conversion'}
  image.pop('bufferView');image.pop('mimeType',None);image['uri']='textures/'+name
 new_binary=bytearray();new_views=[];mapping={}
 for i,v in enumerate(old_views):
  if i in image_views:continue
  while len(new_binary)%4:new_binary.append(0)
  offset=len(new_binary);new_binary.extend(binary[v.get('byteOffset',0):v.get('byteOffset',0)+v['byteLength']]);mapping[i]=len(new_views);new_views.append({**v,'byteOffset':offset})
 for acc in g.get('accessors',[]):
  if 'bufferView' in acc:acc['bufferView']=mapping[acc['bufferView']]
 g['bufferViews']=new_views;g['buffers']=[{'byteLength':len(new_binary)}]
 jb=json.dumps(g,separators=(',',':')).encode();jb+=b' '*((-len(jb))%4);new_binary.extend(b'\0'*((-len(new_binary))%4))
 total=12+8+len(jb)+8+len(new_binary)
 path.write_bytes(struct.pack('<4sII',b'glTF',2,total)+struct.pack('<I4s',len(jb),b'JSON')+jb+struct.pack('<I4s',len(new_binary),b'BIN\0')+new_binary)
 print('SHARED_GLB',path.name,total,flush=True)
(root/'texture_processing.json').write_text(json.dumps(records,indent=2))
