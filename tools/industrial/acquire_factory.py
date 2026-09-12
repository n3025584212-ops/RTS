"""Fetch CC0 Poly Haven factory kit; verify upstream MD5 and record SHA256."""
from pathlib import Path
import json, urllib.request, hashlib, concurrent.futures, time, argparse
parser=argparse.ArgumentParser();parser.add_argument('--source-dir',type=Path,required=True);args=parser.parse_args()
root=args.source_dir;root.mkdir(parents=True,exist_ok=True)
def read(url):
    for attempt in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'FRONTLINE-IndustrialAsset/1.0'}),timeout=120) as r:return r.read()
        except Exception:
            if attempt==3:raise
            time.sleep(2)
lock=Path(__file__).parent/'manifests/factory.json'
if lock.exists():
    pinned=json.loads(lock.read_text());files={r['file']:{**r,'url':r['source']} for r in pinned['files']}
else:
    metadata=json.loads(read('https://api.polyhaven.com/files/modular_factory_facade'))
    kit=metadata['gltf']['4k']['gltf'];files=dict(kit['include']);files['modular_factory_facade.gltf']=kit
def fetch(item):
    name,record=item;p=root/name;p.parent.mkdir(parents=True,exist_ok=True)
    vendor=Path(__file__).parent/'source_geometry'/name
    b=p.read_bytes() if p.exists() else (vendor.read_bytes() if vendor.is_file() else read(record['url']))
    assert hashlib.md5(b).hexdigest()==record['md5'],name
    if 'sha256' in record:assert hashlib.sha256(b).hexdigest()==record['sha256'],name
    p.write_bytes(b);print('VERIFIED',name,len(b),flush=True)
    return {'file':name,'source':record['url'],'author':'James Ray Cock','license':'CC0-1.0','md5':record['md5'],'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:records=list(pool.map(fetch,files.items()))
(root/'source_manifest.json').write_text(json.dumps({'source':'https://polyhaven.com/a/modular_factory_facade','author':'James Ray Cock','license':'CC0-1.0','license_url':'https://polyhaven.com/license','files':records},indent=2))
