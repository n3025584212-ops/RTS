#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_material_v3"
SOURCE="$ROOT/assets/golden_scene/vehicles/mbt_abrams.glb"
ABRAMS_TOOL="$ROOT/scripts/production/quality/material/build_quality_abrams_v4.py"
HOUSE_TOOL="$ROOT/scripts/production/quality/material/build_quality_house_v5.py"

mkdir -p "$OUT"

blender -b --python "$ABRAMS_TOOL" --   --output "$OUT/mbt_abrams_static.glb"
blender -b --python "$HOUSE_TOOL" --   --output "$OUT/house_v5_static.glb"


test -s "$OUT/mbt_abrams_static.glb"
test -s "$OUT/house_v5_static.glb"

cat > "$OUT/.quality_material_v3_complete" <<EOF
QUALITY_MATERIAL_PROOF=V3
SOURCE=PROCEDURAL_HARD_SURFACE_ABRAMS_V10+HOUSE_V5
REFERENCE_SOURCE=assets/golden_scene/vehicles/mbt_abrams.glb
PROCESS=DETERMINISTIC_BLENDER_HARD_SURFACE_BUILD
EOF

echo "FRONTLINE_MATERIAL_V3_ASSET_READY"
ls -lh "$OUT/mbt_abrams_static.glb" "$OUT/house_v5_static.glb"
