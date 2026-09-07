#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_v16"
TMP="${RUNNER_TEMP:-/tmp}/frontline-quality-v16"
DOWNLOADER="$ROOT/tools/golden_scene/download_polyhaven_model.py"
CONVERTER="$ROOT/tools/golden_scene/decimate_tree_to_glb.py"

rm -rf "$TMP"
mkdir -p "$TMP" "$OUT"

convert_asset() {
  local asset="$1"
  local output="$2"
  local tris="$3"
  local srcdir="$TMP/$asset"
  mkdir -p "$srcdir"
  python3 "$DOWNLOADER" --asset "$asset" --out-dir "$srcdir" | tee "$TMP/${asset}-download.log"
  local source
  source="$(find "$srcdir" -maxdepth 1 -type f \( -iname '*.gltf' -o -iname '*.glb' \) | sort | head -n 1)"
  test -n "$source"
  blender -b --python "$CONVERTER" -- \
    --source "$source" \
    --output "$OUT/$output" \
    --target-tris "$tris"
  test -s "$OUT/$output"
}

convert_asset shrub_01 shrub_01_lod.glb 60000
convert_asset shrub_02 shrub_02_lod.glb 42000
convert_asset shrub_03 shrub_03_lod.glb 18000
convert_asset grass_medium_02 grass_medium_02_lod.glb 70000
convert_asset weed_plant_02 weed_plant_02_lod.glb 14000

cat > "$OUT/.quality_v16_assets_complete" <<EOF
QUALITY_SLICE=V16_REBUILD
SHRUB_01=https://polyhaven.com/a/shrub_01
SHRUB_02=https://polyhaven.com/a/shrub_02
SHRUB_03=https://polyhaven.com/a/shrub_03
GRASS_MEDIUM_02=https://polyhaven.com/a/grass_medium_02
WEED_PLANT_02=https://polyhaven.com/a/weed_plant_02
LICENSE=CC0
PURPOSE=LOCAL_FINAL_ENVIRONMENT_ART
EOF

echo "FRONTLINE_QUALITY_V16_ASSETS_READY"
ls -lh "$OUT"/*.glb
