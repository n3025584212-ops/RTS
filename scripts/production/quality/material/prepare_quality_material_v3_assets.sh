#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_material_v3"
SOURCE="$ROOT/assets/golden_scene/vehicles/mbt_abrams.glb"
TOOL="$ROOT/scripts/production/quality/material/build_quality_abrams_v4.py"

mkdir -p "$OUT"

blender -b --python "$TOOL" --   --output "$OUT/mbt_abrams_static.glb"

test -s "$OUT/mbt_abrams_static.glb"

cat > "$OUT/.quality_material_v3_complete" <<EOF
QUALITY_MATERIAL_PROOF=V3
SOURCE=PROCEDURAL_HARD_SURFACE_ABRAMS_V4
REFERENCE_SOURCE=assets/golden_scene/vehicles/mbt_abrams.glb
PROCESS=DETERMINISTIC_BLENDER_HARD_SURFACE_BUILD
EOF

echo "FRONTLINE_MATERIAL_V3_ASSET_READY"
ls -lh "$OUT/mbt_abrams_static.glb"
