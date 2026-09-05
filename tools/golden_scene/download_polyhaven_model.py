#!/usr/bin/env python3
import argparse, json, os, sys, urllib.parse, urllib.request

UA="FRONTLINE-GoldenScene-V15/1.0"

def fetch_json(url):
    req=urllib.request.Request(url,headers={"User-Agent":UA})
    with urllib.request.urlopen(req,timeout=60) as r:
        return json.load(r)

def download(url,path):
    os.makedirs(os.path.dirname(path),exist_ok=True)
    req=urllib.request.Request(url,headers={"User-Agent":UA})
    with urllib.request.urlopen(req,timeout=120) as r, open(path,"wb") as f:
        while True:
            b=r.read(1024*1024)
            if not b: break
            f.write(b)

def collect_urls(obj,path=()):
    out=[]
    if isinstance(obj,dict):
        if isinstance(obj.get("url"),str):
            out.append((path,obj))
        for k,v in obj.items():
            out.extend(collect_urls(v,path+(str(k),)))
    elif isinstance(obj,list):
        for i,v in enumerate(obj):
            out.extend(collect_urls(v,path+(str(i),)))
    return out

ap=argparse.ArgumentParser()
ap.add_argument("--asset",required=True)
ap.add_argument("--out-dir",required=True)
args=ap.parse_args()

data=fetch_json("https://api.polyhaven.com/files/"+urllib.parse.quote(args.asset))
cands=[]
for path,leaf in collect_urls(data):
    url=leaf["url"]
    ext=os.path.splitext(urllib.parse.urlparse(url).path)[1].lower()
    if ext in (".gltf",".glb"):
        score=0
        joined="/".join(path).lower()+" "+url.lower()
        if "1k" in joined: score+=1000
        if ext==".gltf": score+=100
        size=int(leaf.get("size") or 10**12)
        cands.append((-score,size,path,leaf))
if not cands:
    raise SystemExit("No glTF/GLB candidate in Poly Haven API response")
cands.sort(key=lambda x:(x[0],x[1]))
_,_,path,leaf=cands[0]
url=leaf["url"]
name=os.path.basename(urllib.parse.urlparse(url).path) or (args.asset+".gltf")
dst=os.path.join(args.out_dir,name)
download(url,dst)
print("FRONTLINE_V15_POLYHAVEN_SELECTED", "/".join(path), url, dst)

if dst.lower().endswith(".gltf"):
    with open(dst,"r",encoding="utf-8") as f:
        gltf=json.load(f)
    uris=[]
    for buf in gltf.get("buffers",[]):
        u=buf.get("uri")
        if u and not u.startswith("data:"): uris.append(u)
    for img in gltf.get("images",[]):
        u=img.get("uri")
        if u and not u.startswith("data:"): uris.append(u)
    for u in sorted(set(uris)):
        dep_url=urllib.parse.urljoin(url,u)
        dep_path=os.path.join(args.out_dir,urllib.parse.unquote(u))
        download(dep_url,dep_path)
        print("FRONTLINE_V15_DEP",dep_url,dep_path)

print(dst)
