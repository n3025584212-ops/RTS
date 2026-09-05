#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/assets/golden_scene/nature_real"
TMP="${RUNNER_TEMP:-/tmp}/frontline-golden-v15"
mkdir -p "$OUT" "$TMP/src"
rm -rf "$OUT"/* "$TMP/src"/*

python3 "$ROOT/tools/golden_scene/download_polyhaven_model.py" \
  --asset pine_tree_01 --out-dir "$TMP/src" | tee "$TMP/download.log"
SRC="$(tail -n 1 "$TMP/download.log")"
test -s "$SRC"

blender -b --python "$ROOT/tools/golden_scene/decimate_tree_to_glb.py" -- \
  --source "$SRC" \
  --output "$OUT/pine_tree_01_lod.glb" \
  --target-tris 110000

test -s "$OUT/pine_tree_01_lod.glb"
sha256sum "$OUT/pine_tree_01_lod.glb" > "$ROOT/assets/golden_scene/VISUAL_V15_SOURCE_CHECKSUMS.txt"
cat > "$ROOT/assets/golden_scene/.visual_assets_v15_complete" <<EOF
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
VISUAL_ASSET_UPGRADE=V15
POLYHAVEN_ASSET=pine_tree_01
LICENSE=CC0_1_0
TARGET_TRIS=110000
OUTPUT=nature_real/pine_tree_01_lod.glb
EOF
echo "FRONTLINE_GOLDEN_VISUAL_ASSET_V15_PASS"
