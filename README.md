# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态

- Engine: Godot 4.7.1
- Current phase: `P0_DISCOVER`
- Battle01 production: `PAUSED`
- Source of truth: `docs/current/CURRENT_STATE.md`
- Active task: GitHub Issue #20 — Prototype B representative command-battle slice
- GPT collaboration: four-window shared-state runtime

## 开始阅读

1. `docs/current/CURRENT_STATE.md` — 唯一当前项目状态
2. `docs/FRONTLINE_PROJECT_CHARTER_V3.md` — 项目最高运行规则
3. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md` — 日常项目系统
4. `docs/GPT_MULTI_WINDOW_SYSTEM_V2.md` — 四窗口协作规则
5. `docs/GPT_WINDOW_RUNTIME_PLAN_V1.md` — 窗口启用/待命/证据门运行方案
6. `docs/gpt_windows/` — 四个可直接复制的 ChatGPT 初始化指令
7. `docs/current/DECISION_LOG.md` — 项目决策历史
8. 当前 Active Issue — 当前工作的合同与证据线程

明确过时/废弃的历史资料统一保存在 `archive/legacy-unused` 分支；该分支没有当前产品权威。

## GPT 四窗口

```text
00  Project Control / Integration   项目总控、状态整合、冲突裁决
01  Design / Experience             游戏设计、UX/UI、玩家体验与战斗结构
02  Development                     Godot、Gameplay、Combat、Units、AI、实现
03  Review / Operations             QA、Playtest Evidence、PR/CI、GitHub运维
```

### 当前 P0 运行状态

```text
WINDOW_00 = ACTIVE
WINDOW_01 = ACTIVE_BATTLE_AND_COMMAND_DESIGN
WINDOW_02 = ACTIVE_REPRESENTATIVE_SLICE_BUILD
WINDOW_03 = STANDBY_ON_DEMAND
```

不是四个窗口全部同时制造工作。00 常驻；01/02 当前围绕同一个代表性战斗切片工作；03 在有实质构建或审查对象时进入。

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

当前阶段不再用几个盒子、一次接触、一个孤立决策来代表整款 RTS。Prototype B 必须形成一个具有持续指挥负荷的代表性灰盒战斗：多个责任区/战场需求、敌军主动变化、局部自主执行、预备力量或未投入战力、再任务、战斗后果与持续结果流。精确单位数量、地图尺寸和时长保持软定义。

只有当这种代表性战斗已经实际运行，才进入有意义的真人产品体验判断。Codex/自动化只负责技术验证，不模拟真人。
