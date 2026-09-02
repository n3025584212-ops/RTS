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
IMPACT=Battle01 production remains paused. Discovery must define a clearer command interaction and build enough playable substance before further product judgment.
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

## 2026-09-03 — Defer player-experience judgment until minimum playable readiness

DATE=2026-09-03
DECISION_ID=FRONTLINE_MINIMUM_PLAYABLE_BEFORE_HUMAN_EXPERIENCE_V1
STATUS=ACCEPTED
DECISION=FRONTLINE must stop treating Codex/automation as simulated human players and stop repeatedly asking for player-experience judgments while the game is still too thin to support meaningful evaluation. Technical verification, minimum playable readiness and real human product evidence are separate layers.
EVIDENCE=User explicit process correction: repeated simulated-human testing is not useful when the game itself is not yet sufficiently developed.
IMPACT=Issue #20 is re-scoped to BUILD_PROTOTYPE_B_MINIMUM_COHERENT_PLAYABLE_V1. WINDOW_02 becomes active for minimum-playable construction. Human experience testing occurs only after a coherent objective/action/opposition/consequence/feedback/result loop exists. Codex simulated human play is invalid evidence.
RELATED_ISSUE_OR_PR=#20
