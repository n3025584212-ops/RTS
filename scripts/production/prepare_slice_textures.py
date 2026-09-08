"""Reduce source textures to coherent 1K PBR delivery; leave evidence PNGs untouched."""
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[2]
src=root/'assets/golden_scene/pbr';out=root/'assets/visual_slice/surfaces';out.mkdir(exist_ok=True)
for name in ['leafy_grass_diff','aerial_mud_1_diff','aerial_mud_1_nor_gl','gravel_ground_01_diff','asphalt_02_diff','brick_wall_005_diff','brick_wall_005_nor_gl','dirt_aerial_03_diff','t_concrete_wall_002_diff']:
    im=Image.open(src/(name+'_1k.png'));im.thumbnail((1024,1024),Image.Resampling.LANCZOS);im.convert('RGB').save(out/(name+'.jpg'),quality=94)
print('SLICE_TEXTURES_PREPARED')
