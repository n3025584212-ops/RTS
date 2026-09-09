# FRONTLINE GPT windows

这些文件是四个 ChatGPT 路由窗口的可复制初始化入口。它们**不是四个独立项目**，也不拥有独立 CURRENT_STATE。

## 四窗口

| Window | 作用 |
|---|---|
| 00 | Project Control / Integration：总控、状态整合、冲突裁决 |
| 01 | Design / Experience / Visual Production Definition：设计、体验、实现级视觉定义 |
| 02 | Development / Asset Integration / Gameplay Production：Godot、资产、Gameplay、AI、生产实现 |
| 03 | Independent Review / Operations / Design Compliance：QA、PR/CI、仓库运维、设计符合性 |

## 每个窗口先读

1. `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
2. `docs/FRONTLINE_PROJECT_SYSTEM_V2.md`
3. `docs/GPT_MULTI_WINDOW_SYSTEM_V3.md`
4. `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md`
5. `docs/current/CURRENT_STATE.md`
6. CURRENT_STATE 指向的 Active Issue / PR
7. 仅按任务需要读取相关代码、运行证据和历史材料

## 运行状态规则

**不要在这里硬编码“哪个窗口当前 ACTIVE”。** 当前运行状态随项目变化，只读取 `docs/current/CURRENT_STATE.md` 的 `GPT_WINDOW_RUNTIME`。

## 共享状态规则

- WINDOW_00 默认负责材料性 CURRENT_STATE 更新。
- 01/02/03 只有在用户或当前任务明确授权时修改 CURRENT_STATE。
- 不做强制聊天回执链。
- 结果优先落在 Issue、branch/PR、代码、测试、CI 和 runtime evidence。
