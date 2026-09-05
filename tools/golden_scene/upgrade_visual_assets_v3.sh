#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"

mkdir -p "$OUT/pbr" "$OUT/hdri"

fetch() {
  local url="$1"
  local dest="$2"
  echo "FRONTLINE_VISUAL_V3_FETCH url=$url"
  curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V3/1.0" "$url" -o "$dest"
  test -s "$dest"
}

fetch "https://dl.polyhaven.org/file/ph-assets/Textures/png/1k/leafy_grass/leafy_grass_diff_1k.png" "$OUT/pbr/leafy_grass_diff_1k.png"
fetch "https://dl.polyhaven.org/file/ph-assets/Textures/png/1k/leafy_grass/leafy_grass_nor_gl_1k.png" "$OUT/pbr/leafy_grass_nor_gl_1k.png"
fetch "https://dl.polyhaven.org/file/ph-assets/Textures/png/1k/leafy_grass/leafy_grass_arm_1k.png" "$OUT/pbr/leafy_grass_arm_1k.png"
fetch "https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/hochsal_field_1k.hdr" "$OUT/hdri/hochsal_field_1k.hdr"

{
  echo "# FRONTLINE Golden Scene V3 visual source checksums"
  sha256sum "$OUT/pbr/leafy_grass_"*.png
  sha256sum "$OUT/hdri/hochsal_field_1k.hdr"
} > "$OUT/VISUAL_V3_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v3_complete" <<'EOF'
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V3
LEAFY_GRASS_CC0=READY
HOCHSAL_FIELD_HDRI_CC0=READY
EOF

echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V3_PASS"
