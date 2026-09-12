# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V30
SOURCE_OF_TRUTH=THIS_FILE

GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
CORE_LEARNING_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V2.md
DECISION_HISTORY=docs/current/DECISION_LOG.md

SUPERSEDED_PROJECT_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V2.md
SUPERSEDED_COLLABORATION_SYSTEM_V4=docs/GPT_COLLABORATION_SYSTEM_V4.md
SUPERSEDED_COLLABORATION_SYSTEM_V3=docs/GPT_MULTI_WINDOW_SYSTEM_V3.md
SUPERSEDED_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V2.md

FOUR_WINDOW_SYSTEM=ACTIVE
WINDOW_COUNT=4
SHARED_PROJECT_STATE=YES
INDEPENDENT_WINDOW_PROJECT_STATES=NO
WINDOW_NUMBER_AS_EXPERTISE=NO
WINDOW_NUMBER_AS_AUTHORITY=NO
DEFAULT_ACTIVE_PRIMARY_TASKS=1

WINDOW_00=CONTROL_AND_INTEGRATION
WINDOW_01=EVIDENCE_AND_LEARNING
WINDOW_02=REPRODUCTION_AND_BUILD
WINDOW_03=INDEPENDENT_REVIEW_AND_FALSIFICATION

---

## CORE CORRECTION

The project retains four GPT windows for parallel collaboration, but no window is considered correct because of its number or title.

The project no longer treats fluent theory, generated design images, agent agreement, CI, or a window role as proof that a production method is understood.

The active learning target is now explicitly the connected causal chain, not isolated subsystem knowledge.

CORE_CAUSAL_CHAIN:
CONTENT
-> WORLD
-> INPUT
-> SIMULATION
-> CONTROL
-> STATE
-> PRESENTATION
-> RENDER
-> PLAYER

REQUIRED_LEARNING_CHAIN:
REAL_PRODUCT_OR_REAL_PROBLEM
-> EVIDENCE
-> END_TO_END_CAUSAL_DECOMPOSITION
-> REPRODUCTION_OR_DIRECT_VERIFICATION
-> REAL_ARTIFACT
-> COMPARISON
-> TRANSFER_TO_FRONTLINE

DEFAULT_WINDOW_CHAIN:
WINDOW_00_DEFINE_AND_ROUTE
-> WINDOW_01_BUILD_LINKED_EVIDENCE_GRAPH
-> WINDOW_02_REPRODUCE_OR_BUILD
-> WINDOW_03_FALSIFY_AND_REVIEW
-> WINDOW_00_INTEGRATE_OR_REJECT

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

ACTIVE_PRIMARY_TASK=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_TASK_TYPE=EVIDENCE_GRAPH_AND_REPRODUCTION
PRODUCT_PRODUCTION_RESUME=NO

PRIMARY_REFERENCE=0_AD_RELEASE_28
PRIMARY_REFERENCE_STATUS=SELECTED_FOR_INITIAL_END_TO_END_TRACE
SECONDARY_VALIDATOR_A=BEYOND_ALL_REASON_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

REFERENCE_SELECTION=docs/learning/sprint01/REFERENCE_SELECTION.md
EVIDENCE_REGISTER=docs/learning/sprint01/EVIDENCE_REGISTER.md
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
CONTRACT=docs/learning/LEARNING_SPRINT_01_CONTRACT.md

QUESTION=
How does authored content/data become a running RTS battle through world construction, input, simulation, player/AI control, authoritative state, presentation and rendering—and where exactly are FRONTLINE's supported, broken, duplicated or unknown links before the final player-visible result?

## REQUIRED 13-LAYER EVIDENCE GRAPH

1. MAP_LOADING_AND_BATTLE_SPACE
2. UNIT_DATA_SOURCE_OF_TRUTH
3. MODEL_MATERIAL_ASSET_BINDING
4. PLAYER_SELECTION
5. COMMAND_ROUTING
6. PATHFINDING_AND_MOVEMENT
7. DETECTION_AND_TARGET_SELECTION
8. FIRE_HIT_DAMAGE_DEATH
9. AI_COMMAND_GENERATION
10. UI_STATE_ACQUISITION
11. ANIMATION_VFX_AUDIO_FEEDBACK
12. CAMERA_AND_RENDER_PRESENTATION
13. FINAL_PLAYER_VISIBLE_RESULT

These are not thirteen independent study topics. Each important edge between them must be evidenced.

Required evidence fields for a major edge:
- CLAIM
- CHAIN_LAYER_OR_EDGE
- SOURCE
- STATUS=`OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- WHAT_THE_SOURCE_ACTUALLY_PROVES
- WHAT_IT_DOES_NOT_PROVE
- FRONTLINE_CURRENT_IMPLEMENTATION
- EXTERNAL_REFERENCE_IMPLEMENTATION
- GAP
- REPRODUCTION_REQUIRED

Reference selection rationale:
- 0 A.D. Release 28 is the first primary inspectable teacher because its source/data ecosystem exposes maps, art, GUI, shaders, simulation, AI, helpers and templates;
- it is not FRONTLINE's visual/gameplay template and not a universal RTS truth;
- BAR/Recoil and Warzone 2100 are counterexample/cross-check sources;
- commercial games primarily establish observable player-facing result unless production method is publicly documented.

Required sequence:
1. Window 01 selects and traces one real playable chain through all thirteen layers;
2. Window 03 audits versions, source provenance, inference scope and counterexamples in parallel;
3. Window 01 maps the same critical edges onto FRONTLINE current/historical implementation where evidence exists;
4. unsupported edges remain UNKNOWN rather than being bridged by prose;
5. Window 02 independently reproduces a small complete chain on different content;
6. the reproduction must reach player-visible behavior/feedback, not only code/CI;
7. Window 03 reviews the real artifact and whether the claimed edge was actually reproduced;
8. Window 00 only then decides what can transfer to FRONTLINE production.

---

## CURRENT FOUR-WINDOW ALLOCATION

WINDOW_00_STATUS=ACTIVE
WINDOW_00_TASK=Maintain one shared state, Issue #39, task boundaries, evidence gates, repository clarity, and final integration/rejection decisions.

WINDOW_01_STATUS=ACTIVE
WINDOW_01_TASK=Build the linked 13-layer evidence graph; trace one 0 A.D. Release 28 playable chain end-to-end; map comparable FRONTLINE links; preserve UNKNOWN and competing explanations.

WINDOW_02_STATUS=STAGED_WAITING_FOR_REPRODUCIBLE_CHAIN
WINDOW_02_TASK=Once Window 01 produces a concrete linked chain, build the isolated runnable reproduction on the learning branch; produce real runtime/player-visible evidence, not semantic placeholders.

WINDOW_03_STATUS=ACTIVE
WINDOW_03_TASK=Audit Window 01 evidence immediately; verify source/version and claim scope; search for BAR/Warzone counterexamples; later falsify/review Window 02 reproduction against pre-stated criteria and actual source/artifact evidence.

WINDOWS_SHARE_ONE_ISSUE=#39
FOUR_INDEPENDENT_ROADMAPS=NO
FOUR_INDEPENDENT_TRUTHS=NO

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
PRIMARY_REFERENCE_IS_NOT_UNIVERSAL_TRUTH=YES
WINDOW_NUMBER_IS_NOT_PROOF=YES
FOUR_WINDOWS_RETAINED=YES
ISOLATED_SUBSYSTEM_NOTES_ARE_NOT_END_TO_END_LEARNING=YES
PLAYER_LAYER_MUST_BE_REACHED=YES

---

## TASK ROUTING

Four windows are the standard collaboration topology:
- 00 CONTROL / INTEGRATION
- 01 EVIDENCE / LEARNING
- 02 REPRODUCTION / BUILD
- 03 INDEPENDENT REVIEW / FALSIFICATION

Authority comes from evidence and artifacts, not a window number.

NEXT=WINDOW_01_BUILD_FIRST_13_LAYER_TRACE_FOR_ONE_REAL_PLAYABLE_CHAIN
PARALLEL_NEXT=WINDOW_03_AUDIT_FIRST_CHAIN_SOURCES_AND_GENERALIZATION
NEXT_AFTER_CHAIN=WINDOW_02_INDEPENDENT_SMALL_COMPLETE_REPRODUCTION
NEXT_AFTER_REPRODUCTION=WINDOW_03_REPRODUCTION_REVIEW
NEXT_AFTER_REVIEW=WINDOW_00_FRONTLINE_TRANSFER_DECISION
NEXT_AFTER_TRANSFER=RESUME_ONE_SMALL_REAL_PRODUCT_SLICE_USING_ONLY_PROVEN_METHODS
