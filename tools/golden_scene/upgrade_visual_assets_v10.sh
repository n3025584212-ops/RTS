#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v10"
mkdir -p "$OUT/city_hq3" "$TMP"
rm -rf "$TMP"/* "$OUT/city_hq3"/*
URL="https://opengameart.org/sites/default/files/buildings_pack3.blend"
echo "FRONTLINE_VISUAL_V10_FETCH url=$URL"
curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V10/1.0" "$URL" -o "$TMP/buildings_pack3.blend"
test -s "$TMP/buildings_pack3.blend"
blender -b "$TMP/buildings_pack3.blend" --python "$ROOT/tools/golden_scene/split_blend_largest_buildings.py" -- --out "$OUT/city_hq3" --max 8
COUNT="$(find "$OUT/city_hq3" -maxdepth 1 -type f -iname '*.glb' | wc -l)"
test "$COUNT" -ge 3
sha256sum "$TMP/buildings_pack3.blend" > "$OUT/VISUAL_V10_SOURCE_CHECKSUMS.txt"
cat > "$OUT/.visual_assets_v10_complete" <<EOF
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V10
BUILDINGS_PACK3_SPLIT_GLBS=$COUNT
SOURCE_LICENSE=CC0_1_0
SOURCE_PAGE=https://opengameart.org/content/buildings-pack-3
EOF
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V10_PASS split_buildings=$COUNT"
