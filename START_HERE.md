# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》

如果你刚打开仓库、聊天窗口断档、上下文超限，或者怀疑“库里信息丢了”，不要从旧 Issue、旧 PR、旧 Battle01 文档或 README 历史段落自行猜状态。

## 强制恢复顺序

先读 main：

1. `docs/current/CURRENT_STATE.md`
2. `docs/current/ACTIVE_WORK.md`
3. `docs/current/WINDOW_RECOVERY_INDEX.md`
4. `docs/current/RESTART_DECISION.md`
5. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

然后根据 `CURRENT_STATE.md` 中的 `ACTIVE_BRANCH`：

6. 读取该分支最新 HEAD；
7. 读取 `WINDOW_RECOVERY_INDEX.md` 列出的当前 Sprint 关键产物；
8. 只有完成上述步骤后，才读取代码、资产、历史分支或旧 Issue。

## 双层状态规则

`main` = 控制面：
- 当前阶段；
- 当前唯一任务；
- 窗口路由；
- 是否允许产品恢复；
- 历史/现行权威边界。

`learning/sprint01-end-to-end-rts-production` = 当前 Sprint 执行面：
- 01证据产物；
- 03审核产物；
- 02复现场景/脚本；
- runtime evidence / blockers。

不要假设 main 会包含 learning 分支的全部施工文件。

如果两边看起来冲突：
- 施工/运行事实看 active branch；
- 路由/产品权威看 main / Window 00；
- 不能让旧 main 文档覆盖新 branch 事实，也不能让某个 branch 自行宣布产品恢复。

## 当前四窗口

- `00`：CONTROL / INTEGRATION — 唯一控制、整合、冲突裁决。
- `01`：EVIDENCE / LEARNING — 当前 Stage 4 已完成，HOLD。
- `02`：REPRODUCTION / BUILD — 当前 ACTIVE，负责 Sprint01 世界复现 runtime gate。
- `03`：INDEPENDENT REVIEW / FALSIFICATION — 当前 HOLD，等待02 fresh runtime 后审实物。

窗口编号不代表正确性。四个窗口共用一个项目状态和 Issue #39。

## 当前核心链

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

目前已通过：
- 一条真实 player causal chain；
- Stage 4 world causal decomposition；
- 03 对 world method 的独立审核（PASS_WITH_DOWNGRADES）。

当前未通过：
- 新世界复现的 fresh Godot 4.7.1 runtime；
- 新世界 PLAYER-visible artifact audit；
- Sprint 01 总 PASS；
- FRONTLINE 产品恢复。

## 当前唯一下一步

Window 02：运行已经构建好的 `Sprint01WorldReproduction.tscn`，用 fresh Godot 4.7.1 + exact sanctioned asset bytes 生成新的日志、截图和视频。

最新已知 hosted attempt 在 runner 分配前失败，不是 gameplay PASS/FAIL。

具体看：
- `docs/current/CURRENT_STATE.md`
- `docs/current/ACTIVE_WORK.md`
- active branch: `docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

## 历史边界

Battle01、Prototype B、Golden Scene、River Town、Reference Region、local-high-fidelity branches 都保留，但只是：
- 技术资产；
- 失败/实物证据；
- 可复用工具；
- 参考材料。

它们不自动拥有当前产品方向权威。
