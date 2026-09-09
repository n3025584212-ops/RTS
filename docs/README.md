# FRONTLINE documentation map

> 当前文档入口只认 **current system versions**。旧版本已归档，不应继续从 main 作为当前规则读取。

## 当前权威层

```text
USER EXPLICIT DECISION
        ↓
docs/current/CURRENT_STATE.md
        ↓
docs/FRONTLINE_PROJECT_CHARTER_V3.md
        ↓
docs/FRONTLINE_PROJECT_SYSTEM_V2.md
        ↓
approved design / active Issue / current runtime evidence
```

### 当前协作系统

- `GPT_MULTI_WINDOW_SYSTEM_V3.md`
- `GPT_WINDOW_RUNTIME_PLAN_V2.md`
- `gpt_windows/`

### 当前设计入口

- `design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md` — 当前 approved Golden Frame 实现权威。
- `design/FRONTLINE_PRODUCTION_DESIGN_PACKAGE_V1.md` — Golden Frame 的支持性父包；以 Golden Frame spec 和 CURRENT_STATE 为准。
- `design/FRONTLINE_PRODUCTION_TECHNICAL_LAYOUT_V1.svg` — 空间/技术布局支持材料。
- `current/VISUAL_PRODUCTION_RESET_V1.md` — 旧视觉目标废止记录。

## 仓库运维入口

- `ops/REPOSITORY_MAP.md` — 人类可读的目录/分支/工作流地图。
- `ops/BRANCH_CLEANUP_REGISTER_20260909.md` — KEEP / ARCHIVE / REMOVE / HOLD 分支清单。

## 历史资料

明确 superseded 的治理和旧窗口系统保存在 `archive/legacy-unused` 分支。该分支没有当前产品权威。

当两个文件冲突时：优先 `CURRENT_STATE.md`，不要因为旧文件名里有 PASS / FROZEN / V1 就恢复旧规则。
