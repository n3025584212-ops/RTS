# BATTLE01 HUMAN-REASONABLE INTEGRATED PLAYER FLOW EVIDENCE V1

TASK_ID=MATERIALIZE_BATTLE01_HUMAN_REASONABLE_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1  
OWNER=LOCAL_GODOT_EXECUTOR  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
EVIDENCE_STATUS=PRODUCT_PLAYER_FLOW_REWORK_REQUIRED

ENGINE=Godot 4.7.1.stable.official.a13da4feb  
START_COMMIT=e2be3a2e1e63c6df6011ce477d86fcb947c7c99b  
EVIDENCE_TEST_COMMIT=810bdf8 + this evidence commit  
PRODUCT_GAMEPLAY_FILES_CHANGED=NO

## 1. Executive verdict

A human-reasonable (formation-level, real-input, no-kite, no-exploit) integrated
player flow **successfully completes the entire pre-capture arc of Battle01 in
all three postures**, including the previously doubted pieces:

- real PRE-BATTLE STAGING with formation redeploys;
- Recon/contact/reconnaissance;
- combined-arms clearing of the initial Infantry screen;
- the real 15-second first-Central capture with a capture-capable Formation;
- Reserve unlock and HUD Reserve commitment;
- a single deliberate tactical WITHDRAW against the post-capture counterattack.

The same flow **cannot defeat the post-first-capture RED counterattack** (RED
ARMOR-01 + RED REINFORCEMENT ARMOR-01 + reinforcement Infantry) with
formation-level play on the frozen gameplay baseline. The old SYSTEM_STRESS
harness only won that phase with high-frequency kiting and a Logistics screen,
which this task forbids. The defeat is reproducible (identical traces across
runs v10/v12) and is explained by the frozen combat math.

RESULT=PRODUCT_PLAYER_FLOW_REWORK_REQUIRED  
BLOCKER=DESIGN_BALANCE_BLOCKER_POST_FIRST_CAPTURE_RED_COUNTERATTACK_UNWINNABLE_WITH_FORMATION_LEVEL_PLAY  
NEXT_ACTION=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V3  
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_PERFORMANCE

This artifact is runtime evidence only. `docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V3.md` remains unchanged and BLOCKED; no Visual Finalization authorization is created. Gameplay was not modified.

## 2. Baseline provenance

The formal upstream baseline `e2be3a2e` was transported as
`RTS-main.zip` (174 entries, ZIP64, testzip PASS) and applied over the local
clone (previous HEAD `723d223`). The resulting working tree was verified to be
the upstream `main` content:

- real content deltas vs the old local baseline are exactly: 2 modified
  (`scripts/battle01/enemy_ai_route_mobility_controller.gd` — `extends`
  changed to `BattleEnemyAIPreReserveProgressionController`; and the legacy
  integrated stress harness) + 7 new files (the pre-Reserve progression
  controller, its fix smoke, the fix contract, Gate V2/V3, fix implementation
  audit, fix runtime QA gate);
- no Formation values, damage matrix, capture duration, Reserve trigger, route
  geometry, FOW, staging or objective rules changed;
- the Option A pre-first-Central Armor commitment gate is present and wired
  (scene `EnemyAIController` -> `enemy_ai_route_mobility_controller.gd` ->
  `BattleEnemyAIPreReserveProgressionController`).

Local baseline sync commit: `810bdf8` ("Sync working tree to upstream main
e2be3a2e (zip transport)").

The dedicated fix regression
`tests/battle01_pre_reserve_central_progression_fix_smoke.gd` PASSES 8/8 on
this baseline (pre-capture CAPTURING/CONTESTED/Infantry-loss produce no Armor
denial; Armor local self-defense, rear security, pursuit leash, post-capture
counterattack and contest all pass).

BASELINE_ADOPTED=e2be3a2e_VIA_ZIP_TRANSPORT  
OPTION_A_FIX_PRESENT=PASS  
PRE_RESERVE_BLOCKER_REOPENED=NO

## 3. Evidence harness authority

New harness: `tests/battle01_human_reasonable_integrated_player_flow_evidence.gd`
(kept separate; `tests/battle01_integrated_player_flow_evidence.gd` remains as
the SYSTEM_STRESS_AUTOMATION).

Human-reasonable constraints enforced by construction:

- decisions read ONLY a `PLAYER_KNOWLEDGE_SNAPSHOT` (objective owner/contested/
  progress, public intel state per RED unit with positions included only for
  CONTACT/CONFIRMED/LAST_KNOWN, friendly HP/ammo/order/position, Reserve HUD,
  Supply HUD);
- every player action uses real `Input.parse_input_event()` (LMB select,
  Shift+LMB additive, RMB MOVE, Shift+RMB ADVANCE, H hold-fire toggle, X
  withdraw, F resupply, HUD Reserve buttons, START BATTLE, RESTART);
- `MIN_COMMAND_INTERVAL` per formation = 3.0s;
- attack targets are only CONFIRMED/CONTACT public positions; the game's
  ADVANCE targeting gate (CONFIRMED-only) is relied on for engagement;
- no damage-serial micro, no 0.8s loops, no posture reads for micro decisions
  (the run index selects the pre-planned route only), no hidden RED truth in
  decision code.

RUN_A_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK  
RUN_B_RESULT=TIMEOUT_AT_POST_CAPTURE_STALEMATE  
RUN_C_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK

## 4. Run A — BRIDGE_LOCK / CENTRAL_TEMPO

RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_PLAN=CENTRAL_TEMPO  
RUN_A_RESERVE=ARMOR  
RUN_A_STAGING_DURATION=0.04s  
RUN_A_TIME_TO_FIRST_CONTACT=1.48s  
RUN_A_TIME_TO_CENTRAL_CAPTURE=30.22s  
RUN_A_TIME_TO_COUNTERATTACK=30.22s  
RUN_A_TIME_TO_RESERVE_USE=30.22s  
RUN_A_TOTAL_DURATION=64.53s  
RUN_A_TERMINAL=FRONTLINE_DEFEAT

Flow (all formation-level, real input):

1. STAGING: real formation drags (Recon 740,560 / Infantry 700,1160 / IFV
   520,820 / Supply 340,1120) -> `HUMAN_ALL_BLUE_REAL_INPUT_REDEPLOY_PASS`,
   `HUMAN_RUN_A_STAGING_START_PASS`.
2. RECON: Recon MOVE to the central observation ridge; first public contact at
   1.48s.
3. ATTACK: combined-arms ADVANCE (IFV + Infantry) clears the initial RED
   Infantry screen (RED INF destroyed pre-capture).
4. CAPTURE: Infantry (capture-capable) walks into the Central core and performs
   the real 15-second uncontested capture; IFV covers from south-east
   (`CENTRAL_COVER_SOUTH`, deliberately outside the pre-capture Armor arc);
   Central ownership transfers at 30.22s.
5. COUNTERATTACK: Reserve ARMOR committed via real HUD button; the counterattack
   arrives before the Reserve can close; the player makes ONE deliberate
   tactical WITHDRAW to the west rear (a single decision, not damage-serial
   micro), re-groups with the Reserve, re-engages.
6. The re-engagement cannot win the 2-heavy-armor stand: IFV (capture-capable,
   priority-targeted) dies in seconds; remaining force collapses ->
   `FRONTLINE_DEFEAT` at 64.53s.

RUN_A_COMMAND_COUNT=24 (move=12 advance=10 withdraw=1 reserve=1)  
RUN_A_MAX_COMMANDS_10S=8  
RUN_A_AVG_SECONDS_BETWEEN_COMMANDS=2.66  
RUN_A_PER_FORMATION_MIN_INTERVAL=3.33s  
RUN_A_MICRO_INTENSITY_WARNING=NO  
RUN_A_LOGISTICS_BAIT_REQUIRED=NO  
RUN_A_NO_LOGISTICS_BAIT=PASS (Supply stayed behind the line; max Supply x
before Central capture ≈ 520, far below the 1100 audit threshold; its role was
SUSTAIN, never a front-line Armor lure)

RUN_A_FIRST_CENTRAL_HUMAN_REASONABLE=PASS (normal combined-arms clearing +
real 15s capture by a capture-capable Formation; no unit pre-entered the
Industrial rear)

## 5. Run B — VILLAGE_SCREEN / NORTH_INFORMATION

RUN_B_POSTURE=VILLAGE_SCREEN  
RUN_B_PLAN=NORTH_INFORMATION  
RUN_B_RESERVE=INFANTRY  
RUN_B_STAGING_DURATION=0.07s  
RUN_B_TIME_TO_FIRST_CONTACT=0.45s  
RUN_B_TIME_TO_CENTRAL_CAPTURE=29.10s  
RUN_B_TOTAL_DURATION=159.30s  
RUN_B_TERMINAL=TIMEOUT (post-capture stalemate; no capture-capable combat
power could re-secure the re-taken Central)

North-route evidence (real movement, not path-query-only):

- Recon: HOLD FIRE ON -> real north route (900,640 -> 1180,460 -> north
  observation ridge), fire_serial stays 0 during the whole transit
  (`HUMAN_RUN_B_HOLD_FIRE_NO_FIRE_PASS`);
- north information event: `HUMAN_B_NORTH_INFO t=1.5 source=RED INF-02
  pos=(1060,660)` (VILLAGE_SCREEN north flank confirmed by the scout);
- the player then commits Central: `HUMAN_B_CENTRAL_COMMIT t=4.0`
  (north info strictly before the commitment ->
  `HUMAN_RUN_B_NORTH_INFO_CHANGED_DECISION_PASS`);
- Infantry uses the north foot corridor (`HUMAN_RUN_B_INFANTRY_NORTH_VALUE_PASS`);
- IFV/Supply real movement paths never enter the north foot-only geometry
  (`HUMAN_RUN_B_VEHICLE_FOOT_LINK_REJECTED_PASS`);
- Central captured at 29.10s; the same post-capture counterattack wall then
  applies (TIMEOUT after the force lost its combat power).

RUN_B_COMMAND_COUNT=22 (move=9 advance=9 hold_fire=1 weapons_free=1 withdraw=1 reserve=1)  
RUN_B_MAX_COMMANDS_10S=8  
RUN_B_AVG_SECONDS_BETWEEN_COMMANDS=2.73  
RUN_B_PER_FORMATION_MIN_INTERVAL=1.40s  
RUN_B_MICRO_INTENSITY_WARNING=YES (flagged for 07 judgment; the sub-2s value is
the opening HOLD-FIRE toggle + immediate MOVE to the same Formation, i.e. a
fire-discipline state change, not combat micro; all navigation commands remain
>= 3.0s apart)

RUN_B_RECON_NORTH_TRAVERSED=NOT_COMPLETED (the scout was lost under
VILLAGE_SCREEN fire before finishing the link transit; recorded honestly as
combat reality - the information value and decision chain were still captured)  
RUN_B_INFORMATION_VALUE_VISIBLE=YES  
RUN_B_INFANTRY_NORTH_VALUE_VISIBLE=YES

## 6. Run C — SOUTH_SCREEN / SOUTH_MANEUVER

RUN_C_POSTURE=SOUTH_SCREEN  
RUN_C_PLAN=SOUTH_MANEUVER  
RUN_C_RESERVE=ARMOR  
RUN_C_STAGING_DURATION=0.05s  
RUN_C_TIME_TO_FIRST_CONTACT=8.17s (first contact in the SOUTH lane)  
RUN_C_TIME_TO_CENTRAL_CAPTURE=38.77s  
RUN_C_TOTAL_DURATION=76.25s  
RUN_C_TERMINAL=FRONTLINE_DEFEAT

South-route evidence (real movement affecting contact geometry):

- IFV ADVANCE and Supply MOVE genuinely travel the south vehicle lane
  (900,1360 -> 1320,1400 -> ...); the SOUTH_SCREEN posture's RED INF-02 at
  (1340,1380) makes first contact in the south at 8.17s, i.e. the southern
  approach changes the contact geometry versus the central/north runs
  (`HUMAN_RUN_C_SOUTH_CONTACT_GEOMETRY_PASS`);
- Central captured at 38.77s from the southern approach; the post-capture
  counterattack then defeats the force at 76.25s.

RUN_C_COMMAND_COUNT=32 (move=17 advance=13 withdraw=1 reserve=1)  
RUN_C_MAX_COMMANDS_10S=7  
RUN_C_AVG_SECONDS_BETWEEN_COMMANDS=2.35  
RUN_C_PER_FORMATION_MIN_INTERVAL=3.33s  
RUN_C_MICRO_INTENSITY_WARNING=NO

## 7. Posture sequence / defeat control

POSTURE_SEQUENCE=A->B->C->A PASS (real HUD RESTART used whenever a result panel
exists; the harness time-cap path uses a documented scene reload when no panel
exists)  
POSTURE_SEQUENCE_PASS=PASS  
DEFEAT_CONTROL_RESULT=PASS (natural defeat path, DEFEAT HUD, command freeze,
RESTART availability verified; 19.40s)

## 8. Human-reasonable judgment (per run)

For every run the decision layer is, by construction, restricted to public
knowledge; the six questions answer:

1. Hidden truth required? NO (decisions read only the public knowledge snapshot;
   RED HP/AI-state/posture/unseen-reinforcement truth never enters a decision).
2. High-frequency micro required? NO (>=3.0s per-formation navigation gate;
   max 8 commands in any 10s window; one WITHDRAW per run; no damage-serial
   reactions).
3. AI-exploit required? NO (no Logistics screen, no aggro displacement; the
   single withdrawal is a commander decision, not an exploit loop).
4. Fixed pixel-precise coordinates required? NO (waypoints are public map
   landmarks: objectives, named route guides, rally points; no enemy-exact
   coordinate scripting).
5. Formation-level commands dominant? YES (MOVE/ADVANCE/HOLD FIRE/WEAPONS FREE/
   WITHDRAW/RESUPPLY/RESERVE on Formations; command counts 22-32 per run).
6. Every major decision explainable from public battlefield information? YES
   (contact -> attack; screen cleared -> capture; counterattack + Reserve far ->
   single withdraw; Reserve closed -> re-engage; contain -> push).

## 9. Hidden-truth / dependency audit

PLAYER_DECISION_READS_HIDDEN_RED_POSITION=NO  
PLAYER_DECISION_READS_RED_AI_STATE=NO  
PLAYER_DECISION_READS_HIDDEN_POSTURE=NO  
PLAYER_DECISION_READS_UNSEEN_REINFORCEMENT=NO  
PIXEL_PRECISE_SCRIPT_DEPENDENCY=NO  
HIGH_FREQUENCY_KITE_DEPENDENCY=NO  
LOGISTICS_BAIT_REQUIRED=NO

(The evidence/observer layer may read RED truth for audit; the decision layer
cannot - enforced by the single knowledge-snapshot entry point.)

## 10. Route player value

CENTRAL_ROUTE_PLAYER_VALUE=PROVEN (fastest, direct exposure, quick logistics
turn; first capture in ~30s with no bait/kite)  
NORTH_ROUTE_PLAYER_VALUE=PARTIAL_PROVEN (foot-mobility information play proven:
north info obtained before the Central commitment, infantry north corridor,
vehicle rejection; full link transit not completed because the scout was lost
under fire - a combat outcome, not a route-value failure)  
SOUTH_ROUTE_PLAYER_VALUE=PROVEN (longer vehicle-stable approach, different
contact angle; first contact in the south changed the engagement geometry)

## 11. Commander fantasy / combined arms / tempo

COMMANDER_FANTASY_EVIDENCE=STRONG_PRE_CAPTURE (scout -> read defense -> choose
commitment -> combined-arms screen clear -> 15s capture -> Reserve decision ->
single withdraw -> counterattack; all Formation-level, explainable decisions)

COMBINED_ARMS_EVIDENCE=PARTIAL (Recon information, Infantry capture/ground
control, IFV mobile direct fire, Logistics sustain-only, Reserve counterattack
force all materially contributed pre-capture; post-capture the 2-armor stand
collapses the fantasy because no honest tactic wins it)

BATTLE_TEMPO_EVIDENCE=COHERENT_UNTIL_COUNTERATTACK (command workload and
decision phases are clean and commander-paced pre-capture; the post-capture
phase is unwinnable, not merely demanding)

PLAYER_DECISION_PHASES=STAGING -> RECON -> CONTACT -> CENTRAL_ATTACK ->
CENTRAL_CAPTURE -> COUNTERATTACK -> (blocked)

## 12. The blocker - post-first-capture counterattack balance

Empirically reproduced across runs (A: 64.53s defeat, C: 76.25s defeat, B:
post-capture stalemate timeout) and confirmed by the frozen combat math:

- RED counterattack force: RED ARMOR-01 (280 HP) + RED REINFORCEMENT ARMOR-01
  (280 HP) + reinforcement Infantry, converging on Central within seconds of the
  first capture (reinforcement spawn is at the Central entry; the Armor home is
  300 world units away), while the player's Reserve spawns at the far west and
  needs ~15s to arrive;
- BLUE anti-heavy DPS with all three combat Formations
  (IFV 13/0.8s + Reserve 45/1.5s + Infantry 5/0.9s) is ~51.75 HP/s -> 10.8s to
  destroy the 560 HP armor pool;
- RED armor DPS (61 vs IFV, 45 vs heavy, 41 vs soft per 1.5s) delivers
  60-81 HP/s against BLUE; BLUE's total combat HP pool (~480) is consumed in
  8-9s;
- the IFV is capture-capable, so RED priority-targeting kills it in ~1-2s of
  combined armor fire;
- the old SYSTEM_STRESS harness only won this phase with high-frequency kiting
  and a Logistics screen - both explicitly forbidden as human-reasonable
  requirements.

The Option A pre-capture gate is therefore correct and is NOT the blocker. The
blocker is the post-capture counterattack: the frozen starting force + one
Reserve cannot defeat two 280 HP heavy-armor units with formation-level play.

BLOCKER_CLASS=DESIGN_BALANCE_BLOCKER  
PHASE=POST_FIRST_PLAYER_CENTRAL_CAPTURE_COUNTERATTACK  
BLOCKER_NAME=POST_CAPTURE_2X280HP_ARMOR_STAND_UNWINNABLE_WITHOUT_KITING_OR_SCREEN_EXPLOITS

## 13. Product decision (per task sections 2/28/29)

The task's exit rule applies: the product only satisfies a human-reasonable flow
if gameplay is changed. Per the task the local executor STOPS here, keeps the
failure evidence, does NOT tune the harness further toward victory, and does NOT
modify gameplay. This finding is routed for product rework (Window 01) through
Window 07.

PRODUCT_GAMEPLAY_FILES_CHANGED=NO  
PRODUCT_PLAYER_FLOW_REWORK_REQUIRED=YES  
REWORK_ROUTE_TO=WINDOW_01_GAME_DESIGN (via WINDOW_07_INTEGRATION_QA_PERFORMANCE)

## 14. Stability / regression

SOFTLOCK_FOUND=NO  
BLOCKING_RUNTIME_ERRORS=NO  
FOCUSED_REGRESSION_PASS=YES

Focused regressions (real Godot 4.7.1 headless, --fixed-fps 60):

| Test | Result |
|---|---:|
| battle01_pre_battle_staging_smoke | PASS |
| battle01_tactical_overview_real_viewport_input_smoke | PASS |
| battle01_route_identity_terrain_los_smoke | PASS |
| battle01_pre_reserve_central_progression_fix_smoke | PASS |
| battle01_advance_hold_fire_commands_smoke | PASS |
| battle01_resupply_red_logistics_smoke | PASS |
| battle01_enemy_ai_final_objective_smoke | PASS |
| battle01_role_capture_v2_smoke | PASS |
| formal_combat_roster_smoke | PASS |
| battle01_3d_foundation_smoke | PASS |
| battle01_seeded_red_defense_postures_smoke | PASS |
| battle01_logistics_flow_smoke | PASS |

## 15. Frozen summary fields

RUN_A_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK  
RUN_A_HUMAN_REASONABLE=YES_UNTIL_POST_CAPTURE_COUNTERATTACK  
RUN_A_COMMAND_COUNT=24  
RUN_A_MAX_COMMANDS_10S=8  
RUN_A_LOGISTICS_BAIT_REQUIRED=NO

RUN_B_RESULT=TIMEOUT_AT_POST_CAPTURE_STALEMATE  
RUN_B_HUMAN_REASONABLE=YES_UNTIL_POST_CAPTURE_COUNTERATTACK  
RUN_B_NORTH_TRAVERSED=PARTIAL (scout lost under fire; info/decision chain proven)  
RUN_B_INFORMATION_VALUE=YES  
RUN_B_COMMAND_COUNT=22

RUN_C_RESULT=DEFEAT_AT_POST_CAPTURE_COUNTERATTACK  
RUN_C_HUMAN_REASONABLE=YES_UNTIL_POST_CAPTURE_COUNTERATTACK  
RUN_C_SOUTH_FLOW_VISIBLE=YES (south contact geometry proven)  
RUN_C_COMMAND_COUNT=32

POSTURE_SEQUENCE=PASS (A->B->C->A)  
DEFEAT_CONTROL=FAILURE_PATH_PASS (D: 19.40s, HUD/freeze/restart verified)

PLAYER_DECISION_READS_HIDDEN_RED_POSITION=NO  
PLAYER_DECISION_READS_RED_AI_STATE=NO  
PLAYER_DECISION_READS_HIDDEN_POSTURE=NO  
PLAYER_DECISION_READS_UNSEEN_REINFORCEMENT=NO

PIXEL_PRECISE_SCRIPT_DEPENDENCY=NO  
HIGH_FREQUENCY_KITE_DEPENDENCY=NO  
LOGISTICS_BAIT_REQUIRED=NO

CENTRAL_ROUTE_PLAYER_VALUE=PROVEN  
NORTH_ROUTE_PLAYER_VALUE=PARTIAL_PROVEN  
SOUTH_ROUTE_PLAYER_VALUE=PROVEN

COMMANDER_FANTASY_EVIDENCE=STRONG_PRE_CAPTURE_BLOCKED_POST_CAPTURE  
COMBINED_ARMS_EVIDENCE=PARTIAL_PRE_CAPTURE_PROVEN  
BATTLE_TEMPO_EVIDENCE=COHERENT_UNTIL_COUNTERATTACK

SOFTLOCK_FOUND=NO  
BLOCKING_RUNTIME_ERRORS=NO  
FOCUSED_REGRESSION_PASS=YES

READY_FOR_VISUAL_FINALIZATION=NO (unchanged; final judgment remains with
WINDOW_07_INTEGRATION_QA_PERFORMANCE)

BLOCKER=DESIGN_BALANCE_BLOCKER_POST_FIRST_CAPTURE_RED_COUNTERATTACK_UNWINNABLE_WITH_FORMATION_LEVEL_PLAY  
NEXT_ACTION=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V3  
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_PERFORMANCE
