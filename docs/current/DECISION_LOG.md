# FRONTLINE DECISION LOG

STATUS=ACTIVE_APPEND_ONLY_HISTORY
PROJECT=FRONTLINE
CURRENT_STATE=docs/current/CURRENT_STATE.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md

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

## 2026-09-20 — Gate D1 independent audit PASS; GATE_D1_PASS recorded

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_D1_CLOSED_V1
STATUS=CLOSED
DECISION=The Gate D1 independent audit (separate ZCode session, Window 03 role; report product::docs/current/GATE_D1_INDEPENDENT_AUDIT_V1.md, commit 49318e7) returned PASS with no blocking conditions. Numeric audit confirmed matrix consistency (tank.tres 45 dmg / 300 range / 1.5 s / 16 rnd; 7 shots x 45 x 1.0 = 315 >= 280 hp; engaging frame at 145 hp matches the 60% stage trigger). Same-renderer CI comparison (35479014712 vs 35464759495) shows 5.8% pixel delta = the newly added hostile vehicle, not degradation. GATE_D1_PASS is hereby recorded. Non-blocking audit suggestions adopted as D-gate evidence policy: archive raw run logs beside JSON; migrate driver output paths to user://.
EVIDENCE=audit commit 49318e7 on product/frontline-high-fidelity-slice-v1; main routing commit (this commit).
IMPACT=Gate D1 closed. Candidate next: Gate D2 (multi-formation selection) or human playtest checkpoint - Window 00 selection pending.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate D2 multi-formation selection integrated; evidence complete pending audit

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_D2_MULTI_FORMATION_SELECTION_V1
STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT
DECISION=User directive "你接着做吧" (2026-09-20) continued the "D1" line. Window 02 had left Gate D2 (MULTI_FORMATION_SELECTION) as an uncommitted partial run in the product worktree: a platoon script, an uncommitted capture driver, and three local captures that had never been archived. The gate was finished and re-derived rather than merely archived, because three defects made the partial evidence unusable: (1) the group order assigned destination slots by array index, sending the leftmost vehicle to the rightmost slot and scrambling the formation; (2) the platoon spawned with the 13 m-long vehicles 2.2 m apart, so four hulls interpenetrated and the capture read as one mass; (3) snapshots taken in the same frame as a state change recorded the previous rendered frame, so neither the marquee nor the selection rings appeared in the media. The group order now sorts units along the lateral axis and re-slots them at pitch = max(declared spacing, current mean gap) (formation-preserving, no path crossings); the spawn line is a measured 6.0 m abreast at z 7.0 with the selection ring enlarged to clear the 6.4 m hull; and the driver changes state and snaps three frames apart. Click select, drag-box select with a visible marquee, and one group order are all driven through the same entry points the mouse uses.
EVIDENCE=Product commit 9d026ed on product/frontline-high-fidelity-slice-v1; docs/visual_baseline/gate_d2_20260920/ (5 fresh 1920x1080 frames, JSON, raw run log, committed driver tools/gate_d2_capture.gd). Numbers: 4 real abrams.glb vehicles; click 1 -> 1 selected; marquee rect 905 x 54 px -> 4 selected; 4 x FRONTLINE_GATE_B_ORDER_ISSUED accepted=true; minimum advance 12.905 m; frontage 6.000 -> 8.000 m = max(8.0, 6.0); lateral order preserved; all four settled HOLD at z -5.875 with 8.0 m spacing. Repeated local runs reproduce identical assertion values (frames are not byte-identical because the scene animates smoke and temporal effects). CI run 35488489417 reproduces the integration.
IMPACT=Gate D2 awaits independent audit (Gate C protocol) before formal closure. Known limitations recorded in the evidence record: the driver supplies drag geometry programmatically so real mouse input and a human operator remain the separate playtest checkpoint; no collision/avoidance system exists yet, so one vehicle's straight-line path crosses the Gate D1 hostile footprint at (8.5, 0.08, 3.0) while the settled formation has no overlap.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate D2 conditions closed; independent re-audit PASS; GATE_D2_PASS recorded

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_D2_CLOSED_V1
STATUS=CLOSED
DECISION=The Gate D2 independent audit returned PASS_WITH_CONDITION (report product::docs/current/GATE_D2_INDEPENDENT_AUDIT_V1.md) on two counts: the evidence record claimed "No settled-state overlap exists" while the deployment row's second vehicle spawned ~47-58 m^2 of hull inside the Gate D1 hostile (visible clipping in every frame), and that overlap had to be fixed or explicitly accepted before the next gate. Window 02 closed both by changing the integration, not the wording (product 0225e11): the added vehicles redeploy north of the village road at z -12.0 (line_x 6/14/22) with >= 2.3 m of hull clearance from the hostile footprint and no path crossing it; group-order slots are centred on the ordered point instead of the formation's own lateral midpoint (the old centring pushed outer vehicles past the navigation map edge, where they reported HOLD short of their slot); the vehicle navigation grid limit (500 x 500 sim = world +-25 m) is now an encoded placement rule; the group order runs through the mouse wrapper so the screen->ground raycast is exercised; and the driver freezes live input, asserts navigation bounds and prints a settle watchdog. A fresh Window 03 session with no prior context re-verified and returned REVISION2_VERDICT=PASS with both conditions CLOSED, after re-running the driver (exit 0, byte-identical evidence JSON), re-deriving the geometry under both the declared and the worst-case yawed-hull reading, inspecting all five frames, and re-running the same-renderer CI comparison.
EVIDENCE=Product commits 0225e11 (revision 2 code + evidence), cf81bb2 (revision-2 CI comparison: 4.5635% delta vs revision 1's 23.6356%, protected regions 0.00%), 3abbf59 (re-audit recorded) + e511eb1 (revision-2 re-audit text); CI runs 35488489417 and 35492164998 both success. Revision-2 numbers: click 1 -> 1 selected, box -> 4, 4 x order accepted=true, minimum advance 7.460 m, frontage 6.500 -> 8.000 m = max(8.0, 6.5), lateral order preserved, settled x -0.875/7.125/15.125/23.125 at z -19.375 inside the nav map.
IMPACT=ACTIVE_BRANCH_VERIFIED_HEAD moves to e511eb1. Gate D2 is closed; GATE_D2_PASS is recorded. Candidate next routes for Window 00 / the user: human playtest checkpoint (real mouse input is the one thing no driven evidence covers) or Gate D3 (RED force and victory conditions). Note for the next gate: the mechanism that deleted the local product branch ref four times during this work has now been identified — the Codex Windows sandbox service (codex-windows-sandbox-service) intercepts writes to .git/refs, so git update-ref and git commit return 0 while the ref never lands on disk. Recovery: write the ref file under .git/refs/heads/ directly, then confirm with git show-ref. Commits and reflogs survive and the remote was always correct; prefer SHA-based pushes and re-check refs/heads after any local commit in this repository.
RELATED_ISSUE_OR_PR=#41

## 2026-09-20 — Gate D2 re-audit text rescued from the worktree; acceptance-citation policy

DATE=2026-09-20
DECISION_ID=FRONTLINE_GATE_D2_REAUDIT_TEXT_COMMITTED_V1
STATUS=CLOSED
DECISION=The Window 03 revision-2 re-audit body ("REVISION 2 — RE-AUDIT AFTER BOTH CONDITIONS CLOSED", 133 lines, verdict PASS) was written into the product worktree after 3abbf59 had already recorded the outcome, and was left uncommitted. Because the control state cited that re-audit as the closure evidence, the committed report body did not contain the conclusion the control head referenced — the cited text existed in exactly one working tree and in no commit. The text is now committed as product e511eb1 (parent 3abbf59) and pushed, and the main control references are updated to it.
EVIDENCE=Product commit e511eb1 (133 insertions, 0 deletions, docs/current/GATE_D2_INDEPENDENT_AUDIT_V1.md); remote refs/heads/product/frontline-high-fidelity-slice-v1 = e511eb1 (verified by git ls-remote after push); local product ref recovered after the sandbox interception described in the entry above.
IMPACT=ACTIVE_BRANCH_VERIFIED_HEAD remains e511eb1. Two standing rules recorded for the next gates. (1) Acceptance-citation rule: a gate outcome must not be recorded as a control-head citation while the report text carrying that outcome is still uncommitted — commit the report in the same step that records the outcome. (2) Read-path rule: this repository's control documents exist as duplicate per-branch copies (docs/current/CURRENT_STATE.md is main V44 and product V22 simultaneously, both declaring SOURCE_OF_TRUTH=THIS_FILE), so a window working in the product worktree reads a stale control state and never sees the main authority; the product copy is to be reduced to a pointer at the main authority.
RELATED_ISSUE_OR_PR=#41
