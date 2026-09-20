# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》
ROLE=POINTER_ONLY

This file does not state the project status. Exactly one file does:
`docs/current/CURRENT_STATE.md`.

如果刚打开仓库、聊天窗口断档、上下文超限，或者怀疑"高质量画面/项目状态丢了"，
不要从旧 Issue、旧 PR 或聊天记忆猜状态。

## 强制恢复顺序

先读 main：

1. `docs/current/CURRENT_STATE.md` — 唯一控制状态（stage / gate / window / head 都在这里）
2. `docs/current/VISUAL_QUALITY_BASELINE.md`
3. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

然后：

4. 按 `CURRENT_STATE.md` 指定的 active branch 刷新该分支最新 HEAD；
5. 读取当前 task / audit / handoff；
6. 只有完成上述步骤后，才读历史分支和旧 Issue。

**指向规则：本文件与 `ACTIVE_WORK.md` 只做指向，不重复状态。**
任何文件若声称了 `CURRENT_STATE.md` 里没有的当前状态（阶段 / gate / window / head），
一律按过期处理并在回复里报告，而不是照抄。

## 必须同时回答两个问题

任何恢复窗口都必须同时知道：

`CURRENT_TASK` — 当前正在施工/验证什么？

`VISUAL_QUALITY_BASELINE` — FRONTLINE 当前不能遗忘的最高视觉目标和保留实机参考是什么？

这两个不是同一个东西。

最新 Sprint01 截图/视频属于 `LEARNING_AND_RUNTIME_EVIDENCE`。它不是 FRONTLINE 当前最高视觉画面，
也不能因为时间最新就覆盖旧的高质量实机参考。

## 权威划分

`main`：阶段、任务、窗口路由、产品恢复权威、视觉基线索引。

active branch：施工、runtime、截图/视频与审核产物（分支名由 `CURRENT_STATE.md` 指定）。

路由与产品权威只来自 main / Window 00。

## 视觉质量基线

正式视觉目标：
`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`

视觉连续性索引：
`docs/current/VISUAL_QUALITY_BASELINE.md`

保留的真实引擎参考：
- `dev/river-town-local-high-fidelity-v1`
- `dev/godot-golden-scene-v1`
- `dev/reference-region-v1`

这些旧分支不恢复为产品方向权威，但其高质量实机画面、资产和工具不会再被当前学习场遮蔽。
