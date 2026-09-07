#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_material_v3"
SOURCE="$ROOT/assets/golden_scene/vehicles/mbt_abrams.glb"
TOOL="$ROOT/tools/golden_scene/sanitize_static_glb.py"

mkdir -p "$OUT"

blender -b --python "$TOOL" --   --source "$SOURCE"   --output "$OUT/mbt_abrams_static.glb"   --quality-bevel

test -s "$OUT/mbt_abrams_static.glb"

cat > "$OUT/.quality_material_v3_complete" <<EOF
QUALITY_MATERIAL_PROOF=V3
SOURCE=assets/golden_scene/vehicles/mbt_abrams.glb
PROCESS=STATICIZE_ARMATURE_BAKE_HIERARCHY_FLATTEN_GROUND_QUALITY_BEVEL
EOF

echo "FRONTLINE_MATERIAL_V3_ASSET_READY"
ls -lh "$OUT/mbt_abrams_static.glb"
