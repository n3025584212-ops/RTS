# LEARNING SPRINT 01 — End-to-End RTS Production Reconstruction Contract

STATUS=READY
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Goal

不是分别研究地图、AI、材质、战斗、UI或画质，而是建立并验证一条从 CONTENT 到 PLAYER 的完整生产链。

宏观链：

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

## Stage 1 — Build one version-correct real chain

Window 01选择一个最简单但完整的真实RTS事件，从玩家操作追到最终PLAYER层，并向上追溯地图、单位数据、资产绑定。

当前第一参考：0 A.D. Release 28。

重要限制：归档的 `0ad/0ad` GitHub mirror 默认只能作为历史证据。任何声称证明 Release 28 / 2026 当前实现的源码结论，必须证明版本匹配并使用可追溯的权威源。

必须覆盖13层：
1. map loading / battle space;
2. unit data source of truth;
3. model/material/asset binding;
4. player selection;
5. command routing;
6. pathfinding/movement;
7. detection/targeting;
8. fire/hit/damage/death;
9. AI command generation;
10. UI state acquisition;
11. animation/VFX/audio;
12. camera/render;
13. final player-visible result.

## Stage 2 — Window 03 falsification in parallel

Window 03不等待01写完，立即按六项硬检查审核每个重要结论：

1. PRIMARY_SOURCE_INTEGRITY
2. VERSION_IDENTITY
3. RUNTIME_SEMANTICS
4. GENERALIZATION_BOUNDARY
5. ALTERNATIVE_EXPLANATIONS
6. COUNTEREXAMPLE_SEARCH

03必须把结论区分成：
- SOURCE_FACT
- PROJECT_SPECIFIC_INFERENCE
- CROSS_PROJECT_PATTERN
- DESIGN_RECOMMENDATION
- UNSUPPORTED_GENERALIZATION

03判定：
- PASS
- DOWNGRADE
- FIX
- REJECT
- UNKNOWN

BAR/Recoil、Warzone 2100或其他成熟项目用于主动寻找反例，而不只是确认01的结论。

## Stage 3 — Map the same edges onto FRONTLINE

01只在有实际证据时映射 FRONTLINE 当前/历史实现。

不存在或无法证明的连接写 GAP / UNKNOWN，不允许替旧工程补解释。

## Stage 4 — Independent reproduction

02在 `learning/sprint01-end-to-end-rts-production` 上做独立小型完整复现。

最低链：

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

复现不能只证明代码存在。必须有真实环境、真实内容/资产绑定、实际运行证据，并到达PLAYER层。

## Stage 5 — Artifact review

03审核02时必须区分：
- code exists;
- code executes;
- authoritative state changes;
- presentation feedback occurs;
- player-visible result proves the tested claim.

CI green、节点数量、文件数量、隐藏问题的截图都不能替代实物结果。

## Stage 6 — FRONTLINE transfer

只有01证据、02复现、03反证三者闭合后，00才允许迁移。

`0 A.D. does X` 永远不自动等于 `FRONTLINE should do X`。

迁移必须考虑 FRONTLINE 的 Godot 4.7.1、战斗规模、AI/网络需求、性能、内容生产、维护成本、视觉和可读性目标。

## Required deliverables

1. `docs/learning/sprint01/EVIDENCE_REGISTER.md`
2. `docs/learning/sprint01/REFERENCE_SELECTION.md`
3. `docs/learning/sprint01/END_TO_END_CHAIN.md`
4. FRONTLINE chain/gap mapping
5. 03 audit records following `WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`
6. isolated reproducible scene/code under learning paths
7. actual runtime screenshots / capture evidence under `artifacts/learning/sprint01/`
8. `docs/learning/sprint01/REPRODUCTION_RESULT.md`
9. `docs/learning/sprint01/FRONTLINE_TRANSFER_DECISION.md`

## Hard rules

- model summaries are not evidence;
- secondary articles are not source-code proof;
- source/version identity is mandatory for core implementation claims;
- symbol/component existence does not prove runtime chain;
- an essay with no reproduction is FAIL;
- screenshot similarity cannot prove hidden implementation;
- one project's implementation cannot become an RTS universal rule without cross-evidence;
- UNKNOWN must remain UNKNOWN;
- no old Golden Scene blind tuning during this sprint;
- no new FRONTLINE gameplay-system expansion during this sprint;
- no semantic placeholders as final learning/product proof.

## Exit

PASS only when:
1. one real playable chain is traced from content/data to PLAYER with version-correct evidence;
2. critical edges have explicit evidence status and unknowns;
3. Window 03 completes the six-check evidence audit and fixes/downgrades unsupported claims;
4. Window 02 independently reproduces one small complete running chain on different content;
5. real player-visible runtime evidence exists;
6. Window 03 completes artifact falsification;
7. Window 00 can diagnose FRONTLINE gaps by layer/edge and transfer only supported/reproduced methods.

PRODUCT_PRODUCTION_RESUME=NO
