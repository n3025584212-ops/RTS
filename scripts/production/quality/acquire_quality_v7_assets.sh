#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_v7"
TMP="${RUNNER_TEMP:-/tmp}/frontline-quality-v7"
DOWNLOADER="$ROOT/tools/golden_scene/download_polyhaven_model.py"
TREE_CONVERTER="$ROOT/tools/golden_scene/decimate_tree_to_glb.py"
EXPORTER="$ROOT/tools/golden_scene/export_any_to_glb.py"

rm -rf "$TMP"
mkdir -p "$TMP/tree" "$TMP/factory" "$OUT"

python3 "$DOWNLOADER" --asset tree_small_02 --out-dir "$TMP/tree" | tee "$TMP/tree-download.log"
TREE_SOURCE="$(find "$TMP/tree" -maxdepth 1 -type f \( -iname '*.gltf' -o -iname '*.glb' \) | sort | head -n 1)"
test -n "$TREE_SOURCE"
blender -b --python "$TREE_CONVERTER" --   --source "$TREE_SOURCE"   --output "$OUT/tree_small_02_lod.glb"   --target-tris 90000

python3 "$DOWNLOADER" --asset modular_factory_facade --out-dir "$TMP/factory" | tee "$TMP/factory-download.log"
FACTORY_SOURCE="$(find "$TMP/factory" -maxdepth 1 -type f \( -iname '*.gltf' -o -iname '*.glb' \) | sort | head -n 1)"
test -n "$FACTORY_SOURCE"
blender -b --python "$EXPORTER" --   --source "$FACTORY_SOURCE"   --output "$OUT/modular_factory_facade.glb"

test -s "$OUT/tree_small_02_lod.glb"
test -s "$OUT/modular_factory_facade.glb"

cat > "$OUT/.quality_v7_assets_complete" <<EOF
QUALITY_SLICE=V7
TREE_SOURCE=https://polyhaven.com/a/tree_small_02
TREE_LICENSE=CC0
FACTORY_SOURCE=https://polyhaven.com/a/modular_factory_facade
FACTORY_LICENSE=CC0
EOF

echo "FRONTLINE_QUALITY_V7_ASSETS_READY"
ls -lh "$OUT/tree_small_02_lod.glb" "$OUT/modular_factory_facade.glb"
