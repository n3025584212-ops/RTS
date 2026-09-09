# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V24
INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V2.md
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V3.md
GPT_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V2.md
DECISION_HISTORY=docs/current/DECISION_LOG.md
SOURCE_OF_TRUTH=THIS_FILE

LEGACY_PERMANENT_WINDOW_SYSTEM=ABOLISHED
GPT_MULTI_WINDOW_COLLABORATION=ENABLED
GPT_WINDOW_COUNT=4
INDEPENDENT_WINDOW_PROJECT_STATES=NO
CODEX_SIMULATED_HUMAN_PLAY=INVALID_EVIDENCE
PLAYER_EXPERIENCE_GATE=AFTER_REPRESENTATIVE_SLICE_READINESS
TOY_MECHANIC_DEMO_AS_PRODUCT_EVIDENCE=REJECTED
SINGLE_DECISION_REDUCTION_AS_GAME_DEFINITION=REJECTED_AS_TOO_NARROW

---

## CURRENT_PHASE

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED

Discovery proceeds through a representative command-battle system rather than ultra-thin mechanic demos. Technical tests may verify behavior but cannot substitute for a representative RTS battle or later human product judgment.

---

## CURRENT_PRODUCT_QUESTION

QUESTION=
What interacting real-time command decisions and battle loop make FRONTLINE worth playing as a formation-level command game rather than as a conventional RTS with fewer units?

---

## ACCEPTED_TECHNICAL_FOUNDATION

M2_01_RUNTIME_SHELL=KEEP_AS_TECHNICAL_TOOLBOX
REAL_GODOT_4_7_1_VERIFY=PASS

CORE_V1_BATCH1_PR=#23
CORE_V1_BATCH1_MERGED=YES
CORE_V1_BATCH1_MERGE_COMMIT=74c40115b6942df07ffca14b81f2fdbb2261e7ab
CORE_V1_BATCH1_FINAL_REVIEW=PASS

Accepted Core includes FormationState, FormationTask, FormationAgent2D, TaskCommandService, FormationAutonomy, NavigationService and a minimal CombatResolver. Scenario-specific Battle01 identity remains outside Core.

PROTOTYPE_B_CORE_MIGRATION_PR=#27
PROTOTYPE_B_CORE_MIGRATION_MERGED=YES
PROTOTYPE_B_CORE_MIGRATION_COMMIT=09146d7bc351762cd6d9b48719015cd88e200063
HISTORICAL_PROTOTYPE_B_PR=#21 CLOSED_SUPERSEDED

Prototype B is a real consumer of the accepted Core. BLUE and RED task/movement execution share the same Core formation path and TaskCommandService. This remains technical integration evidence only.

---

## CURRENT_REPRESENTATIVE_BATTLE_BATCH1

PRODUCT_ISSUE=#20
IMPLEMENTATION_ISSUE=#29
REVIEW_ISSUE=#31
PR=#30
BRANCH=dev/prototype-b-representative-battle-content-v1
HEAD=9769196db09cc57e38db4d2c2fdea2445484a21d
PR_STATE=OPEN
PR_MERGED=NO
PR_MERGEABLE=YES
CORE_FILES_CHANGED=0

Batch 1 adds actual battle substance on top of accepted Core rather than another architecture pass:

### State-driven RED commander
- normal RED reaction is based on live sector control and BLUE-vs-RED combat power rather than the old 14-second target profile;
- RED begins with two committed formations and one genuine uncommitted reserve;
- RED can counter-commit or exploit according to battlefield state;
- maneuver/reserve retasking uses commitment locks so the opponent cannot oscillate every frame;
- RED task execution continues through the shared TaskCommandService and Core formation runtime.

### Limited BLUE commander support
- BLUE has two finite support missions;
- support requires sector choice and has active duration plus cooldown;
- support produces real RED FormationState HP/ammo effects plus temporary pressure suppression and stronger contact confirmation;
- support timing is a resource tradeoff rather than unlimited UI spam.

### Battlefield trend/readability
- sectors expose GAINING / LOSING / UNDER PRESSURE / ADVANTAGE / CONTESTED from live battle state;
- UI exposes current RED focus, reserve commitment state and remaining support;
- UI presents facts and does not prescribe a correct player answer.

Representative structure remains intact:
- 5 BLUE including ECHO reserve;
- 3 RED;
- 3 simultaneous sectors;
- retask, fallback/recovery, escalation and outcome/restart remain present;
- no Battle01 production restart;
- no economy/base-building expansion;
- no final roster/map/command freeze.

Verified on current head:
- FRONTLINE Prototype B Representative Battle Verify run 33741943494 = SUCCESS;
- Frontline Core Verify #256 / run 33741943657 = SUCCESS;
- Prototype B Core Migration Verify #5 / run 33741943773 = SUCCESS;
- old Core consumer regression = PASS;
- state-driven RED response = PASS;
- RED reserve commit through shared Core command = PASS;
- limited support real damage/suppression/no-spam/later-tradeoff coverage = PASS;
- battlefield trend state = PASS;
- bounded 900-frame Godot 4.7.1 runtime = PASS.

TECHNICAL_RESULT=PASS_PENDING_INDEPENDENT_REVIEW
PRODUCT_PASS=NO
HUMAN_PLAY_GATE=NOT_REACHED
MERGE=NO

---

## VISUAL_PRODUCTION_RESET

VISUAL_PRODUCTION_RESET=ACTIVE
VISUAL_RESET_DOC=docs/current/VISUAL_PRODUCTION_RESET_V1.md
ALL_PREVIOUS_VISUAL_TARGETS=DEPRECATED
PREVIOUS_VISUAL_TARGETS_HISTORICAL_ONLY=YES
NEW_VISUAL_AUTHORITY=APPROVED_GOLDEN_FRAME_V1
IMPLEMENTATION_GRADE_DESIGN_REQUIRED=YES
DESIGN_IMAGE_ALONE_INSUFFICIENT=YES
DESIGN_PACKAGE_MUST_BE_AGENT_EXECUTABLE=YES
GOLDEN_FRAME_V1_SPEC=docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md
GOLDEN_FRAME_V1_STATUS=APPROVED_IMPLEMENTATION_AUTHORITY
GOLDEN_FRAME_TARGET_RESOLUTION=1920x1080
GOLDEN_FRAME_USER_APPROVED=YES
GOLDEN_FRAME_APPROVAL_DATE=2026-09-05
G0_FEASIBILITY_ISSUE=#32
G0_PHASE1_RESULT=GODOT_4_7_1_RECOMMENDED_FOR_REAL_VISUAL_SPIKE
FINAL_ENGINE_LOCK=NO
RECOIL=FALLBACK_IF_GODOT_SCALE_OR_VISUAL_PROOF_FAILS
WARZONE2100=NOT_RECOMMENDED_AS_PRODUCTION_BASE
NEXT_G0_PROOF=REAL_ASSET_GODOT_GOLDEN_SCENE_SPIKE
G0_VISUAL_SPIKE_ISSUE=#33
GOLDEN_FRAME_LOCAL_SHA256=6c9305b89a5bb1839721f12c2ae8c2507fae4fc7d4fdbbdf130f6f1ecc113362
APPROVED_DESIGN_PACKAGE_IS_IMPLEMENTATION_CONTRACT=YES
SILENT_REPLACEMENT_WITH_BOXES_OR_UNRELATED_PLACEHOLDERS=FORBIDDEN
LOGIC_AND_VISIBLE_PRESENTATION_BUILD_TOGETHER=YES

By explicit user decision on 2026-09-04, all earlier FRONTLINE design/visual-target images are abolished as current implementation authority. They may remain archived as historical evidence only. The next visual production direction must start from a newly generated design image and becomes authoritative only after explicit user approval.

---

## ACCEPTED_DECISIONS

ACCEPTED:
- FRONTLINE remains a modern-warfare formation/platoon-level tactical command game project.
- High-APM unit micromanagement is not an assumed product goal.
- TECHNICAL_PASS != PRODUCT_PASS.
- Direct human play is decisive for product acceptance only after representative readiness.
- Codex/automation may perform technical verification but may not simulate or stand in for a human player.
- FRONTLINE must not be reduced to a toy mechanism demo or an arbitrary small number of boxes/formations for product evaluation.
- Representative readiness is systemic, not a fixed unit-count/map-size/minutes checklist.
- The player-facing battle must create sustained command load through interacting responsibilities, changing threats and continuing consequences.
- RTS Core V1 and the Prototype B Core migration are accepted technical foundations on main.
- Old North/Central/South Battle01 production remains unauthorized.
- One shared current state replaces permanent specialist/window states.

REOPENED_OR_NOT_PROVEN:
- incomplete information as the primary game core;
- Recon/Infantry/IFV/Armor as protected final roles;
- old Battle01 command set;
- old Battle01 map structure;
- Command & Response as the final core loop;
- formation autonomy as the final control solution;
- one isolated repeated decision as a sufficient game definition.

---

## EVIDENCE_MODEL

LAYER_1_TECHNICAL_VERIFICATION=
Tests/CI verify that the build runs and specified mechanics work. This is not player evidence.

LAYER_2_REPRESENTATIVE_COMMAND_BATTLE_READINESS=
The build must contain enough interacting RTS/tactical-battle substance that human judgment is meaningful, including multiple responsibilities, changing enemy action, local autonomy, battlefield information, committed versus uncommitted power, visible consequences, retasking, setbacks/escalation and a recognizable outcome/restart path.

Exact formation count, subordinate count, map dimensions, duration, mission fiction and command vocabulary remain soft choices.

LAYER_3_HUMAN_PRODUCT_EVIDENCE=
Only after representative readiness should the user judge command quality, workload, readability, engagement and whether FRONTLINE feels distinct from conventional RTS micromanagement.

---

## GPT_WINDOW_RUNTIME

WINDOW_00=ACTIVE
WINDOW_01=ACTIVE_IMPLEMENTATION_GRADE_DESIGN
WINDOW_02=ACTIVE_GOLDEN_SCENE_VISUAL_FIX
WINDOW_03=ACTIVE_INDEPENDENT_REVIEW_PR30

CURRENT_RUNTIME_REASON=
WINDOW_02 completed representative battle-content Batch 1 on PR #30 at `9769196db09cc57e38db4d2c2fdea2445484a21d`. All three Godot 4.7.1 workflows are green and no Core files changed. Because this is a substantive battle-content integration gate, WINDOW_03 now independently reviews PR #30 under Issue #31. WINDOW_02 does not begin Batch 2 until review integration unless the user explicitly authorizes parallel work.

WINDOW_00_STATE_WRITE_AUTHORITY=DEFAULT
WINDOW_01_02_03_STATE_WRITE_AUTHORITY=ONLY_IF_USER_OR_TASK_EXPLICITLY_DELEGATES
MANDATORY_WINDOW_HANDOFF_CHAIN=NO
DURABLE_RESULTS_OVER_CHAT_RECEIPTS=YES

---

## ACTIVE_HYPOTHESES

H1_COMMAND_LEVEL_PLAY=PLAUSIBLE_NOT_PROVEN
H2_ACTION_RESPONSE=PLAUSIBLE_NOT_PROVEN
H3_SINGLE_RIGHT_CLICK_MAINTAIN_PRESSURE=FAILED_REWORK_REQUIRED
H4_REPRESENTATIVE_SYSTEM_NEED=ACCEPTED_PROCESS_RULE
H5_STATE_DRIVEN_OPPOSITION_AND_LIMITED_SUPPORT=TECHNICALLY_IMPLEMENTED_PENDING_REVIEW

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
ACTIVE_ISSUE=#33
ACTIVE_ISSUE_URL=https://github.com/n3025584212-ops/RTS/issues/33

GOLDEN_SCENE_RESULT=FAIL_CONTINUE_FIXING
PREVIOUS_PARTIAL_PASS=REVOKED_BY_USER
REAL_ASSET_INTEGRATION=PASS
GODOT_4_7_1_IMPORT=PASS
FINAL_1920x1080_VISUAL=NOT_ACCEPTED
GOLDEN_FRAME_VISUAL_COMPLIANCE=NOT_PASSED
GOLDEN_SCENE_PR=#34_CLOSED_PREMATURE_REVIEW
GOLDEN_SCENE_PR34_STATE=CLOSED
GOLDEN_SCENE_MERGE=NO

PARALLEL_EXISTING_REVIEW=PR30_UNDER_ISSUE31
PARALLEL_REVIEW_AUTHORITY=WINDOW_03

Immediate goal:
Continue the existing real-asset Godot Golden Scene from its latest branch state and raise visual fidelity substantially toward Approved Golden Frame V1. The previous PARTIAL_PASS was explicitly revoked by the user because the frame remained visibly low-poly, procedural and prototype-like. Technical import/runtime success does not override visual failure.

USER_VISUAL_REVIEW_OVERRIDE:
- low-poly toy-like vehicle/building/vegetation fidelity = BLOCKING;
- flat/single-material terrain = BLOCKING;
- simplified river banks/roads/bridge = BLOCKING;
- insufficient realistic lighting/shadow/atmospheric depth = BLOCKING;
- weak procedural VFX = BLOCKING;
- insufficient battle damage/decal/detail density = BLOCKING;
- battlefield finishing below HUD finishing = BLOCKING.

NEXT_VISUAL_PASS=HIGHER_FIDELITY_ASSET_AND_PBR_PASS

---

## BLOCKERS

CURRENT_PRODUCT_BLOCKERS:
1. FRONTLINE has not yet passed representative command-battle readiness for direct human judgment.
GOLDEN_SCENE_VISUAL_BLOCKER=APPROVED_GOLDEN_FRAME_V1_NOT_YET_REPRODUCED_IN_ENGINE
2. Ordinary combat remains primarily sector aggregate attrition rather than a convincing formation-vs-formation local engagement process.
3. The interaction among command responsibilities, formation autonomy, enemy reaction, information, combat, support and reserves remains unproven as a product experience under sustained battle load.
4. The game must demonstrate that higher-level command reduces babysitting without making the player passive.

CURRENT_TECHNICAL_INTEGRATION_BLOCKER:
- PR #30 requires WINDOW_03 independent review under Issue #31 before merge unless the user explicitly overrides.

NEXT_BUILD_HYPOTHESIS:
Formation-vs-formation local engagement — contact, suppression, damage, disengagement, ammunition/endurance and state-driven retasking pressure — is the leading candidate for Batch 2 after Batch 1 acceptance. This is not yet frozen scope and should not be required by review unless a concrete PR #30 defect depends on it.

---

## NEXT_DECISION

NEXT=WINDOW_02_CONTINUE_GOLDEN_SCENE_HIGH_FIDELITY_ASSET_AND_PBR_PASS

Required sequence:
1. WINDOW_03 reviews PR #30 / head `9769196db09cc57e38db4d2c2fdea2445484a21d` under Issue #31.
2. If PASS / MERGE: WINDOW_00 merges PR #30, closes #29/#31, and decides/authorizes the next representative battle-content batch.
3. If FIX_THEN_MERGE: WINDOW_02 fixes only concrete blockers and returns to review; do not expand scope or shrink the battle.
4. After Batch 1 acceptance, formation-vs-formation local engagement is the leading next construction direction, but final Batch 2 scope remains a build decision rather than a permanent product freeze.
5. Only after representative readiness does the user directly play and judge the game.

ONE_PRIMARY_PRODUCT_QUESTION=YES
ONE_PRIMARY_ACTIVE_TASK=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
