"""Remove zero-area exported faces and repair undefined tangent frames.
Does not alter any texture, UV, authored normal, nondegenerate face, or vertex position.
Some source bevel caps/decimated UV singularities need this after Blender export.
"""
from pathlib import Path
import numpy as np
import json,struct,sys
folder=Path(sys.argv[1]);reports=[]
for path in sorted(folder.glob('repair_workshop_lod*.glb')):
 blob=path.read_bytes();n=struct.unpack_from('<I',blob,12)[0];g=json.loads(blob[20:20+n]);binary=bytearray(blob[28+n:]);removed=0;fallbacks=0
 def arr(i):
  a=g['accessors'][i];v=g['bufferViews'][a['bufferView']];count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']];dtype={5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']];stride=v.get('byteStride',count*np.dtype(dtype).itemsize)
  return np.ndarray((a['count'],count),dtype=dtype,buffer=binary,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(stride,np.dtype(dtype).itemsize))
 for mesh in g['meshes']:
  for p in mesh['primitives']:
   a=p['attributes'];pos=arr(a['POSITION']);idx=arr(p['indices']);tri=idx.reshape(-1,3).copy();pts=pos[tri];area=np.linalg.norm(np.cross(pts[:,1]-pts[:,0],pts[:,2]-pts[:,0]),axis=1)*.5
   keep=tri[area>=1e-12].reshape(-1);removed+=len(tri)-len(keep)//3;idx[:len(keep),0]=keep
   g['accessors'][p['indices']]['count']=len(keep)
   if 'min' in g['accessors'][p['indices']]:g['accessors'][p['indices']]['min']=[int(keep.min())]
   if 'max' in g['accessors'][p['indices']]:g['accessors'][p['indices']]['max']=[int(keep.max())]
   tangent=arr(a['TANGENT']);normal=arr(a['NORMAL']);length=np.linalg.norm(tangent[:,:3],axis=1);bad=length<.5;fallbacks+=int(bad.sum())
   for i in np.where(bad)[0]:
    axis=np.eye(3)[np.argmin(abs(normal[i]))];v=np.cross(normal[i],axis);tangent[i,:3]=v/np.linalg.norm(v);tangent[i,3]=1
   length=np.linalg.norm(tangent[:,:3],axis=1);tangent[:,:3]/=length[:,None]
 jb=json.dumps(g,separators=(',',':')).encode();jb+=b' '*((-len(jb))%4);total=12+8+len(jb)+8+len(binary)
 path.write_bytes(struct.pack('<4sII',b'glTF',2,total)+struct.pack('<I4s',len(jb),b'JSON')+jb+struct.pack('<I4s',len(binary),b'BIN\0')+binary)
 reports.append({'file':path.name,'zero_area_faces_removed':removed,'undefined_tangents_rebuilt':fallbacks});print(reports[-1])
(folder/'export_sanitation.json').write_text(json.dumps(reports,indent=2))
build=folder/'build_report.json'
if build.exists():
 d=json.loads(build.read_text())
 for row,repair in zip(d['lods'],reports):
  row.setdefault('triangles_before_sanitation',row['triangles'])
  row['triangles']-=repair['zero_area_faces_removed']
 build.write_text(json.dumps(d,indent=2))
