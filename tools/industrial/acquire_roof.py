from pathlib import Path
import json,urllib.request,hashlib,sys
root=Path(sys.argv[1]);root.mkdir(parents=True,exist_ok=True)
asset='corrugated_iron_03'
def read(url):
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'FRONTLINE-AssetBuild'}),timeout=120) as r:return r.read()
lock=Path(__file__).parent/'manifests/roof.json'
pinned=json.loads(lock.read_text()) if lock.exists() else None
d=None if pinned else json.loads(read('https://api.polyhaven.com/files/'+asset));records=[]
for key in ['diff','nor_gl','arm','disp']:
 r=next(v for v in pinned['files'] if v['file']==asset+'_'+key+'.jpg') if pinned else d[{'diff':'Diffuse','disp':'Displacement'}.get(key,key)]['4k']['jpg']
 url=r.get('source',r.get('url'));p=root/(asset+'_'+key+'.jpg');b=p.read_bytes() if p.exists() else read(url);assert hashlib.md5(b).hexdigest()==r['md5']
 if 'sha256' in r:assert hashlib.sha256(b).hexdigest()==r['sha256']
 p.write_bytes(b)
 records.append({'file':p.name,'source':url,'author':'Charlotte Baglioni','license':'CC0-1.0','md5':r['md5'],'sha256':hashlib.sha256(b).hexdigest()});print('ROOF_VERIFIED',key,flush=True)
(root/'source_manifest.json').write_text(json.dumps({'source':'https://polyhaven.com/a/'+asset,'author':'Charlotte Baglioni','license':'CC0-1.0','files':records},indent=2))
