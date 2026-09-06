#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_v10"
TMP="${RUNNER_TEMP:-/tmp}/frontline-quality-v10"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"

rm -rf "$TMP"
mkdir -p "$TMP/src" "$OUT"

URL="https://opengameart.org/sites/default/files/residential-building-lowpoly-apartment-block.zip"
curl -fL --retry 4 --retry-all-errors --retry-delay 2   -A "FRONTLINE-QualitySlice-V10/1.0" "$URL" -o "$TMP/residential.zip"
test -s "$TMP/residential.zip"
unzip -q "$TMP/residential.zip" -d "$TMP/src"

SOURCE=""
for ext in blend fbx obj gltf glb; do
  candidate="$(find "$TMP/src" -type f -iname "*.$ext" -printf '%s %p
' | sort -nr | head -n 1 | cut -d' ' -f2- || true)"
  if [[ -n "$candidate" ]]; then
    SOURCE="$candidate"
    break
  fi
done

if [[ -z "$SOURCE" ]]; then
  echo "V10 residential archive contains no supported 3D source" >&2
  find "$TMP/src" -maxdepth 3 -type f -print
  exit 41
fi

echo "FRONTLINE_QUALITY_V10_SOURCE $SOURCE"
blender -b --python "$EXPORTER" --   --source "$SOURCE"   --output "$OUT/residential_block.glb"

test -s "$OUT/residential_block.glb"
cat > "$OUT/.quality_v10_assets_complete" <<EOF
QUALITY_SLICE=V10
SOURCE=https://opengameart.org/content/residential-building-lowpoly-apartment-block
LICENSE=CC0
EOF

echo "FRONTLINE_QUALITY_V10_ASSET_READY"
ls -lh "$OUT/residential_block.glb"
