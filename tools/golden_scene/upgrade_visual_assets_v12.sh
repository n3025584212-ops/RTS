#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v12"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"
mkdir -p "$OUT/city_real" "$TMP"
rm -rf "$TMP"/* "$OUT/city_real"/*

HOUSE_URL="https://opengameart.org/sites/default/files/house_0.zip"
CHURCH_URL="https://opengameart.org/sites/default/files/75990_Church1Upload_blend.zip"

echo "FRONTLINE_V12_FETCH house"
curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V12/1.0" "$HOUSE_URL" -o "$TMP/house.zip"
echo "FRONTLINE_V12_FETCH church"
curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V12/1.0" "$CHURCH_URL" -o "$TMP/church.zip"

mkdir -p "$TMP/house" "$TMP/church"
unzip -q "$TMP/house.zip" -d "$TMP/house"
unzip -q "$TMP/church.zip" -d "$TMP/church"

HOUSE_SRC="$(find "$TMP/house" -type f \( -iname '*.obj' -o -iname '*.blend' \) | head -n 1)"
CHURCH_SRC="$(find "$TMP/church" -type f -iname '*.blend' | head -n 1)"
test -n "$HOUSE_SRC"
test -n "$CHURCH_SRC"

blender -b --python "$EXPORTER" -- --source "$HOUSE_SRC" --output "$OUT/city_real/ordinary_house_textured.glb"
blender -b --python "$EXPORTER" -- --source "$CHURCH_SRC" --output "$OUT/city_real/church_landmark.glb"

test -s "$OUT/city_real/ordinary_house_textured.glb"
test -s "$OUT/city_real/church_landmark.glb"

{
  echo "# FRONTLINE Golden Scene V12 source checksums"
  sha256sum "$TMP/house.zip"
  sha256sum "$TMP/church.zip"
} > "$OUT/VISUAL_V12_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v12_complete" <<EOF
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V12
ORDINARY_HOUSE_TEXTURED=READY
CHURCH_LANDMARK=READY
SOURCE_LICENSE=CC0_1_0
EOF
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V12_PASS"
