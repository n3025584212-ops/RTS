# FRONTLINE DECISION LOG

STATUS=ACTIVE_APPEND_ONLY_HISTORY
PROJECT=FRONTLINE
CURRENT_STATE=docs/current/CURRENT_STATE.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md

This file records material product/project decisions after they are made.
It is not the current roadmap and does not override CURRENT_STATE.

---

## Entry format

DATE=
DECISION_ID=
STATUS=ACCEPTED | REOPENED | SUPERSEDED | KILLED
DECISION=
EVIDENCE=
IMPACT=
RELATED_ISSUE_OR_PR=

---

## 2026-09-02 — Unified project operating model

DATE=2026-09-02
DECISION_ID=FRONTLINE_UNIFIED_PROJECT_SYSTEM_V1
STATUS=ACCEPTED
DECISION=FRONTLINE uses one unified project state and task-based capabilities. Permanent numbered-window authority and fixed handoff chains are retired.
EVIDENCE=FRONTLINE_PROJECT_CHARTER_V3 + CURRENT_STATE_V5
IMPACT=All current work uses CURRENT_STATE as the single project truth. Historical window documents remain references only unless explicitly reaccepted.
RELATED_ISSUE_OR_PR=

## 2026-09-02 — Prototype A product result

DATE=2026-09-02
DECISION_ID=PROTOTYPE_A_COMMAND_RESPONSE_REWORK
STATUS=REOPENED
DECISION=Prototype A is technically valid evidence but does not prove Command & Response as the game core. Its expression is not accepted for production.
EVIDENCE=First-use player response "没看懂" plus Prototype A technical PASS.
IMPACT=Battle01 production remains paused. Discovery must move beyond the thin Prototype A expression.
RELATED_ISSUE_OR_PR=#17

## 2026-09-02 — Initial nine-window GPT collaboration layout

DATE=2026-09-02
DECISION_ID=FRONTLINE_GPT_MULTI_WINDOW_SYSTEM_V1
STATUS=SUPERSEDED
DECISION=The initial WINDOW_00–WINDOW_08 GPT layout established reusable specialist contexts under one shared state.
EVIDENCE=User requested a GPT multi-window system; V1 was implemented.
IMPACT=The principle of shared-state multi-chat collaboration remains valid, but the nine-window layout is retired because it creates unnecessary coordination/context overhead.
RELATED_ISSUE_OR_PR=

## 2026-09-02 — Four-window GPT operating model

DATE=2026-09-02
DECISION_ID=FRONTLINE_GPT_FOUR_WINDOW_RUNTIME_V2
STATUS=ACCEPTED
DECISION=FRONTLINE uses four practical GPT routing contexts: WINDOW_00 Project Control/Integration, WINDOW_01 Design/Experience, WINDOW_02 Development, WINDOW_03 Review/Operations.
EVIDENCE=User explicitly judged nine windows excessive and requested initialization commands plus a workable runtime plan.
IMPACT=WINDOW_00 is the persistent control context; other windows are activated only when needed. Results are shared through GitHub Issue/PR/code/test evidence rather than mandatory chat receipt chains. Only 00 edits CURRENT_STATE by default.
RELATED_ISSUE_OR_PR=#20

## 2026-09-03 — Human experience gate after sufficient game substance

DATE=2026-09-03
DECISION_ID=FRONTLINE_HUMAN_PLAY_AFTER_READINESS_V1
STATUS=ACCEPTED
DECISION=Codex/automation may verify technical behavior but may not simulate or stand in for a human player. Human product judgment should not repeatedly gate ultra-thin implementation increments.
EVIDENCE=User explicitly challenged the value of repeated simulated-player/experience checks while the game was still too underdeveloped for meaningful judgment.
IMPACT=Development proceeds until enough coherent game substance exists for meaningful human evaluation; TECHNICAL_PASS remains separate from PRODUCT_PASS.
RELATED_ISSUE_OR_PR=#20

## 2026-09-03 — Representative command-battle slice, not toy mechanism demo

DATE=2026-09-03
DECISION_ID=FRONTLINE_REPRESENTATIVE_COMMAND_BATTLE_SLICE_V1
STATUS=ACCEPTED
DECISION=FRONTLINE must not be reduced to a tiny prototype with a few abstract formations, one contact or one isolated repeated decision and then treated as if that were an RTS battle. Core discovery must use a representative integrated command-battle slice with sustained command load and interacting systems.
EVIDENCE=User explicitly rejected the proposed "3 formations / small scenario" framing as an inadequate representation of a real game.
IMPACT=The current primary task is now BUILD_PROTOTYPE_B_REPRESENTATIVE_COMMAND_BATTLE_SLICE_V1. Exact counts and map sizes remain soft; readiness is based on interacting battlefield demands, autonomous local execution, changing enemy action, reserves/retasking, combat consequences and sustained play. The earlier "one repeated decision defines the game" framing is reopened as too narrow.
RELATED_ISSUE_OR_PR=#20

## 2026-09-20 — Archive M2 legacy contract scripts and expired smoke tests

DATE=2026-09-20
DECISION_ID=FRONTLINE_M2_LEGACY_CONTRACT_ARCHIVE_V1
STATUS=ACCEPTED
DECISION=Move 9 unreferenced legacy-contract scripts (enemy AI chain of 5, staging runtime subclass, two staging helpers, minimap) and 8 expired Battle01 smoke tests into archive/m2-legacy-contract/ with original subpaths preserved. Baseline tag archive/pre-cleanup-2026-09-20 created before the move. battle01_resupply_controller.gd and pre_battle_staging_controller.gd are deliberately retained because retained code still type-declares their classes (selection_controller.gd, battle_3d_input.gd); they are inert null-guarded hooks and become follow-up decoupling candidates.
EVIDENCE=Full repository sweep on 2026-09-20: Battle01.tscn no longer mounts EnemyAIController/PreBattleStaging/ResupplyController nodes; filename and class_name greps show zero references from all retained code; CI workflows gate only core_v1_batch1, core_v1_battle_navigation_compat and prototype_b_core_integration. The 8 archived tests assert pre-restart contracts (supply columns, reserve deployment, VILLAGE_SCREEN/SOUTH_SCREEN postures) that no longer match code or .tres resources.
IMPACT=main now contains only live-wired scripts and the three valid CI gates; the archived M2 contract remains fully recoverable via the baseline tag (git checkout archive/pre-cleanup-2026-09-20 -- <path>). DECISION_LOG gap between 2026-09-03 and 2026-09-20 remains unaccounted; this entry does not backfill it.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — River Town sole visual baseline, non-kind baselines recycled

DATE=2026-09-20
DECISION_ID=FRONTLINE_SOLE_VISUAL_BASELINE_V1
STATUS=ACCEPTED
DECISION=RiverTownVisualSlice (product/frontline-high-fidelity-slice-v1) is the single visual baseline of FRONTLINE, evidenced by fresh 1920x1080 Forward+ captures (reference/hero/ground) committed under docs/visual_baseline/river_town_sole_20260920/ on the product branch. Same-kind River Town family assets are retained as part of that one baseline. Non-kind baselines (FullBattlefield V1-V12 + TownProbeA-D, GoldenSceneV1, Quality scenes, assets/golden_scene library, their CI workflows) are recycled with safety tag recycle/2026-09-20/pre-visual-baseline-rationalization. Golden Frame V1 is superseded as VISUAL_TARGET_AUTHORITY. The single golden_scene file used by the baseline (church_landmark.glb) was migrated to assets/visual_slice/landmarks/ so the baseline asset graph is self-contained.
EVIDENCE=User directive 2026-09-20; local re-render of the baseline scene after recycle (Vulkan 1.4.323, Intel UHD, 2129 draw calls, ~134 ms/frame); zero references from retained code to any recycled path; full recycle manifest at docs/ops/VISUAL_BASELINE_RECYCLE_2026-09-20.md on the product branch.
IMPACT=Future visual work compares against docs/visual_baseline/river_town_sole_20260920/ captures under the stated protocol. VISUAL_QUALITY_BASELINE.md amended accordingly.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate B armored-unit integration evidence complete

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_B_ARMORED_UNIT_EVIDENCE_V1
STATUS=EVIDENCE_COMPLETE_PENDING_GATE_C
DECISION=User directed continuation of the active plan (Issue #41). The minimum already-validated controllable armored-unit chain was integrated into the River Town mother scene on product/frontline-high-fidelity-slice-v1: the validated BattleFormation selection/order/movement logic and the validated core NavigationService now drive the real Abrams PBR mesh (river_town_armored_unit.gd + river_town_sim_navigation.gd; additive integration, no proxy, greybox route tables unused). Fresh 1920x1080 Forward+ runtime media (before/mid/arrived + metrics) recorded under product::docs/visual_baseline/gate_b_20260920/ with a new additive gate_b capture view. All seven Gate B PASS evidence items are recorded; TECHNICAL_PASS remains distinct from PRODUCT_PASS, so Gate C independent audit is the required next route.
EVIDENCE=Integration commit 24ad352 + docs commits 52b0724 on the product branch; local run logs with zero script errors; displacement (2.5,7) -> (5.125,-0.875) through select -> issue_move -> NavigationService path; selection ring and terrain-height binding visible in media; sole-baseline visual comparison recorded with no regression. Audit note: the Abrams historically sat outside the hero camera frustum (the hero view frames the foreground house), explaining why earlier captures never showed it; the additive gate_b view resolves this.
IMPACT=Window 02 construction task is evidence-complete; Window 03 independent audit of Gate B is now the active route. CI workflow FRONTLINE River Town Visual Slice is triggered by the push and serves as CI-side reproduction.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate C audit PASS; provenance condition closed; slice gates A/B/C all closed

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_C_CLOSED_V1
STATUS=CLOSED
DECISION=The Gate C independent audit (performed by a separate ZCode session in the Window 03 role, report product::docs/current/GATE_C_AUDIT_GATE_B_V1.md) returned PASS_WITH_ONE_CONDITION for Gate B: zero same-renderer pixel regression across the integration (CI runs 35325714573 vs 35464759495), no proxy leakage, product-readable capture. The single provenance condition was closed by product commit 394460d: the evidence driver tools/gate_b_capture.gd is now in the library and the original local run log gate_b_run.log is archived beside the evidence media. Gate B is hereby PASS and the Gate A/B/C slice is closed. Per the contract, TECHNICAL/PRODUCT acceptance for this slice is complete; the next product gate requires a new Window 00 task definition and is intentionally not invented here.
EVIDENCE=audit report cf91c68; condition-closure commit 394460d on product/frontline-high-fidelity-slice-v1; main routing commit (this commit).
IMPACT=ACTIVE_BRANCH_VERIFIED_HEAD moves to 394460d. NEXT=WINDOW_00_DEFINE_NEXT_PRODUCT_GATE.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate D1 combat chain integrated, evidence complete pending audit

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_D1_COMBAT_CHAIN_V1
STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT
DECISION=User directive "D1" (2026-09-20) authorized Gate D1 MINIMUM_COMBAT_CHAIN per the Window 00 recommendation. The validated combat cycle is now live in the River Town mother scene: a static RED hostile armored target (second real Abrams GLB with red-shifted armor shader, hidden RED BattleFormation, progressive paint charring) and an attack order on the Gate B unit routing through set_combat_target -> _update_combat (range 300 sim, 1.5 s reload, ammo consumption, validated damage matrix TANK-vs-TANK 1.0). Evidence driver tools/gate_d1_capture.gd committed in-library (Gate C provenance lesson applied).
EVIDENCE=Product commit aedabe0; docs/visual_baseline/gate_d1_20260920/: 7 shots x 45 damage, ammo 16->9, target hp 280->0 destroyed, 3 fresh 1920x1080 frames (before/engaging/destroyed) + metrics JSON. Known limitations recorded: static hostile does not return fire, LOS field not yet bound, tracer lifetime vs frame rate.
IMPACT=Gate D1 awaits independent audit (Gate C protocol) before formal closure. D2 (multi-formation selection) and human playtest checkpoint remain the candidate next routes.
RELATED_ISSUE_OR_PR=#41
