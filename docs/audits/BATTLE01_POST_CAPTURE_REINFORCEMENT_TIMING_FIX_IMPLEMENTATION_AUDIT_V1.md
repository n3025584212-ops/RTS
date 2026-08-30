# Battle01 Post-Capture Reinforcement Timing Fix — Implementation Audit V1

## Contract Identification

```
TASK_ID=IMPLEMENT_BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_V1
EXECUTOR=GLM_ZCODE (continued from Codex handoff, CONTINUE_AND_CLOSE_BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_V1)
ENGINE=Godot 4.7.1.stable.official.a13da4feb
START_COMMIT=16313347655e0908f4bfe9437999ccbc2fcaf57b
FINAL_GAMEPLAY_COMMIT=7b95b16692cc935b924dba7fb0c4de636a204d51
PRIMARY_FIX_OPTION=A
POST_CAPTURE_DELAY_IMPLEMENTED=YES
POST_CAPTURE_DELAY_SECONDS=15.0
```

Production commits (already pushed before this audit):

- `858258e` Implement Battle01 post-capture reinforcement timing
- `62df095` Wire post-capture reinforcement timing into live Enemy AI
- `f50d24f` Add post-capture reinforcement timing focused smoke
- `7b95b16` Close Battle01 post-capture reinforcement timing fix (human evidence + logistics reinforcement assertions)

## Fix Semantics (Option A)

On the first PLAYER capture of Central (T=0):

- BLUE Reserve unlocks immediately; Industrial unlocks normally; the pre-first-capture RED Armor gate releases immediately (initial RED ARMOR-01 may counterattack from the next normal AI decision).
- RED reinforcement INF-01 and reinforcement ARMOR-01 stay dormant for the full 15.0s window (verified dormant through T=14.99, both activate together at T=15.0, exactly once).
- The legacy 150s fixed-time fallback remains and cannot preempt an active 15s delay window.

## Production Focused Smoke

`tests/battle01_post_capture_reinforcement_timing_fix_smoke.gd` — `FRONTLINE_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_SMOKE_PASS`:

```
INITIAL_RED_ARMOR_IMMEDIATE_COUNTERATTACK_PASS=PASS
REINFORCEMENT_INFANTRY_DELAY_PASS=PASS (REINFORCEMENT_INFANTRY_0_TO_14_99_DORMANT_PASS)
REINFORCEMENT_ARMOR_DELAY_PASS=PASS (REINFORCEMENT_ARMOR_0_TO_14_99_DORMANT_PASS)
FIXED_TIME_150S_FALLBACK_PASS=PASS (FIXED_TIME_150S_PRECAPTURE_ACTIVATION_PASS)
150S_CANNOT_PREEMPT_ACTIVE_DELAY_PASS=PASS (FIXED_TIME_150S_CANNOT_PREEMPT_ACTIVE_DELAY_PASS)
NO_DUPLICATE_REINFORCEMENT_PASS=PASS (PREACTIVE_150S_CAPTURE_NO_DUPLICATE_REINFORCEMENT_PASS)
```

Invariants preserved:

```
FIRST_CENTRAL_RULE_PRESERVED=YES
PRE_CAPTURE_ARMOR_GATE_PRESERVED=YES (PRE_CAPTURE_ARMOR_GATE_PRESERVED_PASS)
RESERVE_ENTRY_PRESERVED=YES
FORMATION_VALUES_PRESERVED=YES
DAMAGE_MATRIX_PRESERVED=YES
REINFORCEMENT_ROSTER_PRESERVED=YES (REINFORCEMENT_ROSTER_INF1_ARMOR1_PRESERVED_PASS)
```

## Human Evidence Authority Fixes

```
HUMAN_EVIDENCE_CONTACT_AUTHORITY_FIXED=YES
HUMAN_EVIDENCE_LAST_KNOWN_AUTHORITY_FIXED=YES
```

CONTACT never yields RED exact current positions; CONFIRMED may use legally observed positions; LAST_KNOWN reads only `_intel.get_last_known_position_for(red)` — `LAST_KNOWN -> red.global_position` and `CONTACT -> red.global_position` are prohibited and asserted against.

## Formal Human Rerun (fresh, this session)

Harness: `tests/battle01_human_reasonable_integrated_player_flow_evidence.gd`
Logs: `.godot/human_formal_stdout.log` / `.godot/human_formal_stderr.log` (stderr empty, no SCRIPT ERROR / Parse Error / runtime error)

```
RUN_A_FIRST_CENTRAL=PASS
RUN_A_POST_CAPTURE_SURVIVAL=PASS
RUN_A_COUNTERATTACK_RESOLVED=PASS

RUN_B_FIRST_CENTRAL=PASS
RUN_B_POST_CAPTURE_SURVIVAL=PASS

RUN_C_FIRST_CENTRAL=PASS
RUN_C_POST_CAPTURE_SURVIVAL=PASS

RESERVE_INFANTRY_REAL_FLOW_PASS=PASS
RESERVE_ARMOR_REAL_FLOW_PASS=PASS

FULL_VERTICAL_SLICE_VICTORY_PATH_PASS=PASS
FULL_VERTICAL_SLICE_VICTORY_RUN=C
```

Run C completed a full VICTORY (duration=111.04s; first_contact=4.56, central_capture=33.79, counterattack=48.86, reserve_use=34.77) via `SOUTH_SCREEN` / `SOUTH_MANEUVER`: Central -> Reserve -> immediate initial RED Armor pressure -> full 15s response window -> RED reinforcement second wave -> counterattack resolved -> Industrial -> VICTORY.

Other formal guards: `HUMAN_REASONABLE_POSTURE_SEQUENCE_A_B_C_A_PASS`, `HUMAN_CONTACT_AUTHORITY_PASS`, `HUMAN_LAST_KNOWN_AUTHORITY_PASS`, `HUMAN_RUN_A_NO_LOGISTICS_BAIT_PASS`, `HUMAN_FOW_NO_HIDDEN_RED_LEAK_PASS`, `HUMAN_SOFTLOCK_WATCHDOG_PASS`, `HUMAN_MICRO_INTENSITY_WARNING=NO`, `DEFEAT_CONTROL_RESULT=PASS` (Run D), `FRONTLINE_HUMAN_REASONABLE_FLOW_EVIDENCE_PASS`.

Evidence-sampling note (not a gameplay change): Industrial capture and Victory resolve in the same simulation frame; `_finalize_run_record()` backfills `industrial_capture` from the public objective final owner when the 0.25s observer tick missed it. Run C summary `industrial_contact=-1.00` reflects first-contact-at-industrial (captured on arrival), not the capture timestamp; `full_vertical_slice` uses the backfilled `industrial_capture`.

## Regression Suite (fresh, this session, all EXIT=0, 0 errors)

```
PRE_RESERVE_FIX_REGRESSION=PASS   (battle01_pre_reserve_central_progression_fix_smoke: FRONTLINE_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_SMOKE_PASS)
ENEMY_AI_REGRESSION=PASS          (battle01_enemy_ai_final_objective_smoke: AI_FINAL_OBJECTIVE_DETERMINISTIC_PASS; CI --battle01-ci-enemy-ai-smoke: FRONTLINE_ENEMY_AI_SMOKE_PASS)
REINFORCEMENT_REGRESSION=PASS     (battle01_post_capture_reinforcement_timing_fix_smoke; logistics-flow reinforcement 15s delay assertions: BRIDGEHEAD_RED_REINFORCEMENT_14_99_DORMANT_PASS / BRIDGEHEAD_RED_REINFORCEMENT_TRIGGER_PASS)
FOW_REGRESSION=PASS               (STAGING_FOW_NO_POSTURE_LEAK_PASS; HUMAN_FOW_NO_HIDDEN_RED_LEAK_PASS)
ROUTE_REGRESSION=PASS             (battle01_route_identity_terrain_los_smoke: FRONTLINE_ROUTE_IDENTITY_TERRAIN_LOS_SMOKE_PASS)
SEEDED_POSTURE_REGRESSION=PASS    (battle01_seeded_red_defense_postures_smoke: FRONTLINE_SEEDED_RED_DEFENSE_POSTURES_SMOKE_PASS)
ADVANCE_HOLD_FIRE_REGRESSION=PASS (battle01_advance_hold_fire_commands_smoke: FRONTLINE_ADVANCE_HOLD_FIRE_COMMANDS_SMOKE_PASS)
RESUPPLY_REGRESSION=PASS          (battle01_resupply_red_logistics_smoke: FRONTLINE_RESUPPLY_RED_LOGISTICS_SMOKE_PASS)
OBJECTIVE_REGRESSION=PASS         (battle01_role_capture_v2_smoke: FRONTLINE_ROLE_CAPTURE_V2_SMOKE_PASS)
VICTORY_DEFEAT_REGRESSION=PASS    (battle01_logistics_flow_smoke: FRONTLINE_LOGISTICS_FLOW_SMOKE_PASS; human Run C VICTORY + Run D DEFEAT_CONTROL_RESULT=PASS)
RESTART_REGRESSION=PASS           (battle01_pre_battle_staging_smoke: STAGING_RESTART_RETURNS_TO_STAGING_PASS; human A->B->C->A posture sequence with real scene reload: HUMAN_REASONABLE_POSTURE_SEQUENCE_A_B_C_A_PASS)
```

CI smokes: `--battle01-ci-enemy-ai-smoke`, `--battle01-ci-navigation-smoke` (FRONTLINE_NAVIGATION_SMOKE_PASS), `--battle01-ci-intel-combat-smoke`, `--battle01-ci-multi-command-smoke` — all clean.

Additional smokes re-run clean: `battle01_primary_ifv_move_advance_integration_smoke` (FRONTLINE_PRIMARY_IFV_MOVE_ADVANCE_INTEGRATION_SMOKE_PASS), `formal_combat_roster_smoke` (FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS), `battle01_3d_foundation_smoke` (FRONTLINE_3D_FOUNDATION_SMOKE_PASS).

## Environment Verification

```
Godot 4.7.1.stable.official.a13da4feb --version  -> OK
--headless --path . --import                     -> EXIT=0, 0 errors
--headless --editor --path . --quit              -> EXIT=0, 0 errors
Real Battle01 boot (--headless --quit-after 3000) -> EXIT=0, boot markers present
RUNTIME_ERRORS=NONE
```

## Result

```
RESULT=PASS
READY_FOR_WINDOW_07=YES
BLOCKER=NONE
KNOWN_LIMITATIONS=NONE (evidence-sampling backfill for same-frame Industrial capture/Victory is an observer fix, not a gameplay limitation)
```

No production gameplay files were modified in this closing pass; only the human-reasonable evidence harness and the logistics-flow reinforcement assertions were committed.
