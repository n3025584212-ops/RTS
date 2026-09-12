# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V26
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

The project no longer treats fluent theory, a generated design image, agent agreement, CI, or a window role as proof that a production method is understood.

REQUIRED_LEARNING_CHAIN:
REAL_PRODUCT_OR_REAL_PROBLEM
-> EVIDENCE
-> CAUSAL_DECOMPOSITION
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

The Golden Frame remains a visual target, but it is not proof that the project already knows how to manufacture every part of it.

---

## HISTORICAL REAL ARTIFACTS

The following remain valuable evidence/tooling but are not active product tasks:

- Golden Scene V1 / former Issue #33;
- River Town visual reset / former PR #35;
- Prototype B representative battle / former PR #30;
- Battle01 and older production attempts;
- Reference Region and local high-fidelity branches;
- existing asset-import, runtime-capture and screenshot tooling.

Golden Scene historical evidence:

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

These observations are acceptance evidence. Their technical causes are not assumed.

---

## CURRENT ACTIVE WORK

ACTIVE_PRIMARY_TASK=LEARNING_SPRINT_01_BATTLEFIELD_CONSTRUCTION
ACTIVE_ISSUE=#39
ACTIVE_TASK_TYPE=EVIDENCE_AND_REPRODUCTION
PRODUCT_PRODUCTION_RESUME=NO

QUESTION=
How is a believable mature 3D RTS/tactical battlefield region actually produced—from terrain and transport through settlement, vegetation, materials, lighting and command-camera readability—and can we independently reproduce that production logic before transferring it to FRONTLINE?

CONTRACT=docs/learning/LEARNING_SPRINT_01_CONTRACT.md

Required sequence:
1. inspect real shipped results without inferring hidden implementation;
2. inspect at least one real open/inspectable production implementation;
3. inspect official developer/engine/tool production evidence;
4. classify every major claim as OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED;
5. causally decompose the production chain;
6. reproduce the method in an isolated learning scene on different spatial content;
7. run and capture actual evidence;
8. compare success/failure/unknowns;
9. only then decide what transfers to FRONTLINE.

---

## RETIRED OPEN WORK

The following stale work was closed on 2026-09-12 and remains historical only:

- Issue #20 — Prototype B representative command battle;
- Issue #29 — representative battle content batch 1;
- Issue #31 — old window-based independent review;
- Issue #32 — Golden Frame engine/asset feasibility;
- Issue #33 — Golden Scene visual spike;
- PR #30 — Prototype B content branch, closed/superseded;
- PR #35 — visual-reset blind tuning branch, closed/superseded;
- PR #36 — pre-reset repository hygiene PR, closed/superseded.

Branch/commit history is retained for evidence and reuse.

Issue #37 remains open only as an operations register for reviewed stale-branch deletion candidates.

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

Reuse is permitted only when it serves a newly evidenced production method.

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

---

## TASK ROUTING

There are no permanent design / development / review expert windows.

Any chat or agent receives one evidence-scoped task only:
- EVIDENCE_TASK;
- REPRODUCTION_TASK;
- BUILD_TASK;
- REVIEW_TASK.

Authority comes from evidence and artifacts, not a window number.

NEXT=EXECUTE_ISSUE_39_EVIDENCE_SELECTION_AND_CAUSAL_DECOMPOSITION
NEXT_AFTER_EVIDENCE=INDEPENDENT_REPRODUCTION
NEXT_AFTER_REPRODUCTION=FRONTLINE_TRANSFER_DECISION
NEXT_AFTER_TRANSFER=RESUME_A_SMALL_REAL_PRODUCT_BUILD_USING_ONLY_PROVEN_METHODS
