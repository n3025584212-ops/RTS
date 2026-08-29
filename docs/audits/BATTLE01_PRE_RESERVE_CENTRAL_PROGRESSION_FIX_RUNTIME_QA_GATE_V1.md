# BATTLE01 PRE-RESERVE CENTRAL PROGRESSION FIX RUNTIME QA GATE V1

TASK_ID=QA_BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_V1  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_RESULT=PASS

CURRENT_MAIN_AT_QA_START=b1446ba0ceba080e535be0a004bc87cba8e72d37  
VERIFIED_GAMEPLAY_COMMIT=439c415bebde407862838ccb7cc533186e86d014  
FIX_CONTRACT=docs/BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_CONTRACT_V1.md  
IMPLEMENTATION_AUDIT=docs/audits/BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_IMPLEMENTATION_AUDIT_V1.md  
PREVIOUS_INTEGRATED_GATE=docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V2.md

## 1. Independent Window 07 decision

Window 07 did not inherit the implementation PASS. The gate independently inspected:

- the frozen Option A design contract;
- the live Enemy AI inheritance chain;
- the new pre-first-Central Armor commitment controller;
- the focused progression smoke;
- the revised integrated player-flow evidence harness;
- the frozen Central/Reserve/Armor runtime values;
- Git provenance from the pre-implementation baseline through the verified gameplay commit and current main.

The previously confirmed blocker is closed at the product-semantics level:

PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION_BLOCKER=CLOSED

The repaired progression is now structurally:

`STAGING -> RECON / CONTACT -> INITIAL RED INFANTRY DEFENSE -> CENTRAL COMMITMENT -> FIRST PLAYER CENTRAL CAPTURE -> RESERVE / INDUSTRIAL UNLOCK -> RED ARMOR / REINFORCEMENT COUNTERATTACK -> RESUPPLY / PRESERVE / RESERVE DECISION -> INDUSTRIAL`

rather than the failed pre-fix sequence:

`CENTRAL COMMITMENT -> RED ARMOR FULL OBJECTIVE DENIAL -> RESERVE STILL LOCKED -> PROGRESSION COLLAPSE`.

## 2. Git provenance and gameplay binding

The verified gameplay SHA is exactly:

`439c415bebde407862838ccb7cc533186e86d014`

The current main SHA supplied to the gate is one audit-only commit ahead. Git comparison from `439c415...` to `b1446ba...` changes only:

- `docs/audits/BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_IMPLEMENTATION_AUDIT_V1.md`

Therefore current main has no post-validation gameplay/test drift.

From implementation-task start `40aad161aab899a2ecdf9c0bb23e901d454937c9` to the verified gameplay commit, the only production changes are:

- add `scripts/battle01/enemy_ai_pre_reserve_progression_controller.gd`;
- change `scripts/battle01/enemy_ai_route_mobility_controller.gd` to inherit that controller.

The remaining changes are the focused smoke and integrated evidence harness. No Formation resource, damage matrix, objective runtime, reserve runtime, route geometry, FOW, staging, supply, victory/defeat or other gameplay file changed.

EVIDENCE_PROVENANCE_PASS=YES  
POST_VALIDATION_GAMEPLAY_DRIFT=NO

## 3. Option A construction correctness

The live runtime chain is:

`Battle01.tscn -> BattleEnemyAIRouteMobilityController -> BattleEnemyAIPreReserveProgressionController -> BattleEnemyAILogisticsController -> base Enemy AI`

The pre-reserve controller applies only to `RED ARMOR-01` while the first real PLAYER Central capture has not completed.

Before first PLAYER Central capture, the Armor decision path bypasses the base `objective_emergency` Central-denial branch and uses a dedicated legal-target function. The following are not sufficient commit conditions:

- Central CAPTURING;
- Central CONTESTED;
- capture-capable BLUE merely inside Central core;
- RED Infantry engaged/dead;
- BLUE merely inside the broad Central defense area;
- Central progress increasing.

Inside the Central core, RED Armor may only engage a BLUE unit as direct self-defense when that unit is the recent direct attacker and Armor can return fire from its current position under normal range/LOS. This path does not issue movement into the objective core.

OBJECTIVE_EMERGENCY_BYPASS_CLOSED_PASS=PASS  
INFANTRY_DEAD_COMMIT_BYPASS_CLOSED_PASS=PASS  
PRE_FIRST_CAPTURE_ARMOR_GATE_PASS=PASS

## 4. Armor remains an active battlefield threat

The new gate does not disable Armor processing, weapons, intel or damage. It preserves:

- legal RED intel / CONTACT / CONFIRMED / LAST_KNOWN;
- direct self-defense;
- rear / RED Supply security;
- bounded local engagement;
- 350 pursuit leash;
- bounded LAST_KNOWN investigation;
- RETURN to the seeded reserve anchor.

A Central-core direct attacker can be fired upon only without converting the event into an objective-denial move mission. Non-Central direct/rear threats may be engaged under the existing legal-information and bounded-pursuit rules.

ARMOR_LOCAL_SELF_DEFENSE_PASS=PASS  
ARMOR_REAR_SECURITY_PASS=PASS  
PURSUIT_LEASH_PASS=PASS

## 5. First-capture boundary and post-capture restoration

The controller connects to the real Central `capture_completed` signal. On the first:

`capture_completed(new_owner=PLAYER)`

it permanently sets the first-capture phase flag, immediately arms the normal AI decision accumulator, and from the next normal decision opportunity RED ARMOR-01 returns to the inherited objective-emergency / local-counterattack behavior.

There is no artificial grace timer.

The focused post-capture scenario verifies both:

- counterattack state activation after first PLAYER capture;
- movement into Central and real Contest=YES behavior once the gate is released.

POST_FIRST_CAPTURE_COUNTERATTACK_PASS=PASS  
POST_FIRST_CAPTURE_ARMOR_CONTEST_PASS=PASS

## 6. Frozen contract preservation

The live `Battle01.tscn` retains:

`CentralBridgehead.capture_time = 15.0`

The live `player_war_flow.gd` still unlocks Reserve and Industrial only inside the first successful PLAYER Central `capture_completed` callback.

The live Armor resource remains:

- HP=280
- Damage=45
- Range=300
- Fire interval=1.50
- Ammo=16
- Capture=NO
- Contest=YES

No damage-matrix or Formation-value file changed in the implementation diff.

FIRST_CENTRAL_15S_PRESERVED_PASS=PASS  
RESERVE_TRIGGER_PRESERVED_PASS=PASS  
FORMATION_VALUES_PRESERVED_PASS=PASS  
DAMAGE_MATRIX_PRESERVED_PASS=PASS

## 7. Focused behavior evidence

The dedicated focused runtime script exercises the live Battle01 AI subtype and contains separate cases for:

- CAPTURING does not commit pre-capture Armor;
- CONTESTED does not commit pre-capture Armor;
- Infantry loss does not bypass the gate;
- direct self-defense remains legal;
- rear / Supply security remains legal;
- pursuit remains bounded;
- first PLAYER capture releases the gate;
- post-capture Armor resumes counterattack;
- post-capture Armor can physically contest Central.

Bound real-Godot implementation evidence records all focused markers PASS under `Godot 4.7.1.stable.official.a13da4feb`, with no blocking runtime error.

FOCUSED_PROGRESS_FIX_SMOKE=PASS

## 8. Integrated player-flow evidence

Window 07 inspected the revised `tests/battle01_integrated_player_flow_evidence.gd` rather than accepting its markers blindly.

The stale pre-fix requirement to destroy intact RED Armor before first Central capture was removed. The revised flow:

- uses normal staging and real Viewport input;
- clears the initial Infantry screen;
- does not directly kill/force/damage the pre-capture Armor;
- may maneuver Logistics / Infantry / Recon before commitment using normal Formation-aware orders;
- performs the first Central capture with a normal capture-capable Formation under the unchanged 15-second rule;
- uses the real Reserve HUD button after the actual capture unlock;
- only after that hinge reuses combat/kiting logic against the released Armor and counterattack.

No force-objective, seed override, time scale, teleport, HP mutation, direct kill, reserve shortcut or direct signal progression shortcut was added.

Bound exact-engine integrated evidence records:

RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_CENTRAL_CAPTURE=PASS  
RUN_A_RESERVE_UNLOCK=PASS  
RUN_A_RESERVE_ARMOR_COMMIT=PASS  
RUN_A_COUNTERATTACK_REACHED=PASS  
INTEGRATED_RUN_A_PASS=PASS

RUN_B_RESULT=VICTORY  
RUN_C_RESULT=VICTORY  
POSTURE_SEQUENCE_PASS=PASS_A_B_C_A  
DEFEAT_CONTROL_RESULT=PASS

The revised Run A is more actively staged than a minimal human straight-line opening, including early logistics/foot-formation repositioning. This does not invalidate this narrow fix gate because it uses ordinary Formation-level commands and no hidden/test authority, and the structural blocker itself is demonstrably removed. Whether the total Battle01 flow is sufficiently natural, route-distinct and commander-like remains intentionally subject to the required full integrated Vertical Slice rerun.

## 9. Regression evidence

The implementation audit binds real Godot 4.7.1 PASS results for the requested regression family:

ENEMY_AI_REGRESSION_PASS=PASS  
FOW_REGRESSION_PASS=PASS  
ROUTE_REGRESSION_PASS=PASS  
SEEDED_POSTURE_REGRESSION_PASS=PASS  
ADVANCE_HOLD_FIRE_REGRESSION_PASS=PASS  
RESUPPLY_REGRESSION_PASS=PASS  
OBJECTIVE_REGRESSION_PASS=PASS  
VICTORY_DEFEAT_REGRESSION_PASS=PASS

The additional staging, 3D foundation, formal roster, role/capture, logistics-flow and four CLI smoke runs are also recorded PASS in the implementation audit.

BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_EXACT_ENGINE_EVIDENCE

Window 07 does not have a local Godot executable/worktree in this execution environment and therefore does not claim a second independent engine reexecution.

INDEPENDENT_RUNTIME_REEXECUTION=UNAVAILABLE_IN_WINDOW_07  
BOUND_RUNTIME_EVIDENCE_SHA_MATCH=PASS

## 10. Product judgment

FIRST_CENTRAL_PROGRESSION_ROBUSTNESS=PASS

Reason: first Central no longer structurally requires eliminating the intact heavy reserve before earning the Reserve response. A real integrated normal-session Run A now crosses Central, unlocks/commits Armor Reserve and reaches the intended counterattack phase under unchanged capture/combat values.

BATTLE_TEMPO_COHERENCE=PASS

Reason: the escalation boundary is restored to `first Central secured -> Reserve/Industrial unlock -> Armor/reinforcement counterattack`, matching the frozen product arc.

COMMANDER_FANTASY_PASS=PASS

Reason: the repair itself removes the mandatory pre-hinge heavy-Armor micro-kite/aggro requirement. The accepted progression can be executed with Formation-level staging, movement, screening, capture and reserve commitment. Final holistic workload judgment remains for the integrated Vertical Slice gate.

COMBINED_ARMS_VALUE_PASS=PASS

Reason: Recon/FOW, IFV mobile fire support, capture-capable ground control, Logistics/sustain preparation and Reserve escalation remain distinct; the fix does not collapse roles or buff one Formation into an all-purpose solution. Final holistic combined-arms value remains for the integrated Vertical Slice gate.

## 11. Gate decision

CONSTRUCTION_CORRECTNESS=PASS  
PRODUCT_CORRECTNESS=PASS  
PLAYER_FLOW_CORRECTNESS=PASS  
EVIDENCE_SUFFICIENCY=PASS

QA_GATE_RESULT=PASS  
PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION_BLOCKER=CLOSED  
READY_FOR_INTEGRATED_VERTICAL_SLICE_RERUN=YES

NEXT_ACTION=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V1  
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_PERFORMANCE

Do not proceed directly to visual finalization. The previous integrated Vertical Slice gate was interrupted by exactly this blocker and must now be rerun on the new verified gameplay baseline.

BLOCKER=NONE  
ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
