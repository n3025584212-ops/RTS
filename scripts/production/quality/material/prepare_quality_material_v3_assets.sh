#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="$ROOT/assets/golden_scene/quality_material_v3"
SOURCE="$ROOT/assets/golden_scene/vehicles/mbt_abrams.glb"
ABRAMS_TOOL="$ROOT/scripts/production/quality/material/build_quality_abrams_v4.py"
HOUSE_TOOL="$ROOT/scripts/production/quality/material/build_quality_house_v5.py"
CC0_ABRAMS_TOOL="$ROOT/scripts/production/quality/material/convert_cc0_abrams_candidate.py"
CC0_ABRAMS_URL="https://opengameart.org/sites/default/files/abrams-tank.blend"
CC0_ABRAMS_BLEND="$RUNNER_TEMP/frontline-abrams-cc0.blend"

mkdir -p "$OUT"

blender -b --python "$ABRAMS_TOOL" --   --output "$OUT/mbt_abrams_static.glb"
blender -b --python "$HOUSE_TOOL" --   --output "$OUT/house_v5_static.glb"

curl -fL --retry 3 --retry-delay 2 "$CC0_ABRAMS_URL" -o "$CC0_ABRAMS_BLEND"
test -s "$CC0_ABRAMS_BLEND"
blender -b "$CC0_ABRAMS_BLEND" --python "$CC0_ABRAMS_TOOL" --   --output "$OUT/abrams_cc0_candidate.glb"

test -s "$OUT/mbt_abrams_static.glb"
test -s "$OUT/house_v5_static.glb"
test -s "$OUT/abrams_cc0_candidate.glb"

cat > "$OUT/.quality_material_v3_complete" <<EOF
QUALITY_MATERIAL_PROOF=V3
SOURCE=PROCEDURAL_HARD_SURFACE_ABRAMS_V4+HOUSE_V5+OPEN_GAME_ART_CC0_ABRAMS_CANDIDATE
REFERENCE_SOURCE=assets/golden_scene/vehicles/mbt_abrams.glb
PROCESS=DETERMINISTIC_BLENDER_HARD_SURFACE_BUILD
EOF

echo "FRONTLINE_MATERIAL_V3_ASSET_READY"
ls -lh "$OUT/mbt_abrams_static.glb" "$OUT/house_v5_static.glb" "$OUT/abrams_cc0_candidate.glb"
