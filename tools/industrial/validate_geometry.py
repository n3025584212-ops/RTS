"""Numerical mesh validation after export/packaging; requires NumPy."""
import numpy as np
from pathlib import Path
import json,struct
root=Path(__file__).resolve().parents[2];reports=[]
for path in sorted((root/'assets/visual_slice/industrial_workshop').glob('repair_workshop_lod*.glb')):
 blob=path.read_bytes();n=struct.unpack_from('<I',blob,12)[0];g=json.loads(blob[20:20+n]);binary=blob[28+n:]
 def data(i):
  a=g['accessors'][i];v=g['bufferViews'][a['bufferView']];count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']];dtype={5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']]
  stride=v.get('byteStride',count*np.dtype(dtype).itemsize)
  return np.ndarray((a['count'],count),dtype=dtype,buffer=binary,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(stride,np.dtype(dtype).itemsize)).copy()
 result={'file':path.name,'nonfinite':0,'degenerate_triangles':0,'normal_length_error_max':0.,'tangent_length_error_max':0.,'triangle_count':0}
 for mesh in g['meshes']:
  for p in mesh['primitives']:
   a=p['attributes'];pos=data(a['POSITION']);normal=data(a['NORMAL']);tangent=data(a['TANGENT']);uv=data(a['TEXCOORD_0']);idx=data(p['indices']).reshape(-1,3)
   assert idx.min()>=0 and idx.max()<len(pos)
   result['nonfinite']+=sum(int(np.count_nonzero(~np.isfinite(v))) for v in [pos,normal,tangent,uv])
   points=pos[idx];area=np.linalg.norm(np.cross(points[:,1]-points[:,0],points[:,2]-points[:,0]),axis=1)*.5
   result['degenerate_triangles']+=int(np.count_nonzero(area<1e-12));result['triangle_count']+=len(idx)
   result['normal_length_error_max']=max(result['normal_length_error_max'],float(np.max(abs(np.linalg.norm(normal,axis=1)-1))))
   result['tangent_length_error_max']=max(result['tangent_length_error_max'],float(np.max(abs(np.linalg.norm(tangent[:,:3],axis=1)-1))))
 result['passed']=result['nonfinite']==0 and result['degenerate_triangles']==0 and result['normal_length_error_max']<.001 and result['tangent_length_error_max']<.001
 reports.append(result)
dest=root/'artifacts/industrial_workshop/geometry_validation.json';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(json.dumps(reports,indent=2));print(json.dumps(reports,indent=2))
raise SystemExit(0 if all(r['passed'] for r in reports) else 1)
