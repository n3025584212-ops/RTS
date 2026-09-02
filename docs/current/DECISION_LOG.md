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
IMPACT=Battle01 production remains paused. Discovery must define one clearer repeated player decision before more gameplay implementation.
RELATED_ISSUE_OR_PR=#17

## 2026-09-02 — GPT multi-window collaboration system

DATE=2026-09-02
DECISION_ID=FRONTLINE_GPT_MULTI_WINDOW_SYSTEM_V1
STATUS=ACCEPTED
DECISION=FRONTLINE enables WINDOW_00–WINDOW_08 as reusable GPT collaboration/routing contexts while retaining one shared CURRENT_STATE and one product authority chain.
EVIDENCE=User explicit decision to establish a GPT multi-window system + docs/GPT_MULTI_WINDOW_SYSTEM_V1.md.
IMPACT=Separate ChatGPT conversations may specialize in integration, game design, architecture, gameplay, AI, UX, QA, presentation and repository operations. Window numbers are routing labels only; they do not create independent project states, roadmaps, freeze rights or mandatory handoff chains.
RELATED_ISSUE_OR_PR=
