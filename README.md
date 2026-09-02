# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态

- Engine: Godot 4.7.1
- Current phase: `P0_DISCOVER`
- Battle01 production: `PAUSED`
- Source of truth: `docs/current/CURRENT_STATE.md`
- Active task: GitHub Issue #20 — Build Prototype B minimum coherent playable
- GPT collaboration: four-window shared-state runtime
- Human experience gate: only after `MINIMUM_PLAYABLE_READINESS`

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
01  Design / Experience             游戏设计、UX/UI、玩家侧目标与反馈
02  Development                     Godot、Gameplay、Combat、Units、AI、实现
03  Review / Operations             QA、可玩成熟度证据、PR/CI、GitHub运维
```

### 当前 P0 运行状态

```text
WINDOW_00 = ACTIVE
WINDOW_01 = ACTIVE_TARGET_DEFINITION
WINDOW_02 = ACTIVE_MINIMUM_PLAYABLE_BUILD
WINDOW_03 = STANDBY_ON_DEMAND
```

当前重点不是反复模拟玩家体验，而是先把 Prototype B 做到最低可玩完整度。00 控范围，01 给足够施工目标，02 实际构建，03 在真实 build 出现后按需独立检查。

窗口间不使用强制回执链；共享成果落在 GitHub Issue、branch/PR、代码、测试和 CI 证据中。

## 三层证据

```text
1. TECHNICAL_VERIFICATION
   Codex / tests / CI 可执行

2. MINIMUM_PLAYABLE_READINESS
   先确认已经有目标、操作、对抗/变化、后果、反馈、持续游玩和结果闭环

3. HUMAN_PRODUCT_EVIDENCE
   只有真实用户试玩才有效
```

`CODEX_SIMULATED_HUMAN_PLAY=INVALID`

TECHNICAL_PASS 不等于 PRODUCT_PASS；但 PRODUCT_PASS 也不应该被要求在游戏尚未形成可玩闭环时提前判断。

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

先形成一个真实、连贯、可运行的小型游戏闭环，再要求真人判断玩家体验。Battle01 正式生产仍暂停；最低可玩原型中的临时实现不自动成为最终产品规则。
