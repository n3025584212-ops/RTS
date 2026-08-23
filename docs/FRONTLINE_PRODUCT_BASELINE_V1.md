# FRONTLINE_PRODUCT_BASELINE_V1

## Product

FRONTLINE / 《战线》是一款现代战争题材、俯视斜视角、以 Formation / Platoon 级战场指挥为核心的实时战术 / RTS 游戏。

玩家幻想是“战场指挥官”，不是逐兵微操员，也不是传统采矿爆兵型基地建造者。

## Core experience

侦察与不完整信息 → 路线/兵力判断 → 联合兵种接敌 → 火力塑造/机动突破 → 目标争夺 → 敌军反击 → 补给/增援/撤退/保存战力 → 最终夺控战场。

## Product gate

- PLAYABLE
- MEANINGFUL_DECISIONS
- VISUAL_READABILITY
- TARGET_ALIGNMENT
- TECHNICAL_HEALTH

任一核心维度失败，不能以单项系统测试 PASS 覆盖。

## Visual direction

重启后的核心产品目标参考为四类画面：

1. 完整战斗HUD/总体战场
2. 中景高强度交火
3. Camp购买/部署流程
4. Battle01战术地图/Minimap

不要求像素复刻，但信息结构、现代战争氛围、战场密度、Formation识别与指挥感必须保持同一产品方向。

## Default scope exclusions for Battle01

首阶段默认不做：

- 完整 Deck Builder
- 科技树/工人采集/战略工业
- 多地图战役
- 多人联机
- 飞机/直升机/SEAD/EW
- 几十种单位
- 复杂车辆故障模拟
- LLM/ML 敌AI

## Project operating model

- Godot fixed version: 4.7.1
- GitHub repository is the source of truth for code and project files.
- The deleted previous local project is not inherited.
- GPT cloud windows 00–08 retain design/review ownership by domain.
- Codex/Qwen/other coding agents are temporary construction executors, not project authorities.
- Project-wide design-to-implementation, implementation freedom, acceptance authority, minimum-sufficient-evidence, risk-scaled audit, anti-over-audit, and project hygiene/retention rules are defined by `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`.
- All registered FRONTLINE windows and external construction executors inherit that governance by default unless Window 00 explicitly freezes a narrower task-specific override.
- Project hygiene is system-wide mandatory: default cleanup instead of indefinite retention; Git history is the primary recovery mechanism; redundant backups, stale temporary branches, reproducible caches/builds, obsolete CI artifacts, and duplicate evidence must not be accumulated without a specific retention reason.
