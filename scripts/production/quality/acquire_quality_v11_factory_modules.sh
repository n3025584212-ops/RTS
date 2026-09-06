#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_v11_factory"
TMP="${RUNNER_TEMP:-/tmp}/frontline-quality-v11-factory"
DOWNLOADER="$ROOT/tools/golden_scene/download_polyhaven_model.py"
SPLITTER="$ROOT/tools/golden_scene/extract_factory_facade_modules.py"

rm -rf "$TMP"
mkdir -p "$TMP/src" "$OUT"
rm -f "$OUT"/factory_module_*.glb

python3 "$DOWNLOADER" --asset modular_factory_facade --out-dir "$TMP/src" | tee "$TMP/factory-download.log"
SOURCE="$(find "$TMP/src" -maxdepth 1 -type f \( -iname '*.gltf' -o -iname '*.glb' \) | sort | head -n 1)"
test -n "$SOURCE"

blender -b --python "$SPLITTER" -- \
  --source "$SOURCE" \
  --out "$OUT" \
  --count 3

for i in 00 01 02; do
  test -s "$OUT/factory_module_${i}.glb"
done

cat > "$OUT/.quality_v11_factory_complete" <<EOF
QUALITY_SLICE=V11_SINGLE_ROW_SPLIT
SOURCE=https://polyhaven.com/a/modular_factory_facade
LICENSE=CC0
USAGE=SPATIALLY_SPLIT_MODULES_ONLY
WHOLE_FACADE_FORBIDDEN=YES
EOF

echo "FRONTLINE_QUALITY_V11_FACTORY_READY"
ls -lh "$OUT"/factory_module_*.glb
