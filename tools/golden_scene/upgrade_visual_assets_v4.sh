#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v4"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"
mkdir -p "$OUT/city_hd" "$TMP"
rm -rf "$TMP"/*

fetch() {
  local url="$1"
  local dest="$2"
  echo "FRONTLINE_VISUAL_V4_FETCH url=$url"
  curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V4/1.0" "$url" -o "$dest"
  test -s "$dest"
}

# CC0 ordinary urban house by drummyfish.
fetch "https://opengameart.org/sites/default/files/house.obj" "$TMP/ordinary_house.obj"
blender -b --python "$EXPORTER" -- --source "$TMP/ordinary_house.obj" --output "$OUT/city_hd/ordinary_house.glb"

# CC0 PBR-era Soviet apartment block by Mixazzz.
fetch "https://opengameart.org/sites/default/files/residential-building-lowpoly-apartment-block.zip" "$TMP/apartment.zip"
mkdir -p "$TMP/apartment"
unzip -q "$TMP/apartment.zip" -d "$TMP/apartment"
APT_SRC="$(find "$TMP/apartment" -type f \( -iname '*.blend' -o -iname '*.fbx' -o -iname '*.obj' -o -iname '*.gltf' -o -iname '*.glb' \) | sort | head -n 1 || true)"
if [[ -z "$APT_SRC" ]]; then
  echo "ERROR: CC0 apartment archive has no supported source model" >&2
  find "$TMP/apartment" -type f | sort >&2
  exit 31
fi
blender -b --python "$EXPORTER" -- --source "$APT_SRC" --output "$OUT/city_hd/apartment_block.glb"

{
  echo "# FRONTLINE Golden Scene V4 source checksums"
  sha256sum "$TMP/ordinary_house.obj"
  sha256sum "$TMP/apartment.zip"
} > "$OUT/VISUAL_V4_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v4_complete" <<'EOF'
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V4
ORDINARY_HOUSE_CC0=READY
APARTMENT_BLOCK_CC0=READY
EOF

test -s "$OUT/city_hd/ordinary_house.glb"
test -s "$OUT/city_hd/apartment_block.glb"
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V4_PASS"
