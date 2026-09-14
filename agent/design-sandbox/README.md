# AGENT DESIGN SANDBOX

STATUS=AGENT_SANDBOX_NON_AUTHORITY
CREATED=2026-09-14
AUTHORIZED_BY=USER_DIRECT_INSTRUCTION(2026-09-14)
BRANCH=agent/design-sandbox-01
AUTHORITY=NONE
PRODUCT_TRUTH_CLAIMS=FORBIDDEN

## 这个区域是什么

用户于 2026-09-14 直接指示:在不打扰源库的前提下开辟一块 agent 专属区域,只依据仓库中的历史方向文件(不含学习系统)检验"现在可不可做游戏设计"。

本区域只新增文件,不修改 main 上的任何现有文件、状态或权威文档。

## 规则

- 本区域一切产出 = PROPOSAL / HYPOTHESIS。按宪章权威顺序(charter §2),未经用户接受,不构成产品事实。
- 所有设计判断必须引用历史方向文件作为依据;无依据处标 UNKNOWN。
- 不选择 roadmap;不宣称 fun/产品方向已证明(宪章 §9)。
- 本区域不是 CURRENT_STATE,不与 docs/current/ 竞争事实权。

## 文件

- `DESIGN_DIRECTION_AUDIT_V1.md` — 历史方向中的游戏设计审计:已接受/开放/受限三清单 + "可不可设计"判定
- `CORE_LOOP_HYPOTHESES_V0.md` — 在已接受约束内重建核心指挥循环的首批假设(HYPOTHESIS,待真人游玩判定)

## 与源库的边界

- main、docs/current/、学习分支:未触碰,本分支从 main HEAD 9f21313 分出,仅追加 agent/ 目录。
- 若未来用户或项目总控认可本区域产出,应显式迁移到权威位置;本区域不自动升级为权威。
