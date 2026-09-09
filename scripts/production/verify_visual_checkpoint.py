"""Check evidence integrity and frozen-source isolation. This never approves visuals."""
from pathlib import Path
import hashlib,json,subprocess
from PIL import Image
root=Path(__file__).resolve().parents[2];out=root/'artifacts/visual_reset'
git=r'D:\GIT\Git\cmd\git.exe'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
capture=out/'river_town_actual_1920x1080.png';reference=root/'docs/visual_reference/approved_user_frame.png'
metrics=json.loads((out/'runtime_metrics.json').read_text())
assert Image.open(capture).size==(1920,1080)
assert [metrics['engine'][k] for k in ['major','minor','patch']]==[4,7,1]
assert metrics['renderer']=='forward_plus' and metrics['save_error']==0
log=(out/'runtime.log').read_text(encoding='utf8',errors='replace')
assert 'FRONTLINE_RIVER_TOWN_CAPTURED' in log
assert not any(x in log for x in ['SCRIPT ERROR:','SHADER ERROR:','ERROR:'])
frozen=['scripts/core','scripts/battle01','project.godot','scenes/battle01']
changed=subprocess.check_output([git,'-C',str(root),'diff','--name-only','HEAD','--',*frozen],text=True).splitlines()
assert not changed,changed
state={'integrity_check':'PASS','visual_acceptance':'FAIL_NOT_READY','rendered_dimensions':[1920,1080],'engine':metrics['engine']['string'],'renderer':metrics['renderer'],'runtime_errors':0,'frozen_tracked_files_changed':changed,'frozen_comparison':'isolated snapshot baseline 8fbd12f of source e909d17','performance_acceptance':'NOT_TESTED','native_capture_sha256':sha(capture),'reference_sha256':sha(reference),'scope':'Highest achievable main-frame quality; no further distant-detail work','remaining_visual_failures':['foreground building material quality','mud and water realism','foreground asset integration','lighting and atmosphere']}
(out/'verification.json').write_text(json.dumps(state,indent=2))
paths=[root/'scripts/production/river_town_visual_slice.gd',root/'scenes/production/RiverTownVisualSlice.tscn']
paths+=sorted((root/'scripts/production').glob('visual_slice_*.gdshader'))
manifest={'capture':{'path':str(capture.relative_to(root)),'sha256':sha(capture),'captured_at_utc':metrics.get('captured_at_utc'),'source':'Godot Viewport.get_texture().get_image(); pixels not edited'},'reference':{'path':str(reference.relative_to(root)),'sha256':sha(reference)},'runtime_sources':[{'path':str(p.relative_to(root)),'sha256':sha(p)} for p in paths]}
(out/'capture_manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps(state,indent=2))
