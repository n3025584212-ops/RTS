#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v5"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"

mkdir -p "$OUT/city_hq" "$OUT/nature_hq" "$TMP"
rm -rf "$TMP"/*

fetch() {
  local url="$1"
  local dest="$2"
  echo "FRONTLINE_VISUAL_V5_FETCH url=$url"
  curl -fL --retry 4 --retry-all-errors --retry-delay 2 -A "FRONTLINE-GoldenScene-V5/1.0" "$url" -o "$dest"
  test -s "$dest"
}

# CC0 high-quality low-poly urban pack using photo-derived textures + normals.
fetch "https://opengameart.org/sites/default/files/buildings_pack4.blend" "$TMP/buildings_pack4.blend"
blender -b --python "$EXPORTER" -- --source "$TMP/buildings_pack4.blend" --output "$OUT/city_hq/buildings_pack4.glb"

# CC0 Mid Poly Meadows: seven tree variants plus rocks/fences. Keep full glTF
# package so Godot retains relative texture/bin dependencies.
fetch "https://opengameart.org/sites/default/files/gltf_1.zip" "$TMP/meadows_gltf.zip"
rm -rf "$OUT/nature_hq"/*
unzip -q "$TMP/meadows_gltf.zip" -d "$OUT/nature_hq"

{
  echo "# FRONTLINE Golden Scene V5 source checksums"
  sha256sum "$TMP/buildings_pack4.blend"
  sha256sum "$TMP/meadows_gltf.zip"
} > "$OUT/VISUAL_V5_SOURCE_CHECKSUMS.txt"

cat > "$OUT/.visual_assets_v5_complete" <<'EOF'
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V5
BUILDINGS_PACK4_CC0=READY
MID_POLY_MEADOWS_CC0=READY
EOF

test -s "$OUT/city_hq/buildings_pack4.glb"
test "$(find "$OUT/nature_hq" -type f \( -iname '*.gltf' -o -iname '*.glb' \) | wc -l)" -gt 0
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V5_PASS"
