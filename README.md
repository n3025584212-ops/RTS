# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态入口

1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. `docs/current/VISUAL_QUALITY_BASELINE.md`
5. `docs/current/WINDOW_RECOVERY_INDEX.md`

## 当前任务

Active Sprint：`LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION`

Current gate：`SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_FIX`

当前窗口：
- `00 = ACTIVE_CONTROL`
- `01 = HOLD_STAGE4_COMPLETE`
- `02 = ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX`
- `03 = HOLD_PENDING_TRANSPORT_TERRAIN_RERUN`

当前唯一阻断：
`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

Sprint01 的截图/视频是学习与 runtime 证据，不等于 FRONTLINE 当前最高视觉质量。

## 视觉质量基线

正式产品视觉目标仍是：
`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`

视觉连续性与保留高质量实机参考见：
`docs/current/VISUAL_QUALITY_BASELINE.md`

保留参考：
- River Town local high fidelity；
- Golden Scene V1；
- Reference Region asset/tool pool。

它们不恢复成旧产品方向，但也不会再因为当前学习场较新而被视为“丢失”。

## 下一步

`02 transport-terrain fresh runtime -> 03 visual re-audit -> 00 Sprint01 transfer decision`

Sprint01 通过后，启动第一个重启后的正式 FRONTLINE 产品局部：采用 Sprint 验证的方法，同时从一开始以 Golden Frame / retained high-quality engine references 为视觉交付边界。

`SPRINT_PASS=NO`
`PRODUCT_PRODUCTION_RESUME=NO`
