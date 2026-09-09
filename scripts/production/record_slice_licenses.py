"""Record source identity and verify downloaded files; never grants visual approval."""
from pathlib import Path
import urllib.request,json,hashlib,shutil
root=Path(__file__).resolve().parents[2];external=root.parent/'external'
out=root/'docs/licenses/visual_slice';out.mkdir(parents=True,exist_ok=True)
def digest(path,kind='sha256'):
    h=hashlib.new(kind)
    with path.open('rb') as stream:
        while chunk:=stream.read(1024*1024):h.update(chunk)
    return h.hexdigest()
names=['fir_sapling_medium','island_tree_01','shrub_02','grass_bermuda_01','grass_medium_01','rock_moss_set_01','barrel_03','wooden_military_crate','worn_plaster_wall','roof_tiles_14','kloofendal_48d_partly_cloudy_puresky']
rows=[]
for name in names:
    source=external/(name+'.json');data=json.loads(source.read_text())
    shutil.copy2(source,out/(name+'_files_api.json'))
    row={'name':name,'publisher':'Poly Haven','source_page':'https://polyhaven.com/a/'+name,'license':'CC0-1.0','license_url':'https://creativecommons.org/publicdomain/zero/1.0/','files':[]}
    if name not in ['worn_plaster_wall','roof_tiles_14'] and 'gltf' in data:
        meta=data['gltf']['1k']['gltf'];files={name+'_1k.gltf':meta,**meta['include']}
        for rel,info in files.items():
            path=external/name/rel
            assert path.stat().st_size==info['size'],path
            assert digest(path,'md5').lstrip('0')==info['md5'].lstrip('0'),path
            row['files'].append({'path':rel,'source_url':info['url'],'sha256':digest(path),'publisher_md5':info['md5'],'size':path.stat().st_size})
        if name.startswith('grass_'):
            info=data['Alpha']['1k']['png'];path=root/'assets/visual_slice/surfaces'/(name+'_alpha_1k.png')
            assert digest(path,'md5').lstrip('0')==info['md5'].lstrip('0'),path
            row['files'].append({'path':str(path.relative_to(root)),'source_url':info['url'],'sha256':digest(path),'publisher_md5':info['md5'],'size':path.stat().st_size})
        row['modifications']='Blender GLB conversion, bounded decimation, original PBR textures retained. Grass uses the separate publisher Alpha map in a masked runtime shader because the source glTF color JPEG has no transparency. Complete plant and rock variants re-centered separately. Original multi-part crate stays assembled. Far foliage cards rendered from these meshes in Godot 4.7.1; these are runtime assets, not final-frame replacements.'
    elif 'hdri' in data:
        path=root/'assets/visual_slice/sky.hdr';info=data['hdri']['1k']['hdr']
        assert digest(path,'md5').lstrip('0')==info['md5'].lstrip('0')
        row['files'].append({'path':'sky.hdr','source_url':info['url'],'sha256':digest(path),'publisher_md5':info['md5']})
        row['modifications']='HDR file unchanged on disk. Runtime sky shader bounds the solar disk radiance for background and reflection passes; a separate DirectionalLight3D supplies direct sunlight.'
    else:
        for slot,suffix in [('Diffuse','diff'),('nor_gl','nor_gl'),('Rough','rough')]:
            info=data[slot]['1k']['jpg'];path=root/'assets/visual_slice/surfaces'/(name+'_'+suffix+'.jpg')
            assert digest(path,'md5').lstrip('0')==info['md5'].lstrip('0'),path
            row['files'].append({'path':str(path.relative_to(root)),'source_url':info['url'],'sha256':digest(path),'publisher_md5':info['md5']})
        row['modifications']='Textures unchanged on disk; shader tint, normal strength and world-space weathering at runtime.'
    rows.append(row)
for name in ['leafy_grass','aerial_mud_1','gravel_ground_01','asphalt_02','brick_wall_005','dirt_aerial_03','t_concrete_wall_002']:
    rows.append({'name':name,'publisher':'Poly Haven','source_page':'https://polyhaven.com/a/'+name,'license':'CC0-1.0','license_url':'https://creativecommons.org/publicdomain/zero/1.0/','provenance':'Existing e909d17 repository asset, documented in docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md','modifications':'New JPG copies limited to 1024 pixels via prepare_slice_textures.py; historical source files unchanged.'})
    if name=='aerial_mud_1':
        source=external/(name+'.json');data=json.loads(source.read_text());shutil.copy2(source,out/(name+'_files_api.json'))
        rows[-1]['additional_verified_files']=[]
        for slot,suffix in [('Displacement','disp'),('Rough','rough')]:
            info=data[slot]['1k']['png'];path=root/'assets/visual_slice/surfaces'/(name+'_'+suffix+'.png')
            assert digest(path,'md5').lstrip('0')==info['md5'].lstrip('0')
            rows[-1]['additional_verified_files'].append({'path':str(path.relative_to(root)),'source_url':info['url'],'sha256':digest(path),'publisher_md5':info['md5']})
license_snapshot=out/'polyhaven_license_20260908.html'
if not license_snapshot.exists():
    with urllib.request.urlopen(urllib.request.Request('https://polyhaven.com/license',headers={'User-Agent':'FrontlineVisualResearch/1.0'}),timeout=25) as response:
        license_snapshot.write_bytes(response.read())
else:
    print('REUSING_EXISTING_PUBLISHER_LICENSE_SNAPSHOT',license_snapshot.name)
manifest={'recorded_date':'2026-09-08','assets':rows,'abrams':{'source':'https://sketchfab.com/3d-models/abrams-m1a2-sepv3-eb6f5560198740269507e9948376414c','author':'dannzjs','license':'CC-BY-4.0','license_url':'https://creativecommons.org/licenses/by/4.0/','evidence':['abrams_license.txt','abrams_author_api_20260908.json','abrams_source_manifest.json'],'modifications':'Authored geometry retained, textures resized to maximum 1536 pixels and packed as GLB. Runtime material adaptation adds dust, mud, paint roughness and grime. No author endorsement implied.'}}
(out/'source_license_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print('SOURCE_LICENSE_RECORDS_VERIFIED',len(rows)+1)
