# BATTLE01 INTEGRATED VERTICAL SLICE PLAYER FLOW QA GATE V4

TASK_ID=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V3  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_RESULT=REWORK_REQUIRED

START_MAIN_SHA=e2be3a2e1e63c6df6011ce477d86fcb947c7c99b  
VERIFIED_GAMEPLAY_COMMIT=439c415bebde407862838ccb7cc533186e86d014  
PREVIOUS_GATE=docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V3.md  
HUMAN_REASONABLE_EVIDENCE=docs/audits/BATTLE01_HUMAN_REASONABLE_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1.md  
HUMAN_REASONABLE_HARNESS=tests/battle01_human_reasonable_integrated_player_flow_evidence.gd

## 1. Independent Window 07 decision

Window 07 independently inspected the uploaded evidence package, its hashes, the human-reasonable harness, the evidence audit, current `main`, the frozen Formation resources, damage matrix, formal RED roster, Reserve entry rules, Enemy AI reinforcement activation and player IntelTracker behavior.

The evidence package is authentic relative to the supplied package manifest:

- ZIP SHA256=`213fb09eaa1e5baf512f0d747dff4e34db5b904f550f7dca195e1d609a449f34`
- harness SHA256=`f1c7f54e5026a3e1957d2aebe0bdb70746fe9e530f42c4090dc7fc93cc3b9f9c`
- evidence audit SHA256=`5f422acdaa3c232757bf25193576de3e9344fd046a3f93bc830c0d49e59f5b3f`
- package contains exactly the harness and evidence audit; no gameplay file is included.

The two evidence files have now been materialized onto formal GitHub `main` without changing gameplay.

The previous V3 gate remains historically valid as `BLOCKED`: at that time the only complete-success evidence depended on high-frequency scripted micro, Logistics screening and route-query-heavy validation. V4 does not overwrite V3.

New human-reasonable evidence is now sufficient to change the classification from evidence-only `BLOCKED` to product `REWORK_REQUIRED`.

The key new fact is not that every possible player strategy has been mathematically proven impossible. The key fact is that:

1. the repaired first-Central hinge is now repeatedly reachable using lower-frequency Formation-level play in all three seeded postures;
2. the same lower-frequency flow then repeatedly collapses at the same post-first-capture counterattack stage;
3. the only bound complete-victory harness still relies on exactly the high-frequency kiting / Logistics-screen techniques that the final product gate previously rejected as insufficient Commander-Fantasy evidence.

Therefore the current Battle01 baseline does not yet demonstrate a robust, human-reasonable complete Vertical Slice player flow.

QA_GATE_RESULT=REWORK_REQUIRED

## 2. Git provenance and no gameplay drift

The formal gameplay baseline remains the already verified Option-A baseline. The evidence package adds only:

- `tests/battle01_human_reasonable_integrated_player_flow_evidence.gd`
- `docs/audits/BATTLE01_HUMAN_REASONABLE_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1.md`

PRODUCT_GAMEPLAY_FILES_CHANGED=NO  
POST_VALIDATION_GAMEPLAY_DRIFT=NO  
FROZEN_OPTION_A_FIX_REOPENED=NO

The narrow pre-Reserve Central progression fix remains CLOSED.

## 3. Human-reasonable runtime results accepted

Bound exact-engine evidence reports:

RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK  
RUN_A_FIRST_CENTRAL_CAPTURE=PASS_AT_30.22S  
RUN_A_RESERVE=ARMOR  
RUN_A_LOGISTICS_BAIT_REQUIRED=NO  
RUN_A_HIGH_FREQUENCY_KITE_DEPENDENCY=NO

RUN_B_POSTURE=VILLAGE_SCREEN  
RUN_B_RESULT=TIMEOUT_AT_POST_CAPTURE_STALEMATE  
RUN_B_FIRST_CENTRAL_CAPTURE=PASS_AT_29.10S  
RUN_B_RESERVE=INFANTRY  
RUN_B_NORTH_INFORMATION_BEFORE_CENTRAL_COMMIT=PASS  
RUN_B_RECON_FULL_NORTH_LINK_TRAVERSAL=NOT_COMPLETED

RUN_C_POSTURE=SOUTH_SCREEN  
RUN_C_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK  
RUN_C_FIRST_CENTRAL_CAPTURE=PASS_AT_38.77S  
RUN_C_RESERVE=ARMOR  
RUN_C_SOUTH_CONTACT_GEOMETRY=PASS

DEFEAT_CONTROL_RESULT=PASS  
SOFTLOCK_FOUND=NO  
BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_EVIDENCE  
FOCUSED_REGRESSION_PASS=YES

These results materially strengthen the product diagnosis because all three normal postures cross the previously blocked first-Central hinge before failing later.

## 4. First-Central repair remains successful

The human-reasonable flow no longer requires destruction of the intact starting RED Armor before first Central capture.

Across A/B/C, the player can:

`STAGING -> RECON / CONTACT -> INITIAL INFANTRY DEFENSE -> CENTRAL COMMITMENT -> REAL 15S CENTRAL CAPTURE -> RESERVE UNLOCK`

with Formation-level orders and without the old Logistics deep-east Armor screen.

FIRST_CENTRAL_PROGRESSION_ROBUSTNESS=PASS  
PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION_BLOCKER=CLOSED

The current rework is therefore NOT authorization to roll back Option A.

## 5. Post-capture counterattack product blocker

The formal roster contains one active RED Armor plus one dormant reinforcement Armor and one reinforcement Infantry. The reinforcement entry is `(1380,900)`, adjacent to the Central battle area. Enemy AI activates the reinforcement Infantry + Armor immediately when Central is captured/lost, rather than waiting only for the 150-second fixed-time fallback.

The player Reserve, by contrast, enters from `WEST_REAR_ENTRY=(320,900)` only after the first completed PLAYER Central capture.

The frozen combat values are unchanged:

- RED / BLUE Armor: HP 280, Damage 45, Range 300, interval 1.50s;
- IFV: HP 180, Damage 24, interval 0.80s;
- Infantry: HP 100, Damage 14, interval 0.90s;
- IFV -> HEAVY multiplier 0.55;
- Infantry -> HEAVY multiplier 0.35;
- Armor -> LIGHT multiplier 1.35;
- Armor -> HEAVY multiplier 1.00;
- Armor -> SOFT multiplier 0.90.

This means the evidence audit's approximate per-shot values are directionally correct: IFV deals about 13 to heavy, Infantry about 5, Armor 45 to heavy; RED Armor deals about 61 to IFV and about 41 to soft targets.

Window 07 does NOT elevate the executor's simplified DPS calculation to a mathematical proof that no possible legal tactic can ever win. Terrain, LOS, arrival staggering, focus fire and alternative plans mean the absolute term `UNWINNABLE` is too strong as a theorem.

However, a final product gate does not require a theorem of impossibility before classifying rework. It requires credible evidence that a normal intended player flow works robustly. That evidence is absent:

- A natural central Formation-level plan reaches Central and then loses to the counterattack;
- a north-information plan reaches Central and then loses enough capture-capable power to stalemate;
- a south-maneuver plan reaches Central and then loses to the same escalation;
- the only complete-victory harness still requires high-frequency kiting and a Logistics screen.

POST_FIRST_CAPTURE_COUNTERATTACK_ROBUSTNESS=FAIL  
COUNTERATTACK_PLAYER_PRESSURE=EXCESSIVE_FOR_CURRENT_COMMANDER_LEVEL_FLOW  
PRODUCT_REWORK_CLASS=POST_CAPTURE_ESCALATION_BALANCE_AND_TIMING

## 6. Human-reasonable harness integrity audit

The new harness is materially better than the old stress harness:

- no damage-serial reactive kiting loop;
- no 0.8-second defensive position loop;
- no Logistics deep-east bait dependency in Run A;
- route plans are preselected by run index rather than reading the active posture to choose hidden enemy coordinates;
- player combat orders use CONFIRMED targets for actual engagement;
- navigation cadence is gated to approximately >=3 seconds per Formation;
- START, selection, MOVE, ADVANCE, HOLD FIRE, Reserve and most player actions use the real runtime input path.

But Window 07 also found three evidence-authority limitations that the local evidence audit incorrectly labels as fully clean:

### 6.1 CONTACT / LAST_KNOWN position leakage

`_public_knowledge()` copies `red.global_position` whenever intel state is anything other than UNSEEN.

That is not contract-correct for the final human-reasonable authority:

- CONTACT is not full precise truth;
- LAST_KNOWN must use the IntelTracker's stored static last-known position, not the RED Formation's current hidden position.

The formal `BattleIntelTracker` already exposes `get_last_known_position_for(target)` and renders LAST_KNOWN from its stored record. The harness should have used that authority.

HUMAN_EVIDENCE_CONTACT_POSITION_AUTHORITY=FAIL  
HUMAN_EVIDENCE_LAST_KNOWN_POSITION_AUTHORITY=FAIL

This defect gives the automated player extra information rather than depriving it of information. It therefore prevents a clean `NO_HIDDEN_TRUTH` certification, but it does not explain away the repeated post-capture failures as a player disadvantage.

### 6.2 Rear WITHDRAW is not fully real-input

For the deliberate rear regroup, `_order_withdraw(..., false)` calls `PlayerWarFlow.withdraw_selected(false)` directly because the current X-key player input prefers the forward rally once Central is secured.

This is an existing public product command authority and does not mutate gameplay, but it violates the task's stricter claim that every player action used `Input.parse_input_event()`.

HUMAN_EVIDENCE_ALL_ACTIONS_REAL_VIEWPORT_INPUT=PARTIAL

### 6.3 Timeout restart uses diagnostic scene reload

Run B times out without a result panel. The harness therefore uses `change_scene_to_packed()` to continue collecting Run C instead of a player-facing Restart button.

The A->B->C->A seed sequencing is useful diagnostic evidence, but this specific human-reasonable harness is not standalone proof of real-HUD restart across the timeout boundary. Real restart had already passed in earlier dedicated/integrated evidence.

HUMAN_EVIDENCE_POSTURE_SEQUENCE_AUTHORITY=PARTIAL_DIAGNOSTIC_RELOAD_ON_TIMEOUT

These limitations reduce the evidence from a perfect final PASS authority, but they do not require another evidence-only cycle before product rework. The product already fails the final player-flow objective under the lower-micro strategy, and the extra-information leak is player-favorable.

## 7. Route-value judgment

CENTRAL_ROUTE_VALUE_VISIBLE=PASS  
NORTH_ROUTE_VALUE_VISIBLE=PARTIAL_PASS  
SOUTH_ROUTE_VALUE_VISIBLE=PASS

Central now has a real fast direct flow to first capture.

North has materially better evidence than V3: north information is obtained before Central commitment, Infantry uses the north corridor, and vehicles do not use the foot-only geometry. Full Recon traversal of the dedicated link is not completed because the scout is destroyed under fire, so North remains `PARTIAL_PASS` rather than final full PASS.

South now changes actual first-contact geometry and takes longer to first Central capture, so its vehicle-maneuver / tempo distinction is materially visible.

ROUTE_IDENTITY_PLAYER_VALUE_PASS=PARTIAL_PASS_BLOCKED_BY_NORTH_FULL_TRAVERSAL_AND_GLOBAL_MATCH_FAILURE

## 8. Commander Fantasy / Combined Arms / Battle Tempo

Pre-capture, the new evidence is substantially aligned with the product baseline:

- Recon supplies information;
- Infantry supplies capture-capable ground control;
- IFV provides mobile direct fire;
- Logistics stays in a sustain role rather than acting as Armor bait;
- Reserve is selected only after Central.

The command workload no longer resembles the old damage-serial stress script. A/C report no micro-intensity warning; B's sub-2-second minimum comes from HOLD FIRE toggle followed by MOVE rather than a repeated combat loop.

However, the experience collapses immediately after the first major strategic success. The intended sequence is:

`FIRST CENTRAL -> RESERVE / SUSTAIN DECISION -> COUNTERATTACK RESPONSE -> INDUSTRIAL`

The observed lower-micro sequence is:

`FIRST CENTRAL -> COUNTERATTACK ARRIVES BEFORE RESERVE CAN EFFECTIVELY JOIN -> WITHDRAW / REGROUP -> DEFEAT OR STALEMATE`

That is a product-tempo and commander-fantasy failure even though it is no longer a hard software softlock.

COMMANDER_FANTASY_PASS=FAIL_POST_CAPTURE  
COMBINED_ARMS_VALUE_PASS=FAIL_POST_CAPTURE_ESCALATION  
BATTLE_TEMPO_COHERENCE=FAIL_POST_CAPTURE_ESCALATION_OVERLOAD  
RESERVE_DECISION_VALUE_PASS=FAIL_CURRENT_RESPONSE_WINDOW

## 9. Stability / frozen-contract judgment

FOCUSED_REGRESSION_PASS=PASS  
SOFTLOCK_PASS=PASS  
RUNTIME_STABILITY_PASS=PASS_IN_BOUND_EVIDENCE  
BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_EVIDENCE  
FROZEN_CONTRACT_PRESERVED=YES_EXCEPT_NO_NEW_GAMEPLAY_CHANGE_IN_THIS_EVIDENCE_TASK

No gameplay file was changed by the human-evidence task.

## 10. Final Gate judgment

CONSTRUCTION_CORRECTNESS=PASS  
FIRST_CENTRAL_PROGRESSION_ROBUSTNESS=PASS  
PRODUCT_CORRECTNESS=FAIL_POST_CAPTURE_COUNTERATTACK_ROBUSTNESS  
PLAYER_FLOW_CORRECTNESS=FAIL_POST_CAPTURE  
BATTLE_TEMPO_COHERENCE=FAIL  
COMMANDER_FANTASY_PASS=FAIL  
COMBINED_ARMS_VALUE_PASS=FAIL  
ROUTE_IDENTITY_PLAYER_VALUE_PASS=PARTIAL  
RESERVE_DECISION_VALUE_PASS=FAIL  
SOFTLOCK_PASS=PASS  
RUNTIME_STABILITY_PASS=PASS  
EVIDENCE_SUFFICIENCY=PASS_FOR_REWORK_CLASSIFICATION_NOT_FOR_FINAL_PASS

QA_GATE_RESULT=REWORK_REQUIRED  
READY_FOR_VISUAL_FINALIZATION=NO

## 11. Correct next owner

The blocker spans counterattack force composition/timing, Reserve response window and intended commander-level difficulty. Window 07 must not choose a hidden balance fix itself.

The correct next step is Window 01 design arbitration of one minimal post-capture escalation fix. Window 01 must decide whether the primary lever is, for example:

- reinforcement composition/timing;
- Reserve entry / response timing;
- counterattack sequencing;
- or a narrowly justified combat-balance lever.

This audit does NOT pre-authorize any of those options.

NEXT_ACTION=RESOLVE_BATTLE01_POST_CAPTURE_COUNTERATTACK_ROBUSTNESS_BLOCKER_V1  
NEXT_OWNER=WINDOW_01_GAME_DESIGN

BLOCKER=POST_FIRST_PLAYER_CENTRAL_CAPTURE_COUNTERATTACK_IS_NOT_ROBUSTLY_SURVIVABLE_UNDER_CURRENT_FORMATION_LEVEL_PLAYER_FLOW; EXISTING_COMPLETE_VICTORY_EVIDENCE_DEPENDS_ON_HIGH_FREQUENCY_KITING_AND_LOGISTICS_SCREENING  
ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
