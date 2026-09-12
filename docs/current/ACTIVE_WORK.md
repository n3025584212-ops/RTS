# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
ACTIVE_ISSUE=#39
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## 当前任务本质

当前不是分别研究“地图、单位、AI、材质、VFX、镜头”。

Window 01 的核心学习主线是把这些东西串成一条完整因果链：

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

外部成熟 RTS 用来提供真实证据和反例；FRONTLINE 自己的代码、场景、失败实机用来建立当前实现图谱和问题证据。

目标是回答：

> 一个玩家最终看到和感受到的战争画面，前面到底经过了哪些数据、系统、行为、状态和反馈链？当前 FRONTLINE 的每一条关键连接究竟存在、缺失、重复、错误，还是未知？

---

## 01窗口必须逐层建立证据的13层

1. 地图怎么加载；
2. 单位数据从哪里来；
3. 模型 / 材质如何绑定；
4. 玩家怎么选单位；
5. 点击命令走到哪里；
6. 寻路怎么执行；
7. 如何发现 / 选择目标；
8. 伤害怎么产生；
9. AI怎样下命令；
10. UI怎样拿到状态；
11. 动画 / VFX / 声音怎样反馈；
12. 镜头怎样呈现；
13. 最后玩家看到什么。

禁止把十三层写成十三篇互不连接的知识笔记。

---

## 证据记录格式

每一个关键连接都必须记录：

- `CLAIM`
- `CHAIN_LAYER / EDGE`
- `SOURCE`
- `SOURCE_VERSION`
- `STATUS=OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- `WHAT_THE_SOURCE_ACTUALLY_PROVES`
- `WHAT_IT_DOES_NOT_PROVE`
- `FRONTLINE_CURRENT_IMPLEMENTATION`
- `EXTERNAL_REFERENCE_IMPLEMENTATION`
- `GAP`
- `REPRODUCTION_REQUIRED=YES|NO`

---

## 当前参考证据

PRIMARY_REFERENCE=0_AD_RELEASE_28
SECONDARY_VALIDATOR_A=BEYOND_ALL_REASON_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

0 A.D. 是第一条真实链的主要可检查教材，不是 FRONTLINE 模板，也不是“RTS标准答案”。

重要版本警报：`0ad/0ad` GitHub 仓库已归档并注明源码在 2024-08-20 迁往 Wildfire Games Gitea。因此 GitHub `master` 默认只能作为历史证据；任何声称证明 Release 28 / 2026 当前实现的源码结论，都必须证明版本匹配。

BAR/Recoil、Warzone 用于主动寻找反例，不只是做确认样本。

---

## 四窗口当前分工

### 00 — 中控 / 整合
维护一份状态、一条主线和 Issue #39；决定何时允许01结果进入02复现、何时允许复现结果迁回 FRONTLINE。

### 01 — 证据 / 学习
ACTIVE。

沿13层建立完整证据图谱，第一阶段先追一个真实 playable chain，同时映射 FRONTLINE 当前/历史实现。

### 02 — 复现 / 施工
STAGED。

当01给出一条足够具体的链后，在 learning branch 做小而完整的真实复现：

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

02必须能指出失败属于哪一层或哪一条连接，不能只说“画质不好/AI不好”。

### 03 — 独立审核 / 反证
ACTIVE。

严格执行：`docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`

03不是复述01，而是审核“证据 -> 事实 -> 推论”是否越界。每条重要结论必须经过六项检查：

1. `PRIMARY_SOURCE_INTEGRITY`：是否拿二手文章冒充源码证据；
2. `VERSION_IDENTITY`：项目/仓库/tag/commit/日期是否匹配；
3. `RUNTIME_SEMANTICS`：代码存在是否真的等于运行时走这条链；
4. `GENERALIZATION_BOUNDARY`：是否从项目事实越界成 RTS 通则；
5. `ALTERNATIVE_EXPLANATIONS`：是否主动寻找竞争解释；
6. `COUNTEREXAMPLE_SEARCH`：BAR/Recoil、Warzone 或其他成熟项目是否构成反例。

03对结论使用：
`SOURCE_FACT -> PROJECT_SPECIFIC_INFERENCE -> CROSS_PROJECT_PATTERN -> DESIGN_RECOMMENDATION -> UNSUPPORTED_GENERALIZATION`

03判定使用：
`PASS | DOWNGRADE | FIX | REJECT | UNKNOWN`

之后审核02时，同样区分：代码存在、代码执行、状态变化、表现反馈、PLAYER实际看到结果。

---

## 当前禁止事项

- 不继续旧 Golden Scene 盲调；
- 不继续扩 Formation / AI 作为独立系统工程；
- 不把某一个参考工程的实现提升成 RTS 普遍规律；
- 不用 archived/错误版本源码证明当前实现；
- 不从类/组件存在直接推出完整运行调用链；
- 不生成新的幻想目标图来替代生产知识；
- 不用节点数、文件数、CI PASS 或代码存在证明最终体验；
- 不允许用流畅文字填补 UNKNOWN 链路。

---

## Sprint 01 完成条件

只有同时满足以下条件才 PASS：

1. 至少一条真实 playable chain 被从内容/数据追到 PLAYER 层；
2. 十三层之间的重要连接有来源、版本和证据等级；
3. UNKNOWN 被明确保留，没有脑补桥梁；
4. 03完成六项硬审计并把越界结论降级/打回；
5. 02在不同内容上独立复现一条小而完整的运行链；
6. 实物有真实运行、截图/录像和操作证据；
7. 03完成实物反证和复现审核；
8. 00能根据证据图谱明确判断 FRONTLINE 当前差距属于哪一层或哪些跨层连接；
9. 只有经过支持/复现的方法才进入 FRONTLINE transfer decision。

完成前：`PRODUCT_PRODUCTION_RESUME=NO`。
