import json,struct,numpy as np
from pathlib import Path
root=Path(__file__).resolve().parents[2];reports=[]
p=root/'assets/visual_slice/industrial_workshop/repair_workshop_lod0.glb';b=p.read_bytes();n=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+n]);binary=b[28+n:]
def arr(i):
 a=g['accessors'][i];v=g['bufferViews'][a['bufferView']];c={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']];dt={5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']];return np.ndarray((a['count'],c),dtype=dt,buffer=binary,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(v.get('byteStride',c*np.dtype(dt).itemsize),np.dtype(dt).itemsize))
for m in g['meshes']:
 for p in m['primitives']:
  if g['materials'][p['material']]['name']!='Workshop_brick':continue
  pos=arr(p['attributes']['POSITION']);uv=arr(p['attributes']['TEXCOORD_0']);idx=arr(p['indices']).reshape(-1,3);pts=pos[idx];uvs=uv[idx];center=pts.mean(axis=1);cross=np.cross(pts[:,1]-pts[:,0],pts[:,2]-pts[:,0]);area=np.linalg.norm(cross,axis=1);du=uvs[:,1]-uvs[:,0];dv=uvs[:,2]-uvs[:,0];ua=abs(du[:,0]*dv[:,1]-du[:,1]*dv[:,0]);density=np.sqrt(ua/(area+1e-20));normal=cross/(area[:,None]+1e-20)
  for name,lo,hi in [('lower',.8,2.5),('upper',3.2,4.0),('gable',4.4,5.5)]:
   mask=(center[:,1]>lo)&(center[:,1]<hi)&(abs(center[:,2])<.05)&(abs(normal[:,2])>.95)&(area>.0005)
   median=float(np.median(density[mask]));assert abs(median-1/3)<.001,(name,median)
   reports.append({'region':name,'samples':int(mask.sum()),'median_uv_units_per_metre':median,'expected':1/3,'passed':True})
(root/'artifacts/industrial_workshop/texel_density_validation.json').write_text(json.dumps(reports,indent=2));print(json.dumps(reports))
