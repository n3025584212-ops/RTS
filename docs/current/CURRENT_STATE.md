# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V31
SOURCE_OF_TRUTH=THIS_FILE

GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
CORE_LEARNING_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md
START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V2.md
DECISION_HISTORY=docs/current/DECISION_LOG.md

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

## CORE CAUSAL CHAIN

CONTENT
-> WORLD
-> INPUT
-> SIMULATION
-> CONTROL
-> STATE
-> PRESENTATION
-> RENDER
-> PLAYER

The active learning target is the connected causal chain, not isolated subsystem knowledge.

Required learning method:
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

## CURRENT ACTIVE WORK

ACTIVE_PRIMARY_TASK=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_TASK_TYPE=EVIDENCE_GRAPH_AND_REPRODUCTION
PRODUCT_PRODUCTION_RESUME=NO

PRIMARY_REFERENCE=0_AD_RELEASE_28
SECONDARY_VALIDATOR_A=BEYOND_ALL_REASON_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

REFERENCE_SELECTION=docs/learning/sprint01/REFERENCE_SELECTION.md
EVIDENCE_REGISTER=docs/learning/sprint01/EVIDENCE_REGISTER.md
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
CONTRACT=docs/learning/LEARNING_SPRINT_01_CONTRACT.md
AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

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

These are not thirteen independent topics. Critical edges between layers must be evidenced.

---

## WINDOW 03 STRICT AUDIT GATE

WINDOW_03_STATUS=ACTIVE_STRICT_EVIDENCE_AUDIT

Window 03 audits the boundary between evidence, fact, inference, pattern and recommendation.

Six mandatory checks:
1. PRIMARY_SOURCE_INTEGRITY
2. VERSION_IDENTITY
3. RUNTIME_SEMANTICS
4. GENERALIZATION_BOUNDARY
5. ALTERNATIVE_EXPLANATIONS
6. COUNTEREXAMPLE_SEARCH

Allowed generalization levels:
- SOURCE_FACT
- PROJECT_SPECIFIC_INFERENCE
- CROSS_PROJECT_PATTERN
- DESIGN_RECOMMENDATION
- UNSUPPORTED_GENERALIZATION

Allowed audit verdicts:
- PASS
- DOWNGRADE
- FIX
- REJECT
- UNKNOWN

### Verified current audit alerts

ALERT_01_0AD_GITHUB_ARCHIVE=ACTIVE
The `0ad/0ad` GitHub repository is archived and labels itself a deprecated Git mirror, with source migrated to Wildfire Games Gitea on 2024-08-20. It must not be treated as current 2026 / Release-28 source by default. Historical use requires explicit version qualification; Release-28 source claims require version-matched authoritative source evidence.

ALERT_02_0AD_COMPONENT_TAXONOMY_NOT_RUNTIME_CHAIN=ACTIVE
0 A.D. Release-28 documentation exposes different component categories including systems, C++ script wrappers and scripted components. The existence of `UnitAI`, `Pathfinder`, `GuiInterface` or another component does not by itself prove the exact runtime path of a specific command.

ALERT_03_BAR_ENGINE_GAME_LOBBY_BOUNDARY=ACTIVE
Beyond All Reason explicitly separates game code from the Recoil RTS Engine and has a separate lobby/client layer. Reading only the BAR game repository is insufficient to infer the full RTS engine/runtime architecture.

ALERT_04_WARZONE_DIFFERENT_SCRIPT_BOUNDARY=ACTIVE
Warzone 2100 documents JavaScript scripting for AIs, campaigns and some game rules on top of its native/core implementation. This is a mature counterexample pool against unsupported claims that one project's component boundary is necessary for RTS.

---

## CURRENT FOUR-WINDOW ALLOCATION

WINDOW_00_STATUS=ACTIVE
WINDOW_00_TASK=Maintain one shared state, Issue #39, task boundaries, evidence gates, repository clarity, and final integration/rejection decisions.

WINDOW_01_STATUS=ACTIVE
WINDOW_01_TASK=Build the linked 13-layer evidence graph; trace one version-correct real playable chain end-to-end; map comparable FRONTLINE links; preserve UNKNOWN and competing explanations.

WINDOW_02_STATUS=STAGED_WAITING_FOR_REPRODUCIBLE_CHAIN
WINDOW_02_TASK=Once Window 01 produces a concrete linked chain, build the isolated runnable reproduction on the learning branch; produce real runtime/player-visible evidence, not semantic placeholders.

WINDOW_03_STATUS=ACTIVE
WINDOW_03_TASK=Apply the six-check hard audit contract to Window 01 claims now; later apply the same evidence discipline to Window 02's actual reproduction and player-visible artifact.

WINDOWS_SHARE_ONE_ISSUE=#39
FOUR_INDEPENDENT_ROADMAPS=NO
FOUR_INDEPENDENT_TRUTHS=NO

---

## HISTORICAL REAL ARTIFACTS / REUSABLE TOOLBOX

Historical evidence/tooling, not active product tasks:
- Golden Scene V1 / former Issue #33;
- River Town visual reset / former PR #35;
- Prototype B representative battle / former PR #30;
- Battle01 and older production attempts;
- Reference Region and local high-fidelity branches;
- existing asset-import, runtime-capture and screenshot tooling.

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
PRIMARY_REFERENCE_IS_NOT_UNIVERSAL_TRUTH=YES
WINDOW_NUMBER_IS_NOT_PROOF=YES
FOUR_WINDOWS_RETAINED=YES
ISOLATED_SUBSYSTEM_NOTES_ARE_NOT_END_TO_END_LEARNING=YES
PLAYER_LAYER_MUST_BE_REACHED=YES
SECONDARY_SOURCE_NOT_SOURCE_CODE_PROOF=YES
VERSION_IDENTITY_REQUIRED=YES
SYMBOL_EXISTENCE_NOT_RUNTIME_CHAIN=YES
COUNTEREXAMPLE_SEARCH_REQUIRED_FOR_GENERALIZATION=YES

---

## TASK ROUTING

NEXT=WINDOW_01_BUILD_FIRST_VERSION_CORRECT_13_LAYER_TRACE
PARALLEL_NEXT=WINDOW_03_AUDIT_WITH_SIX_HARD_CHECKS
NEXT_AFTER_CHAIN=WINDOW_02_INDEPENDENT_SMALL_COMPLETE_REPRODUCTION
NEXT_AFTER_REPRODUCTION=WINDOW_03_REPRODUCTION_REVIEW
NEXT_AFTER_REVIEW=WINDOW_00_FRONTLINE_TRANSFER_DECISION
NEXT_AFTER_TRANSFER=RESUME_ONE_SMALL_REAL_PRODUCT_SLICE_USING_ONLY_PROVEN_METHODS
