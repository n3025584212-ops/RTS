# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》

如果刚打开仓库、聊天窗口断档、上下文超限，或者怀疑“高质量画面/项目状态丢了”，不要从旧 Issue、旧 PR 或聊天记忆猜状态。

## 强制恢复顺序

先读 main：

1. `docs/current/CURRENT_STATE.md`
2. `docs/current/ACTIVE_WORK.md`
3. `docs/current/VISUAL_QUALITY_BASELINE.md`
4. `docs/current/WINDOW_RECOVERY_INDEX.md`
5. `docs/current/RESTART_DECISION.md`
6. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

然后：

7. 刷新 `CURRENT_STATE.md` 指定的 active branch 最新 HEAD；
8. 读取当前 task/audit/handoff；
9. 只有完成上述步骤后，才读取历史分支和旧 Issue。

## 必须同时回答两个问题

任何恢复窗口都必须同时知道：

`CURRENT_TASK` — 当前正在施工/验证什么？

`VISUAL_QUALITY_BASELINE` — FRONTLINE 当前不能遗忘的最高视觉目标和保留实机参考是什么？

这两个不是同一个东西。

最新 Sprint01 截图/视频属于 `LEARNING_AND_RUNTIME_EVIDENCE`。它不是 FRONTLINE 当前最高视觉画面，也不能因为时间最新就覆盖旧的高质量实机参考。

## 当前控制面

`main`：阶段、任务、窗口路由、产品恢复权威、视觉基线索引。

`learning/sprint01-end-to-end-rts-production`：Sprint01 证据、施工、runtime、截图/视频和审核产物。

施工/运行事实看 active branch；路由和产品权威看 main / Window 00。

## 当前四窗口

- `00 = ACTIVE_CONTROL`
- `01 = HOLD_STAGE4_COMPLETE`
- `02 = ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX`
- `03 = HOLD_PENDING_TRANSPORT_TERRAIN_RERUN`

## 当前 Sprint 01

已经通过并冻结（除非出现回归证据）：
- player causal chain；
- exact Abrams/IFV binding；
- Abrams readability；
- persistent world-label removal；
- PLAYER world readability；
- capture-state alignment；
- Stage 4 / world-to-movement causal results。

当前唯一剩余边界：

`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

Window 02 只修道路/路肩/地形/路口/硬化地面/建筑植被岩石的物理整合，并重新跑 fresh Godot 4.7.1 实物。

## 视觉质量基线

正式视觉目标：
`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`

视觉连续性索引：
`docs/current/VISUAL_QUALITY_BASELINE.md`

保留的真实引擎参考包括：
- `dev/river-town-local-high-fidelity-v1`
- `dev/godot-golden-scene-v1`
- `dev/reference-region-v1`

这些旧分支不恢复为产品方向权威，但其高质量实机画面、资产和工具不会再被当前学习场遮蔽。

## 下一步

`02 fresh transport-terrain integration runtime -> 03 REAL_ENOUGH_WORLD_DELIVERY re-audit -> 00 Sprint01 final transfer decision`

Sprint01 PASS 后，启动重启后的第一个正式 FRONTLINE 产品局部：使用 Sprint 验证的方法，但从一开始就以 Golden Frame 和保留高质量引擎参考作为视觉交付边界。

`SPRINT_PASS=NO`
`PRODUCT_PRODUCTION_RESUME=NO`
