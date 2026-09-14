# FRONTLINE DESIGN DIRECTION AUDIT V1 — 可不可设计

STATUS=AGENT_SANDBOX_PROPOSAL
AUTHORITY=NONE
DATE=2026-09-14
SCOPE=历史方向文件中的游戏设计(按用户 2026-09-14 指示,不含学习系统)
METHOD=只使用仓库内历史文档;每条判断附文件依据;无依据处标 UNKNOWN

INPUT_DOCS:
- docs/FRONTLINE_PROJECT_CHARTER_V3.md
- docs/current/DECISION_LOG.md
- docs/current/RESTART_DECISION.md
- docs/design/FRONTLINE_PRODUCTION_DESIGN_PACKAGE_V1.md
- docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md
- docs/current/VISUAL_PRODUCTION_RESET_V1.md
- docs/ops/REPOSITORY_MAP_V2.md
- docs/current/CURRENT_STATE.md (V31)

---

## 0. 结论

CAN_DESIGN=YES_WITH_SCOPE

游戏设计不是从零开始:历史方向文件已经接受了一批足够具体的设计地基——做什么游戏、什么指挥语言、什么可读性标准、什么内容形状、什么视觉质量门。当前真正的设计空白只有一处大的:核心指挥循环(Command & Response 于 2026-09-02 被重开后无人重建),外加一份已写成但从未获批准的生产设计包。

可设计的部分与不可设计的部分见 §3。

## 1. 已接受层(可直接作为设计输入)

| # | 设计事实 | 状态 | 依据 |
|---|---|---|---|
| A1 | 产品 = 现代战争、编队/排级指挥实时战术游戏 | ACCEPTED | CURRENT_STATE V31;Design Package §1-2 |
| A2 | 指挥语言 = 编队级 MOVE / ATTACK / HOLD / WITHDRAW / COMMIT RESERVE / FIRE SUPPORT / RESUPPLY;单兵微操作不是主交互 | PROPOSED(已成文未批准,无冲突记载) | Design Package §7 |
| A3 | 一眼可读性合同:玩家一帧内回答八问;UI 不替玩家回答最优解 | PROPOSED | Design Package §10 |
| A4 | 状态→表现合同(情报不确定/压制/低弹药/受损/预备队/committed/火力支援) | PROPOSED | Design Package §9 |
| A5 | 内容形状 = 代表性合成兵种指挥战斗切片:多责任区、敌军主动变化、局部自主执行、预备力量/再任务、战斗后果、持续结果流 | ACCEPTED | DECISION_LOG 2026-09-03 REPRESENTATIVE_COMMAND_BATTLE_SLICE_V1;Issue #20 |
| A6 | 视觉质量门 = Golden Frame V1,用户已批准 | ACCEPTED | Golden Frame §7(USER_APPROVED=YES, 2026-09-05);CURRENT_STATE APPROVED_VISUAL_TARGET |
| A7 | 单位家族 6 类(MBT/IFV/机步/侦察/自行火炮/后勤);精确 roster 不冻结 | 软定义 | Design Package §5 |
| A8 | 相机 = 斜指挥视角约 48°、自由 yaw、近中远三档可读性 | PROPOSED | Design Package §3 |
| A9 | 人类游玩是核心玩法发现的决定性证据;TECHNICAL_PASS != PRODUCT_PASS | ACCEPTED | Charter §10;DECISION_LOG 2026-09-03 HUMAN_PLAY_AFTER_READINESS_V1 |
| A10 | 阶段 = P0 DISCOVER:研究、纸面练习、一次性原型均合法 | ACCEPTED | Charter §5;CURRENT_STATE CURRENT_PHASE |

注:Design Package V1 整体 STATUS=PROPOSED_AWAITING_USER_APPROVAL、AUTHORITY=NONE_UNTIL_USER_APPROVES(包 §13)。因此 A2/A3/A4/A8 的真实状态是"已有成文方案,无批准";A6 是其唯一获批准的子件。

## 2. 冲突与精确状态

- 2.1 Design Package V1(2026-09-04)至今未见任何后续文档标记其获批 → 生产切片契约悬置。
- 2.2 Golden Frame V1 于 2026-09-05 获用户批准,且最新的 CURRENT_STATE V31 仍列其为 APPROVED_VISUAL_TARGET → 视觉门有效。RESTART_DECISION(2026-09-12)把 Golden Scene / River Town 的既有"工作"降级为技术资产与失败证据,但未撤销 Golden Frame 的视觉目标批准。
- 2.3 VISUAL_PRODUCTION_RESET_V1(2026-09-04)废弃 P0-01…FINAL-01 全部旧视觉图 → 完整视觉规范集不存在,当前只有单帧质量门。
- 2.4 PROTOTYPE_A_COMMAND_RESPONSE_REWORK = REOPENED(2026-09-02)→ 核心交互假设失效,无后继被接受的替代。失败证据:首次真人游玩"没看懂"(技术 PASS,产品不可读)。这是当前最大的设计空白。
- 2.5 RESTART_DECISION 七条失败模式中最切题的三条,设计工作必须内建对策:
  - 从通用理论直接跳原创设计 → 新假设必须逐条锚定在 §1 的 A 项上;
  - 语义实现被当成品 → 一切设计声明区分"设计意图"与"已验证";
  - 同一模型定义方案+验收+自评 → 每个假设自带证伪条件,判定权留给真人。
- 2.6 对抗结构从未被显式决策:全库(文档+代码)0 处提及 PvP / multiplayer / network(2026-09-14 代码搜索核实),但所有历史工件一致隐含 PvE——Design Package §2 "RED defends and counter-commits based on battlefield state"、§11 复用清单 "state-driven enemy commander work"、battle01 约 140KB enemy_ai_* 代码、13 层证据链第 9 层 AI_COMMAND_GENERATION。即:PvE 是继承下来的隐含假设,不是 ACCEPTED 决策。

## 3. 判定

### 3.1 可设计(且正是被需要的)

- D1 核心指挥循环重建:REOPENED 状态 + A5 已定义其必须满足的形状 → 这正是宪章 P0 DISCOVER 阶段的合法工作。产出形态 = 假设集 + 各自的最小证伪测试(本区域 `CORE_LOOP_HYPOTHESES_V0.md` 已产出第一版)。
- D2 生产设计包的批准推进:包已成文,缺的是用户的批准/修改决定 → 合法的设计动作 = 把包中悬而未决的 USER_DECISION 点列清,交用户拍板。
- D3 一眼可读层设计:Prototype A 的失败是"没看懂",因此任何核心循环假设必须自带 10 秒可读合同 → 可设计、必须设计。

### 3.2 不可设计(超出 agent 权限,或历史已禁止)

- X1 替代用户批准 Design Package V1 或宣称其已生效(包 §13)。
- X2 宣称任何核心循环假设为 ACCEPTED(需真人游玩证据,宪章 §7-8)。
- X3 选择 roadmap、定义产品方向(宪章 §2、§9;FINAL_PRODUCT_AUTHORITY=USER_PRODUCT_OWNER)。
- X4 把 P0-01…FINAL-01 旧视觉图当规范使用(已废弃,Visual Reset V1)。
- X5 把一次性证伪原型包装成"游戏本体"(2026-09-03 用户明确拒绝以小场景代表整款游戏)。

### 3.3 待用户决定(UNKNOWN,设计无权替答)

- U1 核心幻想:玩家应感到"从容的指挥官"还是"应接不暇的指挥官"?决定 H1-H4 的权重排序。
- U2 单局时长目标与一场战斗内预期的玩家决策密度(历史文档无任何数字)。
- U3 Design Package V1:原样批准、修改后批准、还是搁置重议?
- U4 情报不确定性是否进入核心循环第一层(决定 H2 是主循环还是调制器)。
- U5 对抗结构:PvE(AI 指挥官)还是 PvP?历史工件全部隐含 PvE(§2.6),商业参考则混合(Regiments 纯 PvE、WARNO 以 PvP 为主、Broken Arrow 双轨)。确认 PvE 应升格为显式 ACCEPTED 决策;改选 PvP 则 AI 层降级、需新增确定性模拟/网络同步/匹配等全部缺失基建,并与核心循环假设 H2 的情报设计冲突部分重议。

## 4. 一句话结论

可设计。历史方向已把"游戏是什么"和"合格标准是什么"钉得很死,把"玩家反复面对的核心决策是什么"留为唯一大空白;按宪章 P0 阶段规则,填补这个空白正是当前最合法的设计工作——产出应为待真人判定的假设集,而不是新的权威文档。
