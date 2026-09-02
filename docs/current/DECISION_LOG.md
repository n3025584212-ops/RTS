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
