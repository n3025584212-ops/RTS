"""Pack the licensed source glTF without changing authored geometry/materials."""
from pathlib import Path
import json,struct,io,hashlib,shutil
from PIL import Image
root=Path(__file__).resolve().parents[2]
src=root.parent/'external/abrams';out=root/'assets/visual_slice'
d=json.loads((src/'scene.gltf').read_text());blob=bytearray((src/d['buffers'][0]['uri']).read_bytes())
for image in d['images']:
    im=Image.open(src/image.pop('uri'));im.thumbnail((1536,1536),Image.Resampling.LANCZOS)
    buf=io.BytesIO()
    # Source materials are opaque. Preserve any meaningful alpha if present.
    alpha=im.mode=='RGBA' and im.getchannel('A').getextrema()[0]<255
    if alpha:im.save(buf,format='PNG',optimize=True);mime='image/png'
    else:im.convert('RGB').save(buf,format='JPEG',quality=92);mime='image/jpeg'
    while len(blob)%4:blob.append(0)
    idx=len(d['bufferViews']);data=buf.getvalue()
    d['bufferViews'].append({'buffer':0,'byteOffset':len(blob),'byteLength':len(data)})
    blob.extend(data);image['bufferView']=idx;image['mimeType']=mime
d['buffers']=[{'byteLength':len(blob)}]
jb=json.dumps(d,separators=(',',':')).encode();jb+=b' '*((-len(jb))%4);blob+=b'\0'*((-len(blob))%4)
packed=struct.pack('<III',0x46546c67,2,28+len(jb)+len(blob))+struct.pack('<II',len(jb),0x4e4f534a)+jb+struct.pack('<II',len(blob),0x004e4942)+blob
out.mkdir(parents=True,exist_ok=True);(out/'abrams.glb').write_bytes(packed)
lic=root/'docs/licenses/visual_slice';lic.mkdir(parents=True,exist_ok=True)
for name in ['license.txt','source_manifest.json']:shutil.copy2(src/name,lic/('abrams_'+name))
shutil.copy2(root.parent/'external/abrams_author.json',lic/'abrams_author_api_20260908.json')
print('ABRAMS_PACKED_BYTES',len(packed),'SHA256',hashlib.sha256(packed).hexdigest())
