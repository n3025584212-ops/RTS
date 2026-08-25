# BATTLE01 Seeded RED Defense Postures Runtime QA Gate V1

TASK_ID=QA_BATTLE01_SEEDED_RED_DEFENSE_POSTURES_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_FAIL
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
CURRENT_MAIN_AT_QA_START=e588dd76c115dd56f491b416001649714410ff96
VERIFIED_GAMEPLAY_COMMIT=f64144ab955346357661e29ce4f973eb110455fe
SOURCE_IMPLEMENTATION_AUDIT=docs/audits/BATTLE01_SEEDED_RED_DEFENSE_POSTURES_IMPLEMENTATION_AUDIT_V1.md

## Independent QA conclusion

Window 07 independently reviewed the final gameplay commit, the implementation audit, the real seeded-posture smoke source, Battle01 startup wiring, Formal Combat Roster seed/posture implementation, and the inherited Enemy AI runtime contract.

Construction of the seeded posture layer is substantially correct: seed mapping is deterministic (`seed mod 3`), posture resolution occurs before roster/AI runtime initialization, the selected posture is locked, real starting positions differ, active/dormant roster counts remain frozen, and Enemy AI agent `home` / `assigned_anchor` values are initialized from each Formation's actual posture-selected starting position. The final SOUTH_SCREEN RED INF-02 anchor is aligned to `(1340,1380)` on the legal Navigation grid.

However this gate cannot pass for two independent reasons.

### 1. Product correctness blocker — normal player path is effectively seed 0

`BattleFormalCombatRoster` resolves seed in this order:

1. QA forced seed;
2. `--battle01-seed=<int>` command-line input;
3. `BATTLE01_SEED` environment input;
4. exported `battle01_seed` fallback.

The exported fallback is `0`. The current `Battle01.tscn` does not override it, and the normal `battle01.gd` startup path does not provide a varying reproducible run/session seed.

Therefore a normal player launch with no external QA/developer seed injection always resolves:

`seed=0 -> BRIDGE_LOCK`.

The implementation proves that A/B/C can exist when an external seed is supplied, but it does not yet make the normal repeat-play path vary among A/B/C. Consequently the product claim that a player replaying Battle01 cannot rely on the previous run's deployment memory is not currently true by default, and Recon's repeat-play value is not established for the normal player path.

This is a seeded-posture product integration issue, not the later North/Central/South terrain/LOS differentiation task.

### 2. Evidence sufficiency gaps in the current focused smoke

The real seeded-posture smoke strongly verifies deterministic selection, all three posture identities, frozen roster, real deployment differences, posture lock, hidden-BLUE independence, dormant reinforcement preservation and baseline logistics compatibility.

But the current source does not independently satisfy every explicit Window 07 acceptance requirement:

- `RED_POSTURE_RETURN_ANCHOR_PASS` is exercised only against SOUTH_SCREEN. The QA contract explicitly requires RETURN-to-current-anchor verification for both non-default VILLAGE_SCREEN and SOUTH_SCREEN.
- Logistics compatibility is exercised for VILLAGE_SCREEN and SOUTH_SCREEN only to the point that RED resupply can start and Supply can enter EVADE. It does not, in both alternate rear-slot postures, complete and verify the full 4-second transfer / finite charge consumption / Supply-destruction sustain-loss chain required by this QA contract.

These evidence gaps do not by themselves prove the production behavior is wrong, but they prevent `EVIDENCE_SUFFICIENCY=PASS` under the explicit gate requirements.

## Independent construction findings

SEED_MAPPING=PASS
SEED_0=BRIDGE_LOCK
SEED_1=VILLAGE_SCREEN
SEED_2=SOUTH_SCREEN
SAME_SEED_SAME_POSTURE=PASS_BY_RUNTIME_EVIDENCE
FRAME_RATE_INDEPENDENT=PASS_BY_CONSTRUCTION
NO_RUNTIME_RANDOM_POSTURE_CHANGE=PASS
POSTURE_PREMATCH_ONLY=PASS
POSTURE_LOCKED_AFTER_START=PASS

POSTURE_A_CONSTRUCTION=PASS
POSTURE_B_CONSTRUCTION=PASS
POSTURE_C_CONSTRUCTION=PASS
REAL_DEPLOYMENT_DIFFERENCE=PASS

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
DORMANT_REINFORCEMENT_PRESERVED=PASS
FOG_LIMITED_AI_PRESERVED=PASS
NO_HIDDEN_BLUE_DEPENDENCE=PASS
AI_STATE_COUNT_PRESERVED=7
INVESTIGATE_TIMEOUT_PRESERVED=4.0s
MAX_PURSUIT_DISTANCE_PRESERVED=350

HOME_ANCHOR_BINDING_CONSTRUCTION=PASS
SOUTH_SCREEN_RETURN_RUNTIME=PASS
VILLAGE_SCREEN_RETURN_RUNTIME=NOT_EXPLICITLY_PROVEN

RED_LOGISTICS_BASE_REGRESSION=PASS
VILLAGE_SCREEN_LOGISTICS_START_AND_EVADE=PASS
SOUTH_SCREEN_LOGISTICS_START_AND_EVADE=PASS
VILLAGE_SCREEN_FULL_4S_TRANSFER_AND_DESTRUCTION=NOT_EXPLICITLY_PROVEN
SOUTH_SCREEN_FULL_4S_TRANSFER_AND_DESTRUCTION=NOT_EXPLICITLY_PROVEN

BLOCKING_RUNTIME_ERRORS=NONE_REPORTED_BY_BOUND_RUNTIME_EVIDENCE

## Player-facing product judgment

The authored A/B/C deployments are materially different enough to create different opening reads when different seeds are actually supplied: INF-02 changes between North, forward North and South; Armor shifts between deep Central, South-offset and North/Central reserve; Supply uses distinct rear slots. This is a real deployment difference rather than telemetry-only labeling.

However the normal current Battle01 startup path has no varying reproducible seed source and falls back to seed 0. Therefore:

PLAYER_FACING_POSTURE_DIFFERENCE=PASS_CONDITIONAL_ON_DIFFERENT_SEEDS
RECON_REPEAT_PLAY_VALUE=FAIL_DEFAULT_PLAYER_PATH_ALWAYS_BRIDGE_LOCK

The later route-terrain/LOS differentiation remains a separate downstream task and is not required to correct this seeded-posture integration defect.

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS
PRODUCT_CORRECTNESS=FAIL
EVIDENCE_SUFFICIENCY=FAIL

QA_GATE_RESULT=FAIL
READY_FOR_NEXT_STAGE=NO
BLOCKER=DEFAULT_PLAYER_PATH_ALWAYS_SEED_0_AND_REQUIRED_NONDEFAULT_RUNTIME_EVIDENCE_INCOMPLETE

## Required correction boundary

RETURN_TO=WINDOW_04_AI_COMMAND

The correction must remain inside the seeded posture slice:

1. Ensure the normal player Battle01 run receives a non-constant reproducible pre-match seed source, without using hidden BLUE state, runtime tactical randomness, frame timing or unseeded randomness. If no authorized run/session seed source exists, return to Window 00 for the smallest product decision instead of inventing unrelated systems.
2. Add QA-only runtime proof that VILLAGE_SCREEN as well as SOUTH_SCREEN returns displaced units to the selected posture anchor.
3. Extend alternate-posture logistics QA so both VILLAGE_SCREEN and SOUTH_SCREEN prove the full finite resupply chain required by this gate, including real rendezvous, completed 4-second transfer/charge use and Supply-destruction sustain loss, while preserving EVADE/FOW behavior.
4. Re-run the focused seeded posture smoke and the relevant existing regression suite with real Godot 4.7.1.

Do not implement route terrain/LOS differentiation, ADVANCE/HOLD FIRE, pre-battle staging, new units, new economy, or final art/VFX as part of this correction.

## Cleanup / active state

Window 07 changed no production gameplay code and retained no ZIP, generated cache, duplicate checkout, large log bundle or screenshot bundle. This QA gate document is the only durable QA output.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Next action

NEXT_ACTION=FIX_BATTLE01_SEEDED_RED_POSTURE_PLAYER_SEED_AND_CLOSE_QA_GAPS_V1
NEXT_OWNER=WINDOW_04_AI_COMMAND
