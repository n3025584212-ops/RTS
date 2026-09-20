# FRONTLINE — GOVERNANCE ARCHIVE INDEX

STATUS=ARCHIVE_NON_AUTHORITATIVE
ARCHIVED_ON=2026-09-20
RULE=Nothing in this directory is authority. Do not load these files to determine current state,
current rules or current routing. They are kept so that a supersession can be traced; git history
holds the full text either way.

## Supersession chains

Project system:

- `FRONTLINE_PROJECT_SYSTEM_V1.md` → V2 → **`docs/FRONTLINE_PROJECT_SYSTEM_V3.md` (current)**

GPT collaboration / window system:

- `GPT_MULTI_WINDOW_SYSTEM_V2.md` → `GPT_MULTI_WINDOW_SYSTEM_V3.md` →
  `GPT_COLLABORATION_SYSTEM_V4.md` → `GPT_FOUR_WINDOW_SYSTEM_V5.md` →
  **retired 2026-09-20; replaced by `docs/FRONTLINE_EXECUTION_MODEL_V1.md`**

Window runtime plan:

- `GPT_WINDOW_RUNTIME_PLAN_V1.md` → `GPT_WINDOW_RUNTIME_PLAN_V2.md` →
  **retired 2026-09-20 with the window layer; no replacement**

Window initialization prompts:

- `gpt_windows/` (README + WINDOW_00–WINDOW_03) → **retired 2026-09-20; superseded by the
  four-step read path in `docs/FRONTLINE_EXECUTION_MODEL_V1.md` section 5**

Repository map:

- `REPOSITORY_MAP_V2.md` → **`docs/ops/REPOSITORY_MAP_V3.md` (current)**

## Why they were archived

All seven declared `STATUS=ACTIVE` at the same time, so a reader could not tell which one was
current — and `docs/README.md`, the directory map, pointed at the oldest links in each chain.
A window could load V1 and never see V3. They were moved rather than deleted so the chain stays
traceable.

## Also archived on the same date

`docs/current/history/` holds one-off historical decisions that were sitting in `current/`
alongside live state:

- `RESTART_DECISION.md`
- `WINDOW_RECOVERY_INDEX.md`

## Current authority set

- `docs/current/CURRENT_STATE.md` — the single control state (stage / gate / window / head)
- `docs/FRONTLINE_PROJECT_CHARTER_V3.md` — project authority and phase model
- `docs/FRONTLINE_PROJECT_SYSTEM_V3.md` — task / decision / evidence workflow
- `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md` — four-window collaboration system
- `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md` — window activation and phase runtime rules
- `docs/FRONTLINE_LEARNING_SYSTEM_V1.md` — learning-route system
- `docs/ops/REPOSITORY_MAP_V3.md` — repository navigation
- `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md` — Window 03 audit protocol
- `docs/current/VISUAL_QUALITY_BASELINE.md` — visual baseline and retained references
