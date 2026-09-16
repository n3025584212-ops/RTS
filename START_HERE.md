# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》

如果你刚打开仓库、聊天窗口断档、上下文超限，或者怀疑“库里信息丢了”，不要从旧 Issue、旧 PR、旧 Battle01 文档或聊天记忆自行猜状态。

## 强制恢复顺序

1. `docs/current/CURRENT_STATE.md`
2. `docs/current/ACTIVE_WORK.md`
3. `docs/current/WINDOW_RECOVERY_INDEX.md`
4. `docs/current/RESTART_DECISION.md`
5. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

然后：

6. 刷新当前 branch HEAD；
7. 读取 `WINDOW_RECOVERY_INDEX.md` 列出的 Sprint 关键产物；
8. 之后才读取代码、资产、历史分支或旧 Issue。

## 控制面 / 执行面

`main` = 控制面：阶段、任务、路由、产品恢复权威。

`learning/sprint01-end-to-end-rts-production` = Sprint 01 执行面：证据、审核、复现、runtime blocker/evidence。

这个文件在 learning 分支保留镜像，目的是防止窗口 checkout 到活动分支后又读到旧项目状态。

若两边冲突：
- 实现/运行事实看 active branch；
- 路由/产品权威看 main / Window 00；
- 任何窗口不得自行把 branch 结果升级成产品恢复。

## 当前四窗口

- `00`：ACTIVE_CONTROL
- `01`：HOLD_STAGE4_COMPLETE
- `02`：ACTIVE_RUNTIME_GATE
- `03`：HOLD_PENDING_FRESH_RUNTIME

## 当前唯一下一步

运行已经构建好的：

`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn`

要求 fresh Godot 4.7.1 + exact sanctioned assets + real input + fresh logs/screenshots/video。

当前 hosted attempt 在 runner 分配前失败，不是 gameplay PASS/FAIL。

具体看：
- `docs/current/CURRENT_STATE.md`
- `docs/current/ACTIVE_WORK.md`
- `docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

## 历史边界

Battle01、Prototype B、Golden Scene、River Town、Reference Region、local-high-fidelity branches 都只是历史证据/工具池，不自动拥有当前产品方向权威。
