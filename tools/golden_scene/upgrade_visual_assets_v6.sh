#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v6"
mkdir -p "$OUT/city_hq" "$TMP"
rm -rf "$TMP"/*

echo "FRONTLINE_VISUAL_V6_FETCH buildings_pack4.blend"
curl -fL --retry 4 --retry-all-errors --retry-delay 2 \
  -A "FRONTLINE-GoldenScene-V6/1.0" \
  "https://opengameart.org/sites/default/files/buildings_pack4.blend" \
  -o "$TMP/buildings_pack4.blend"
test -s "$TMP/buildings_pack4.blend"

rm -f "$OUT/city_hq/"*.glb
blender -b "$TMP/buildings_pack4.blend" \
  --python "$ROOT/tools/golden_scene/split_blend_buildings_to_glb.py" \
  -- --out "$OUT/city_hq"

COUNT="$(find "$OUT/city_hq" -maxdepth 1 -type f -iname '*.glb' | wc -l)"
test "$COUNT" -ge 2
sha256sum "$TMP/buildings_pack4.blend" > "$OUT/VISUAL_V6_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v6_complete" <<EOF
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V6
BUILDINGS_PACK4_SPLIT_GLBS=$COUNT
SOURCE_LICENSE=CC0_1_0
EOF
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V6_PASS split_buildings=$COUNT"
