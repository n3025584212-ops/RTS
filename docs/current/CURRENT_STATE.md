# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V27
SOURCE_OF_TRUTH=THIS_FILE

GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_COLLABORATION_SYSTEM=docs/GPT_COLLABORATION_SYSTEM_V4.md
START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V2.md
DECISION_HISTORY=docs/current/DECISION_LOG.md

SUPERSEDED_PROJECT_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V2.md
SUPERSEDED_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V3.md
SUPERSEDED_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V2.md

PERMANENT_SPECIALIST_WINDOW_ROLES=ABOLISHED
WINDOW_NUMBER_AS_EXPERTISE=NO
WINDOW_NUMBER_AS_AUTHORITY=NO
WINDOWS=OPTIONAL_CONVERSATION_CONTEXTS_ONLY
DEFAULT_ACTIVE_PRIMARY_TASKS=1

---

## CORE CORRECTION

The project no longer treats fluent theory, generated design images, agent agreement, CI, or a window role as proof that a production method is understood.

REQUIRED_LEARNING_CHAIN:
REAL_PRODUCT_OR_REAL_PROBLEM
-> EVIDENCE
-> END_TO_END_CAUSAL_DECOMPOSITION
-> REPRODUCTION_OR_DIRECT_VERIFICATION
-> REAL_ARTIFACT
-> COMPARISON
-> TRANSFER_TO_FRONTLINE

UNKNOWN is valid. Plausible prose may not fill missing production knowledge.

---

## CURRENT PRODUCT / VISUAL AUTHORITY

PRODUCT=modern-warfare formation/platoon-level tactical command game
ENGINE_BASELINE=Godot_4_7_1
ENGINE_FINAL_LOCK=NO

APPROVED_VISUAL_TARGET=FRONTLINE_GOLDEN_FRAME_V1
GOLDEN_FRAME_SPEC=docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md
GOLDEN_FRAME_TARGET_RESOLUTION=1920x1080
GOLDEN_FRAME_SHA256=6c9305b89a5bb1839721f12c2ae8c2507fae4fc7d4fdbbdf130f6f1ecc113362
USER_APPROVED_GOLDEN_FRAME=YES

The Golden Frame remains a visual target, not proof that the project already knows how to manufacture it.

---

## HISTORICAL REAL ARTIFACTS

Historical evidence/tooling, not active product tasks:
- Golden Scene V1 / former Issue #33;
- River Town visual reset / former PR #35;
- Prototype B representative battle / former PR #30;
- Battle01 and older production attempts;
- Reference Region and local high-fidelity branches;
- existing asset-import, runtime-capture and screenshot tooling.

Golden Scene evidence:
REAL_ASSET_INTEGRATION=PASS
GODOT_4_7_1_IMPORT=PASS
RUNTIME_CAPTURE_PIPELINE=PASS
VISUAL_ACCEPTANCE=FAIL
PREVIOUS_PARTIAL_PASS=REVOKED_BY_USER
PR34=CLOSED_PREMATURE_REVIEW

USER_OBSERVED_BLOCKING_GAPS:
- low-poly / toy-like vehicles, buildings and vegetation;
- flat or single-material terrain treatment;
- simplified river banks, roads and bridge construction;
- insufficient realistic lighting, shadow and atmospheric depth;
- weak procedural-looking combat VFX;
- insufficient damage, decal and world-history detail;
- battlefield finishing below HUD finishing.

These are acceptance observations. Their technical causes are not assumed.

---

## CURRENT ACTIVE WORK

ACTIVE_PRIMARY_TASK=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-battlefield-construction
ACTIVE_TASK_TYPE=EVIDENCE_AND_REPRODUCTION
PRODUCT_PRODUCTION_RESUME=NO

QUESTION=
How does a mature inspectable RTS go from authored world/content and player input through units, navigation, combat, AI, UI, camera and presentation into a running readable battle—and can we independently reproduce a small complete chain before transferring any method to FRONTLINE?

CONTRACT=docs/learning/LEARNING_SPRINT_01_CONTRACT.md

Required sequence:
1. select at least one mature inspectable 3D RTS / real-time tactics production reference;
2. inspect real shipped results without inferring hidden implementation;
3. inspect real source/data/maps/content pipeline and official production evidence;
4. classify every major claim as OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED;
5. trace one playable chain end-to-end: world -> unit/data -> input -> movement -> combat -> AI -> UI -> camera -> presentation -> runtime;
6. separately causally decompose world construction;
7. independently reproduce a small complete running slice on different content;
8. capture and compare actual evidence;
9. record success/failure/approximation/unknowns;
10. only then decide what transfers to FRONTLINE.

---

## RETIRED OPEN WORK

Closed on 2026-09-12 and historical only:
- Issue #20 — Prototype B representative command battle;
- Issue #29 — representative battle content batch 1;
- Issue #31 — old window-based independent review;
- Issue #32 — Golden Frame engine/asset feasibility;
- Issue #33 — Golden Scene visual spike;
- PR #30 — Prototype B content branch, closed/superseded;
- PR #35 — visual-reset blind tuning branch, closed/superseded;
- PR #36 — pre-reset repository hygiene PR, closed/superseded.

Branch/commit history is retained for evidence and reuse.

Issue #37 remains open only as the branch-hygiene operations register.
Issue #39 is the only current product-learning issue.
OPEN_PRODUCT_PRS=0

---

## ACCEPTED TECHNICAL TOOLBOX

Reusable technical assets, not product-definition authority:
- Core V1 merged at 74c40115b6942df07ffca14b81f2fdbb2261e7ab;
- Prototype B Core migration merged at 09146d7bc351762cd6d9b48719015cd88e200063;
- FormationState / FormationTask / FormationAgent2D;
- TaskCommandService / FormationAutonomy / NavigationService;
- minimal CombatResolver;
- Godot 4.7.1 project and verified runtime tooling;
- legal asset import / provenance tooling;
- screenshot and CI evidence tooling;
- useful assets on preserved visual/reference branches.

Reuse is permitted only when it serves a newly evidenced method.

---

## HARD RULES

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
GENERATED_IMAGE_NOT_MANUFACTURABILITY_PROOF=YES
ELEMENT_PRESENCE_NOT_VISUAL_QUALITY_PROOF=YES
SEMANTIC_SUBSTITUTION_AS_IMPLEMENTATION=FORBIDDEN
GREYBOX_AS_PRODUCTION_DELIVERY=FORBIDDEN
USER_HYPOTHESIS_NOT_AUTOMATIC_TECHNICAL_FACT=YES
MODEL_HYPOTHESIS_NOT_AUTOMATIC_TECHNICAL_FACT=YES
USER_VISUAL_ACCEPTANCE_IS_AUTHORITATIVE=YES
UNKNOWN_ALLOWED=YES
ESSAY_WITHOUT_REPRODUCTION_IS_NOT_LEARNING_PASS=YES
OLD_OPEN_TASKS_DO_NOT_CONTROL_CURRENT_WORK=YES
RECENT_COMPLAINT_MUST_NOT_NARROW_THE_ENTIRE_LEARNING_PROBLEM=YES

---

## TASK ROUTING

There are no permanent design / development / review expert windows.

Any chat or agent receives one evidence-scoped task only:
- EVIDENCE_TASK;
- REPRODUCTION_TASK;
- BUILD_TASK;
- REVIEW_TASK.

Authority comes from evidence and artifacts, not a window number.

NEXT=ISSUE_39_REFERENCE_SELECTION_AND_EVIDENCE_REGISTER
NEXT_AFTER_REFERENCE=TRACE_REAL_END_TO_END_CHAIN
NEXT_AFTER_CHAIN=INDEPENDENT_SMALL_COMPLETE_REPRODUCTION
NEXT_AFTER_REPRODUCTION=FRONTLINE_TRANSFER_DECISION
NEXT_AFTER_TRANSFER=RESUME_ONE_SMALL_REAL_PRODUCT_SLICE_USING_ONLY_PROVEN_METHODS
