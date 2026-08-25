# BATTLE01 Seeded RED Defense Postures Runtime QA Gate V2

TASK_ID=RERUN_QA_BATTLE01_SEEDED_RED_DEFENSE_POSTURES_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_PASS
ENGINE=Godot 4.7.1.stable.official.a13da4feb
SOURCE_OF_TRUTH=GITHUB_MAIN
CURRENT_MAIN_AT_QA_START=0440927883a82c8ffb5a78fdb4aa17fe5cf3df2c
VERIFIED_GAMEPLAY_COMMIT=917d906ff2dbe01e0bec13cb8c2330a7972a23e4
SOURCE_FIX_AUDIT=docs/audits/BATTLE01_SEEDED_RED_DEFENSE_POSTURES_FIX_AUDIT_V1.md
PREVIOUS_QA_GATE=docs/audits/BATTLE01_SEEDED_RED_DEFENSE_POSTURES_RUNTIME_QA_GATE_V1.md

## Independent QA conclusion

Window 07 independently reviewed the final gameplay commit, the fix audit, the production seed resolver, the actual Battle01 restart path, the extended seeded-posture smoke, the frozen product/AI/Formation contracts, and the bound real-local Godot 4.7.1 runtime evidence.

All three blockers from the previous FAIL gate are closed.

### 1. Normal player seed path is now product-integrated

`BattleFormalCombatRoster` now uses a process-local static normal-run counter. The normal fallback is no longer a permanent seed 0: exported `battle01_seed=-1` means normal player sequencing. Only a real current Battle01 scene consumes the counter. The normal sequence is deterministic `0 -> 1 -> 2 -> 0`, mapping to `BRIDGE_LOCK -> VILLAGE_SCREEN -> SOUTH_SCREEN -> BRIDGE_LOCK`.

Battle01 Restart still calls `reload_current_scene()`, so the static counter survives scene replacement within the same game process. No system clock, frame count, unseeded randomness, hidden BLUE state, reserve choice or player command participates in posture selection.

Seed-resolution priority remains:
1. `force_seed_for_test()`;
2. `--battle01-seed=<int>`;
3. `BATTLE01_SEED`;
4. explicit editor/debug `battle01_seed >= 0`;
5. normal session run sequence.

These explicit override paths return before the normal-run counter is consumed, so they cannot be overwritten by or consume the normal replay sequence.

### 2. Both non-default RETURN anchors are explicitly runtime-proven

The focused smoke now separately exercises:
- VILLAGE_SCREEN RED INF-02 assigned/home anchor `(1060,660)`;
- SOUTH_SCREEN RED INF-02 assigned/home anchor `(1340,1380)`.

Each Formation is displaced, ordered through the real RETURN movement path, reaches HOLD, and terminates at the current posture anchor rather than any legacy fixed deployment.

### 3. Both alternate Supply rear slots are full-chain runtime-proven

Fresh VILLAGE_SCREEN and SOUTH_SCREEN Battle01 instances each prove:
- posture-specific rear slot is legal and walkable;
- depleted Armor is selected for resupply;
- Armor and Supply receive a legal rendezvous and both physically move;
- TRANSFERRING is reached;
- continuous 4.0-second transfer restores 50% max ammo;
- Supply charge falls from 2 to 1;
- HP is unchanged;
- destroying RED Supply removes remaining charges;
- no later resupply can start and combat ammo does not recover spontaneously.

The inherited RED logistics / FOW / EVADE contract remains covered by the dedicated resupply regression suite.

## Contract preservation

SEED_0=BRIDGE_LOCK
SEED_1=VILLAGE_SCREEN
SEED_2=SOUTH_SCREEN
SAME_SEED_SAME_POSTURE=PASS
FRAME_RATE_INDEPENDENT=PASS
NO_RUNTIME_RANDOM_POSTURE_CHANGE=PASS
POSTURE_PREMATCH_ONLY=PASS
POSTURE_LOCKED_AFTER_START=PASS

POSTURE_A_INF02=(1420,700)
POSTURE_B_INF02=(1060,660)
POSTURE_C_INF02=(1340,1380)
POSTURE_A_ARMOR=(1900,900)
POSTURE_B_ARMOR=(1900,1060)
POSTURE_C_ARMOR=(1900,700)
POSTURE_A_SUPPLY=(2180,1060)
POSTURE_B_SUPPLY=(2300,1180)
POSTURE_C_SUPPLY=(2260,1340)

ROSTER_UNCHANGED=PASS
ACTIVE_RED_ROSTER=INFx2;ARMORx1;SUPPLYx1
DORMANT_RED_ROSTER=INFx1;ARMORx1
DORMANT_REINFORCEMENT_PRESERVED=PASS

FOG_LIMITED_AI_PRESERVED=PASS
NO_HIDDEN_BLUE_DEPENDENCE=PASS
AI_STATE_COUNT_PRESERVED=7
AI_STATES=HOLD;MOVE;ENGAGE;INVESTIGATE;RETURN;SUPPORT;EVADE
INVESTIGATE_TIMEOUT_PRESERVED=4.0s
PURSUIT_LEASH_PRESERVED=350
CONTACT_CONFIRMED_LAST_KNOWN_SEMANTICS_PRESERVED=PASS

SUPPLY_CHARGES_PRESERVED=2
SUPPLY_RESTORE_FRACTION_PRESERVED=50_PERCENT_MAX_AMMO
SUPPLY_TRANSFER_DURATION_PRESERVED=4.0s
SUPPLY_HP_RESTORE_PRESERVED=NO
RED_SUPPLY_EVADE_PRESERVED=PASS

## Runtime evidence accepted

RUNTIME_EVIDENCE_SOURCE=LOCAL_GODOT_4_7_1
PROJECT_IMPORT=PASS
PROJECT_PARSE=PASS
REAL_BATTLE01_BOOT=PASS

NORMAL_PLAYER_SEED_PATH=PASS
NORMAL_REPLAY_SEQUENCE=PASS
NORMAL_REPLAY_WRAP=PASS
EXPLICIT_SEED_OVERRIDE=PASS
EXPLICIT_OVERRIDE_DOES_NOT_CONSUME_NORMAL_COUNTER=PASS

POSTURE_A=PASS
POSTURE_B=PASS
POSTURE_C=PASS
POSTURE_B_RETURN_ANCHOR=PASS
POSTURE_C_RETURN_ANCHOR=PASS
POSTURE_B_FULL_LOGISTICS_CHAIN=PASS
POSTURE_C_FULL_LOGISTICS_CHAIN=PASS

FRONTLINE_SEEDED_RED_DEFENSE_POSTURES_SMOKE=PASS
RESUPPLY_RED_LOGISTICS_REGRESSION=PASS
ENEMY_AI_REGRESSION=PASS
ROLE_CAPTURE_REGRESSION=PASS
FORMAL_ROSTER_REGRESSION=PASS
LOGISTICS_REGRESSION=PASS
3D_FOUNDATION_REGRESSION=PASS
BLOCKING_RUNTIME_ERRORS=NONE

## Player-facing product judgment

The three authored deployments are materially different in actual positions, not telemetry labels. Normal consecutive Battle01 replays now rotate through those deployments while the posture name remains hidden from the normal HUD. A player may learn that A/B/C are possible, but cannot use the immediately previous run as a reliable answer for current INF-02, Armor reserve or Supply rear placement. Recon / LOS / Contact / observation therefore has real repeat-play value for identifying the active posture.

PLAYER_FACING_POSTURE_DIFFERENCE=PASS
RECON_REPEAT_PLAY_VALUE=PASS

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS
PRODUCT_CORRECTNESS=PASS
EVIDENCE_SUFFICIENCY=PASS
QA_GATE_RESULT=PASS
READY_FOR_NEXT_STAGE=YES
BLOCKER=NONE

## Scope boundary

This PASS closes only the seeded RED opening-posture slice. It does not claim the full revised Battle01 is complete.

Still downstream:
- real North / Central / South route terrain / LOS / access differentiation;
- ADVANCE / HOLD FIRE command closure;
- pre-battle staging;
- final art / VFX after runtime playtest gates.

Do not reopen this posture gate unless a downstream change plausibly regresses it.

## Cleanup / active state

Window 07 made no production gameplay change. The only durable output of this rerun is this QA Gate V2. No ZIP, cache, duplicate checkout, large log bundle or screenshot bundle was retained.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Next action

NEXT_ACTION=IMPLEMENT_BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_V1
NEXT_OWNER=WINDOW_02_TECH_ARCHITECTURE
