# Gate D1 Evidence Record — MINIMUM_COMBAT_CHAIN — 2026-09-20

STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT
PARENT=Gate B (MINIMUM_ARMORED_UNIT_INTEGRATION, PASS) — D1 extends the integrated chain with the validated combat cycle
BRANCH=product/frontline-high-fidelity-slice-v1
ENGINE=Godot 4.7.1-stable official, Forward+, Vulkan 1.4.323 (Intel UHD Graphics), 1920x1080, capture_view=gate_b

## What was integrated

- `scripts/production/river_town_hostile_target.gd` — static RED armored target: a second real
  `abrams.glb` with the same armor-shader treatment, red-shifted via the shader `paint_color`
  parameter; backed by a hidden RED `BattleFormation` so damage uses the validated matrix.
  Progressive paint charring driven by `health_changed`; full char at destruction.
- `scripts/production/river_town_armored_unit.gd` (extended) — `demo_issue_attack()` routes
  through the validated combat chain (`set_combat_target` -> `_update_combat` fire cycle:
  range 300 sim / 1.5 s reload / ammo consumption / damage matrix); `attack_fired` signal
  drives a 0.12 s tracer effect from muzzle to target. No proxy at any point.
- `tools/gate_d1_capture.gd` — committed evidence driver (state-driven snaps; no
  provenance gap this time).

## Evidence run (this directory + gate_d1_evidence.json)

- `FRONTLINE_GATE_D1_TARGET_READY role=TANK hp=280 sim=(335,280) world=(8.5,0.08,3.0)`
- `FRONTLINE_GATE_D1_ATTACK_ORDERED range_sim=72.1` (inside 300 sim range)
- Fire cycle: 7 shots x 45 damage (TANK vs TANK multiplier 1.0), 1.5 s interval,
  ammo 16 -> 9, target hp 280 -> 0, `FRONTLINE_GATE_D1_TARGET_DESTROYED`
- Media: `gate_d1_before_engagement.png` (both intact), `gate_d1_engaging.png`
  (red at 145 hp, ~48% charred, blue selection ring visible),
  `gate_d1_target_destroyed.png` (red fully charred)
- No visual regression: scene pipeline, house, village, lighting untouched; only the
  hostile unit's paint state changes.

## Known limitations (for the auditor)

1. The hostile is static and does not return fire (no combat target set on it) — a pure
   damage-chain demonstration, by design of the minimum gate.
2. LOS check is not exercised (no `BattleVisibilityField` bound; fire occurred over open
   ground). Visibility binding is future work.
3. Tracer effect lives ~0.12 s and may fall between captures at this scene weight;
   fire/damage progression is carried by the log lines and paint charring instead.
4. The two vehicles park ~7 m apart for the demo; no collision system exists yet.
