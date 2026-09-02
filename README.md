# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态

- Engine: Godot 4.7.1
- Current phase: `P0_DISCOVER`
- Battle01 production: `PAUSED`
- Source of truth: `docs/current/CURRENT_STATE.md`
- Active task: GitHub Issue #20 — Prototype B core player decision
- GPT collaboration: `WINDOW_00`–`WINDOW_08` enabled under one shared project state

## 开始阅读

1. `docs/current/CURRENT_STATE.md` — 唯一当前项目状态
2. `docs/FRONTLINE_PROJECT_CHARTER_V3.md` — 项目最高运行规则
3. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md` — 日常项目系统
4. `docs/GPT_MULTI_WINDOW_SYSTEM_V1.md` — GPT 多窗口协作规则
5. `docs/gpt_windows/` — 00–08 窗口初始化命令
6. `docs/current/DECISION_LOG.md` — 已接受/重开的产品决策历史
7. 当前 Active Issue — 当前工作的合同与证据线程

已经明确过时/废弃的历史资料不留在 `main`，统一保存在 `archive/legacy-unused` 分支。该分支没有当前产品权威。

## GPT 窗口

```text
00  Project Director / 项目总控
01  Game Design / 游戏设计与产品发现
02  Technical Architecture / Godot 技术架构
03  Gameplay & Combat / Gameplay、单位、战斗
04  AI & Simulation / 敌军AI、自主执行、模拟
05  UX & UI / 交互、HUD、首次理解
06  Playtest & QA / 试玩、QA、证据
07  Visual & Audio / 视觉、动画、音频、表现
08  Repository Ops / GitHub、CI、仓库整理
```

这些窗口只是 GPT 分工/上下文路由，不各自拥有项目状态、路线图或冻结权。

## Repository layout

```text
project.godot                 Godot 4.7.1 project entry
scenes/                       runtime scenes
scripts/                      runtime scripts
resources/                    game data/resources
assets/                       UI and visual assets
tests/                        focused runtime/smoke verification
docs/current/                 current state + decision history
docs/gpt_windows/             reusable GPT window prompts
.github/workflows/            automated runtime verification
```

## 当前开发原则

当前阶段先证明一个首次玩家能理解、可重复发生、区别于普通 MOVE/ATTACK 微操的 Formation-level 决策。核心交互没有通过直接试玩前，不恢复 Battle01 正式生产，也不以历史 PASS 自动恢复旧设计。
