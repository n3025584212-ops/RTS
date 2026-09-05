#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v20"
EXPORTER="$ROOT/tools/golden_scene/export_baked_obj_to_glb.py"
SPLITTER="$ROOT/tools/golden_scene/split_blend_largest_buildings.py"
DEST="$OUT/city_v20"

mkdir -p "$DEST" "$TMP"
rm -rf "$TMP"/* "$DEST"/*

URL="https://opengameart.org/sites/default/files/houses_oga_0.zip"
curl -fL --retry 4 --retry-all-errors --retry-delay 2 \
  -A "FRONTLINE-GoldenScene-V20/1.0" "$URL" -o "$TMP/houses.zip"
test -s "$TMP/houses.zip"
mkdir -p "$TMP/src"
unzip -q "$TMP/houses.zip" -d "$TMP/src"

mapfile -t OBJS < <(find "$TMP/src" -type f -iname '*_baked.obj' | sort)
if [ "${#OBJS[@]}" -lt 6 ]; then
  echo "V20 expected six baked OBJ houses, found ${#OBJS[@]}" >&2
  exit 20
fi
count=0
for src in "${OBJS[@]}"; do
  out="$DEST/family_house_$(printf '%02d' "$count").glb"
  blender -b --python "$EXPORTER" -- --source "$src" --output "$out"
  count=$((count+1))
  [ "$count" -ge 6 ] && break
done

COUNT="$(find "$DEST" -maxdepth 1 -type f -iname '*.glb' | wc -l)"
test "$COUNT" -ge 3
sha256sum "$TMP/houses.zip" > "$OUT/VISUAL_V20_SOURCE_CHECKSUMS.txt"
cat > "$OUT/.visual_assets_v20_color_complete" <<EOF
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_RECOVERY=V20_COLOR_TEXTURED
FAMILY_HOUSE_GLBS=$COUNT
SOURCE_LICENSE=CC0_1_0
SOURCE_PAGE=https://opengameart.org/content/family-house-collection
EOF
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V20_PASS family_houses=$COUNT"
