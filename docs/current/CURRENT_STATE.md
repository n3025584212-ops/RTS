# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V14
INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
GPT_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md
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

Discovery must proceed through a representative command-battle system rather than ultra-thin mechanic demos. A small mechanism test may verify code, but it cannot stand in for an RTS battle or justify product conclusions.

---

## CURRENT_PRODUCT_QUESTION

QUESTION=
What interacting real-time command decisions and battle loop make FRONTLINE worth playing as a formation-level command game rather than as a conventional RTS with fewer units?

The earlier framing around finding exactly one repeated decision remains diagnostically useful but is too narrow as the definition of the game.

---

## ACCEPTED_TECHNICAL_FOUNDATION

M2_01_RUNTIME_SHELL=KEEP_AS_TECHNICAL_TOOLBOX
REAL_GODOT_4_7_1_VERIFY=PASS

CORE_V1_BATCH1_PR=#23
CORE_V1_BATCH1_MERGED=YES
CORE_V1_BATCH1_MERGE_COMMIT=74c40115b6942df07ffca14b81f2fdbb2261e7ab
CORE_V1_BATCH1_FINAL_REVIEW=PASS
CORE_V1_BATCH1_CI=GODOT_4_7_1_FRONTLINE_CORE_VERIFY_251_PASS

Accepted reusable Core seam includes FormationState, FormationTask, FormationAgent2D, TaskCommandService, FormationAutonomy, NavigationService and a minimal CombatResolver. TaskCommandService exposes explicit assign/retask/cancel semantics. Scenario-specific Battle01 identity remains outside Core.

This is technical architecture evidence only; it is not PRODUCT_PASS and does not freeze product gameplay semantics.

---

## CURRENT_PROTOTYPE_B_CORE_MIGRATION

PRODUCT_ISSUE=#20
TECHNICAL_TASK=#26
TECHNICAL_PR=#27
NARROW_FIX_ISSUE=#28
BRANCH=dev/prototype-b-core-v1-migration
CURRENT_HEAD=c69b6cfd045a8d2b0469ced5fe36a0c443738835
PR_STATE=OPEN
PR_MERGED=NO
PR_MERGEABLE=YES

Prototype B is materially migrated to the accepted RTS Core:
- BLUE and RED formation execution uses FormationAgent2D / FormationState / FormationAutonomy / NavigationService;
- BLUE player commands and RED scenario commander tasking share TaskCommandService;
- scenario-specific RIDGE/CROSSING/RELAY, pressure, intel/confidence, objective/control and outcome logic remain scenario-side;
- representative structure remains present: 5 BLUE including ECHO reserve, 3 sectors, 3 RED agents, reserve/retask consequences, fallback/recovery, escalation, combat consequences and outcome/restart.

Initial WINDOW_03 review at `a944fa41936f8a5e329f9083d657a9b33f1aacd8` returned PARTIAL_PASS / FIX_THEN_MERGE because Core navigation endpoint resolution could leave fallback/recovery and reserve-return lifecycle checks comparing against unreachable raw staging coordinates.

Issue #28 narrow fix is complete at `c69b6cfd045a8d2b0469ced5fe36a0c443738835`:
- CORE_CONSISTENT_STAGING_TARGET=YES
- FALLBACK_RECOVERY_RESUME_TEST=PASS
- ECHO_RESERVE_RETURN_TEST=PASS
- PROTOTYPE_B_MIGRATION_CI=PASS_RUN_4
- FRONTLINE_CORE_VERIFY=PASS_RUN_255
- REGRESSIONS=NO_BLOCKING_REGRESSION_OBSERVED
- WINDOW_02_RESULT=PASS
- MERGE=NO
- SELF_APPROVAL=NO
- PRODUCT_PASS=NO

Historical draft PR #21 remains open temporarily and must only be classified/closed as superseded after PR #27 is finally accepted; do not delete by age alone.

---

## ACCEPTED_DECISIONS

ACCEPTED:
- FRONTLINE remains a modern-warfare formation/platoon-level tactical command game project.
- High-APM unit micromanagement is not an assumed product goal.
- TECHNICAL_PASS != PRODUCT_PASS.
- Direct human play is decisive for product acceptance only after representative readiness.
- Codex/automation may perform technical verification but may not simulate or stand in for a human player.
- FRONTLINE must not be reduced to a toy mechanism demo or arbitrary small number of boxes/formations for product evaluation.
- Representative readiness is systemic, not a fixed unit-count/map-size/minutes checklist.
- The player-facing battle must create sustained command load through interacting responsibilities, changing threats and continuing consequences.
- RTS Core V1 batch 1 is accepted as reusable technical foundation on main.
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
WINDOW_01=ACTIVE_BATTLE_AND_COMMAND_DESIGN
WINDOW_02=STANDBY_AFTER_PR27_NARROW_FIX
WINDOW_03=ACTIVE_FINAL_PROTOTYPE_B_CORE_REVIEW

CURRENT_RUNTIME_REASON=
WINDOW_02 completed Issue #28 and returned PR #27 at head `c69b6cfd045a8d2b0469ced5fe36a0c443738835` with both required lifecycle tests and both Godot 4.7.1 CI gates passing. WINDOW_02 must not continue implementation unless WINDOW_03 finds a concrete remaining blocker. WINDOW_03 now performs final independent review of PR #27 for the staging-arrival fix, regression evidence, scope containment and merge readiness.

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

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=BUILD_PROTOTYPE_B_REPRESENTATIVE_COMMAND_BATTLE_SLICE_V1
ACTIVE_ISSUE=#20
ACTIVE_ISSUE_URL=https://github.com/n3025584212-ops/RTS/issues/20

CURRENT_TECHNICAL_INTEGRATION=FINAL_REVIEW_PROTOTYPE_B_CORE_MIGRATION_PR27
TECHNICAL_TASK=#26
TECHNICAL_FIX_ISSUE=#28
TECHNICAL_PR=#27
TECHNICAL_REVIEW_HEAD=c69b6cfd045a8d2b0469ced5fe36a0c443738835

MERGE=NO
SELF_APPROVAL=NO
PRODUCT_PASS=NO

---

## BLOCKERS

CURRENT_PRODUCT_BLOCKERS:
1. FRONTLINE still has not passed representative command-battle readiness for direct human judgment.
2. The interaction among command responsibilities, formation autonomy, enemy reaction, information and reserves remains unproven as a product experience under sustained battle load.
3. The game must demonstrate that higher-level command reduces babysitting without making the player passive.

CURRENT_TECHNICAL_INTEGRATION_BLOCKER:
- PR #27 merge is gated only by WINDOW_03 final independent review at head `c69b6cfd045a8d2b0469ced5fe36a0c443738835`; no known implementation or CI blocker remains after Issue #28.

---

## NEXT_DECISION

NEXT=WINDOW_03_FINAL_INDEPENDENT_REVIEW

Required sequence:
1. WINDOW_03 independently reviews PR #27 at the fix head.
2. If PASS / MERGE: WINDOW_00 merges PR #27, closes #26/#28, and classifies/closes historical draft PR #21 as superseded without deleting it.
3. If another concrete blocker is found: WINDOW_02 fixes that blocker only and returns to review; do not expand scope or shrink the representative battle.
4. After accepted migration, continue building the representative command battle rather than treating architecture cleanliness as product completion.
5. Only after representative readiness does the user directly play and judge the game.

ONE_PRIMARY_PRODUCT_QUESTION=YES
ONE_PRIMARY_ACTIVE_TASK=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
