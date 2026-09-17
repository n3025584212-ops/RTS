# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT_MIRROR
PROJECT=FRONTLINE《战线》
CONTROL_AUTHORITY=main

如果从 learning 分支直接进入仓库，先回看 main 的控制文件，不要把 learning 分支最新截图当成 FRONTLINE 当前最佳视觉画面。

## 强制恢复顺序

1. `main:docs/current/CURRENT_STATE.md`
2. `main:docs/current/ACTIVE_WORK.md`
3. `main:docs/current/VISUAL_QUALITY_BASELINE.md`
4. `main:docs/current/WINDOW_RECOVERY_INDEX.md`
5. 刷新本分支最新 HEAD
6. 读取当前 task/audit/handoff

## 当前任务

CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_FIX
ACTIVE_TASK=REPAIR_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V1
TASK=docs/learning/sprint01/TASK_02_TRANSPORT_TERRAIN_INTEGRATION_FIX_V1.md

当前窗口：
- `00 = ACTIVE_CONTROL`
- `01 = HOLD_STAGE4_COMPLETE`
- `02 = ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX`
- `03 = HOLD_PENDING_TRANSPORT_TERRAIN_RERUN`

当前唯一 Sprint 缺口：
`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

## 视觉基线不是本分支最新截图

Sprint01 的 PNG/MP4 是：
`LEARNING_AND_RUNTIME_EVIDENCE`

它们不是：
`FRONTLINE_PRODUCT_VISUAL_BASELINE`

正式视觉目标与保留高质量引擎参考由 main 的：
`docs/current/VISUAL_QUALITY_BASELINE.md`
统一索引。

旧 River Town / Golden Scene / Reference Region 不恢复为产品方向权威，但其高质量实机、资产和工具继续作为视觉连续性参考保留。

## 下一步

`02 fresh transport-terrain integration runtime -> 03 REAL_ENOUGH_WORLD_DELIVERY re-audit -> 00 Sprint01 final decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
