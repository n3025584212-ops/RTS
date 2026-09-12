# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V25
SOURCE_OF_TRUTH=THIS_FILE

GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_COLLABORATION_SYSTEM=docs/GPT_COLLABORATION_SYSTEM_V4.md
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

The Golden Frame remains the visual target. It is not evidence that every production method needed to manufacture it is already known.

---

## CURRENT REAL ARTIFACT

ACTIVE_ISSUE=#33
TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
CURRENT_REAL_ARTIFACT=existing Godot Golden Scene V1 implementation / dev branch evidence
LATEST_REVIEWED_RUNTIME_SCREENSHOT=artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png

REAL_ASSET_INTEGRATION=PASS
GODOT_4_7_1_IMPORT=PASS
RUNTIME_CAPTURE_PIPELINE=PASS
VISUAL_ACCEPTANCE=FAIL_CONTINUE_FIXING
PREVIOUS_PARTIAL_PASS=REVOKED_BY_USER
PR34=CLOSED_PREMATURE_REVIEW
MERGE=NO
PRODUCT_PASS=NO

USER_OBSERVED_BLOCKING_GAPS:
- low-poly / toy-like vehicles, buildings and vegetation;
- flat or single-material terrain treatment;
- simplified river banks, roads and bridge construction;
- insufficient realistic lighting, shadow and atmospheric depth;
- weak procedural-looking combat VFX;
- insufficient damage, decal and world-history detail;
- battlefield finishing below HUD finishing.

These observations are current acceptance evidence. Their technical causes remain hypotheses until investigated.

---

## CURRENT LEARNING RESET

LEARNING_RESET=ACTIVE

The next cycle must NOT begin with generic advice such as:
- use more PBR;
- add more detail;
- improve VFX;
- improve lighting;
- make it more realistic.

For each major rejected area, the project must obtain stronger production evidence and reproduce or directly verify the relevant method before claiming it is the solution.

PRIORITY_EVIDENCE_QUESTIONS:
1. How do proven RTS / real-time 3D projects construct rich terrain-material transitions at command-camera distance?
2. How are river banks, roads, bridge approaches and settlements generated/assembled so spatial placement looks causal rather than decorative?
3. What asset/material/LOD quality is actually required for vehicles, infantry, buildings and vegetation at the approved camera scale?
4. How do proven real-time scenes create lighting and atmospheric depth without hiding gameplay readability?
5. How are smoke, fire, explosions, impacts, tracers, damage and decals layered into production-quality combat presentation?

For every answer, distinguish OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN.

---

## ACCEPTED TECHNICAL TOOLBOX

The following remain reusable technical assets, not product-definition authority:
- Core V1 merged at 74c40115b6942df07ffca14b81f2fdbb2261e7ab;
- Prototype B Core migration merged at 09146d7bc351762cd6d9b48719015cd88e200063;
- FormationState / FormationTask / FormationAgent2D;
- TaskCommandService / FormationAutonomy / NavigationService;
- minimal CombatResolver;
- existing Golden Scene asset-import, runtime-capture and evidence tooling.

Old Battle01 / Prototype B design decisions are not automatically current product design.
PR #30 and Issue #31 are historical/incomplete technical work and do not control current visual production.

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

---

## TASK ROUTING

There are no permanent design / development / review expert windows.

Any chat or agent may receive one evidence-scoped task:
- EVIDENCE_TASK;
- REPRODUCTION_TASK;
- BUILD_TASK;
- REVIEW_TASK.

Authority comes from the artifact and evidence, not the window number.

CURRENT_PRIMARY_TASK_TYPE=EVIDENCE_AND_REPRODUCTION
CURRENT_PRIMARY_GOAL=identify and reproduce real production methods for the largest rejected Golden Scene visual gaps before another broad visual-fix pass

NEXT=EVIDENCE_AND_REPRODUCTION_PASS_FOR_REJECTED_GOLDEN_SCENE_GAPS

After reproduction evidence exists:
NEXT_AFTER_LEARNING=APPLY_PROVEN_METHODS_TO_EXISTING_GOLDEN_SCENE
THEN=RUN_CAPTURE_COMPARE_WITH_APPROVED_GOLDEN_FRAME
THEN=USER_VISUAL_REVIEW
