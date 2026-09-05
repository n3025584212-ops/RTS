#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v2"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"

mkdir -p "$OUT/pbr" "$OUT/hdri" "$OUT/vehicles" "$TMP"
rm -rf "$TMP"/*

fetch() {
  local url="$1"
  local dest="$2"
  echo "FRONTLINE_VISUAL_V2_FETCH url=$url"
  curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V2/1.0" "$url" -o "$dest"
  test -s "$dest"
}

# Poly Haven assets are CC0. Keep 1K maps for this fixed 1920x1080 G0 proof.
fetch "https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/kloppenheim_05_1k.hdr" "$OUT/hdri/kloppenheim_05_1k.hdr"

download_pbr() {
  local id="$1"
  for suffix in diff nor_gl arm; do
    fetch "https://dl.polyhaven.org/file/ph-assets/Textures/png/1k/${id}/${id}_${suffix}_1k.png" "$OUT/pbr/${id}_${suffix}_1k.png"
  done
}

download_pbr grass_path_3
download_pbr dirt_aerial_03
download_pbr aerial_mud_1
download_pbr asphalt_02
download_pbr gravel_ground_01
download_pbr brick_wall_005
download_pbr t_concrete_wall_002

# CC0 Abrams model by Sketlux, OpenGameArt.
fetch "https://opengameart.org/sites/default/files/abrams-tank.blend" "$TMP/abrams-tank.blend"
blender -b --python "$EXPORTER" -- --source "$TMP/abrams-tank.blend" --output "$OUT/vehicles/mbt_abrams.glb"

{
  echo "# FRONTLINE Golden Scene V2 visual source checksums"
  sha256sum "$OUT/hdri/kloppenheim_05_1k.hdr"
  sha256sum "$OUT/pbr/"*.png
  sha256sum "$TMP/abrams-tank.blend"
} > "$OUT/VISUAL_V2_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v2_complete" <<'EOF'
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V2
POLY_HAVEN_CC0_PBR=READY
POLY_HAVEN_CC0_HDRI=READY
ABRAMS_CC0=READY
EOF

test -s "$OUT/vehicles/mbt_abrams.glb"
test -s "$OUT/hdri/kloppenheim_05_1k.hdr"
test -s "$OUT/pbr/grass_path_3_diff_1k.png"
test -s "$OUT/pbr/asphalt_02_diff_1k.png"

echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V2_PASS"
