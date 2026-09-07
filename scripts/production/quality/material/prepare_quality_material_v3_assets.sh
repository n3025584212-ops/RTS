#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_material_v3"
SOURCE="$ROOT/assets/golden_scene/vehicles/mbt_abrams.glb"
ABRAMS_TOOL="$ROOT/scripts/production/quality/material/build_quality_abrams_v4.py"
HOUSE_TOOL="$ROOT/scripts/production/quality/material/build_quality_house_v5.py"
HOUSE_V14_TOOL="$ROOT/scripts/production/quality/material/convert_cc0_house_v14.py"
HOUSE_V14_URL="https://opengameart.org/sites/default/files/NucesHouse.blend"
HOUSE_V14_BLEND="${RUNNER_TEMP:-/tmp}/frontline-nuces-house-v14.blend"

mkdir -p "$OUT"

blender -b --python "$ABRAMS_TOOL" --   --output "$OUT/mbt_abrams_static.glb"
blender -b --python "$HOUSE_TOOL" --   --output "$OUT/house_v5_static.glb"

curl -fL --retry 4 --retry-all-errors --retry-delay 2 \
  -A "FRONTLINE-MaterialProof-V14/1.0" "$HOUSE_V14_URL" -o "$HOUSE_V14_BLEND"
test -s "$HOUSE_V14_BLEND"
blender -b "$HOUSE_V14_BLEND" --python "$HOUSE_V14_TOOL" -- \
  --output "$OUT/house_cc0_v14.glb"

test -s "$OUT/mbt_abrams_static.glb"
test -s "$OUT/house_v5_static.glb"
test -s "$OUT/house_cc0_v14.glb"

cat > "$OUT/.quality_material_v3_complete" <<EOF
QUALITY_MATERIAL_PROOF=V3
SOURCE=PROCEDURAL_HARD_SURFACE_ABRAMS_V13+HOUSE_V5+CC0_NUCES_HOUSE_V14_CANDIDATE
REFERENCE_SOURCE=assets/golden_scene/vehicles/mbt_abrams.glb
PROCESS=DETERMINISTIC_BLENDER_HARD_SURFACE_BUILD
EOF

echo "FRONTLINE_MATERIAL_V3_ASSET_READY"
ls -lh "$OUT/mbt_abrams_static.glb" "$OUT/house_v5_static.glb" "$OUT/house_cc0_v14.glb"
