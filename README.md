# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态

- Engine: Godot 4.7.1
- Current phase: `P0_DISCOVER`
- Battle01 production: `PAUSED`
- Source of truth: `docs/current/CURRENT_STATE.md`
- Active task: GitHub Issue #20 — Prototype B core player decision
- GPT collaboration: four-window shared-state runtime

## 开始阅读

1. `docs/current/CURRENT_STATE.md` — 唯一当前项目状态
2. `docs/FRONTLINE_PROJECT_CHARTER_V3.md` — 项目最高运行规则
3. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md` — 日常项目系统
4. `docs/GPT_MULTI_WINDOW_SYSTEM_V2.md` — 四窗口协作规则
5. `docs/GPT_WINDOW_RUNTIME_PLAN_V1.md` — 窗口启用/待命/决策门运行方案
6. `docs/gpt_windows/` — 四个可直接复制的 ChatGPT 初始化指令
7. `docs/current/DECISION_LOG.md` — 项目决策历史
8. 当前 Active Issue — 当前工作的合同与证据线程

明确过时/废弃的历史资料统一保存在 `archive/legacy-unused` 分支；该分支没有当前产品权威。

## GPT 四窗口

```text
00  Project Control / Integration   项目总控、状态整合、冲突裁决
01  Design / Experience             游戏设计、UX/UI、试玩解释、玩家体验
02  Development                     Godot、Gameplay、Combat、Units、AI、实现
03  Review / Operations             QA、Playtest Evidence、PR/CI、GitHub运维
```

### 当前 P0 运行状态

```text
WINDOW_00 = ACTIVE
WINDOW_01 = ACTIVE
WINDOW_02 = STANDBY_FEASIBILITY_ONLY
WINDOW_03 = STANDBY_ON_DEMAND
```

不是四个窗口全部同时施工。00 常驻；01–03 按 `GPT_WINDOW_RUNTIME_PLAN_V1` 的触发条件启用。

这些窗口只是 GPT 分工/上下文路由，不各自拥有项目状态、路线图或冻结权。窗口间不使用强制回执链；共享成果落在 GitHub Issue、branch/PR、代码、测试和 CI 证据中。

## Repository layout

```text
project.godot                 Godot 4.7.1 project entry
scenes/                       runtime scenes
scripts/                      runtime scripts
resources/                    game data/resources
assets/                       UI and visual assets
tests/                        focused runtime/smoke verification
docs/current/                 current state + decision history
docs/gpt_windows/             four reusable GPT initialization prompts
.github/workflows/            automated runtime verification
```

## 当前开发原则

当前阶段先证明一个首次玩家能理解、可重复发生、区别于普通 MOVE/ATTACK 微操的 Formation-level 决策。核心交互没有通过直接试玩前，不恢复 Battle01 正式生产，也不以历史 PASS 自动恢复旧设计。
