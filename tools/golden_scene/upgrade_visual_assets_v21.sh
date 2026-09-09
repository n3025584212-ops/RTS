#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSET_ROOT="$ROOT/assets/golden_scene"
ABRAMS_OUT="$ASSET_ROOT/quality_material_v3"
VFX_OUT="$ASSET_ROOT/vfx_v21"
ABRAMS_TOOL="$ROOT/scripts/production/quality/material/build_quality_abrams_v4.py"

mkdir -p "$ABRAMS_OUT" "$VFX_OUT"

# Deterministic hard-surface rebuild proven by the material-quality proof lane.
# This produces actual GLB geometry (tracks, optics, stowage, antennas, mud
# layers), not a runtime proxy around the rejected low-detail tank.
blender -b --python "$ABRAMS_TOOL" -- \
  --output "$ABRAMS_OUT/mbt_abrams_static.glb"

BASE="https://opengameart.org/sites/default/files"
for i in 1 2 3 4; do
  curl -fL --retry 4 --retry-all-errors --retry-delay 2 \
    -A "FRONTLINE-GoldenScene-V21/1.0" \
    "$BASE/smoke${i}.png" -o "$VFX_OUT/smoke${i}.png"
done
curl -fL --retry 4 --retry-all-errors --retry-delay 2 \
  -A "FRONTLINE-GoldenScene-V21/1.0" \
  "$BASE/explosion_atlas_512x512.png" -o "$VFX_OUT/explosion_atlas_512x512.png"

test -s "$ABRAMS_OUT/mbt_abrams_static.glb"
for f in "$VFX_OUT"/smoke{1,2,3,4}.png "$VFX_OUT/explosion_atlas_512x512.png"; do
  test -s "$f"
done

cat > "$ASSET_ROOT/.visual_assets_v21_complete" <<'EOF'
FRONTLINE_GOLDEN_VISUAL_ASSETS=V21
HQ_MBT=DETERMINISTIC_HARD_SURFACE_GLB_FROM_PROVEN_MATERIAL_PROOF
SMOKE_SOURCE=https://opengameart.org/content/smoke-vapor-particles
SMOKE_LICENSE=CC0
EXPLOSION_SOURCE=https://opengameart.org/content/explosion-particles-sprite-atlas
EXPLOSION_LICENSE=CC0
COMMERCIAL_USE=YES
REDISTRIBUTION=YES
EOF

echo "FRONTLINE_GOLDEN_VISUAL_ASSETS_V21_READY"
ls -lh "$ABRAMS_OUT/mbt_abrams_static.glb" "$VFX_OUT"/*.png
