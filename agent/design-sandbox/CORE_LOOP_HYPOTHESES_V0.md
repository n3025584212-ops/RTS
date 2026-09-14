# CORE COMMAND LOOP HYPOTHESES V0

STATUS=HYPOTHESIS_SET_PROPOSAL
AUTHORITY=NONE
DATE=2026-09-14
PARENT_AUDIT=agent/design-sandbox/DESIGN_DIRECTION_AUDIT_V1.md
REPLACES=NOTHING(Prototype A "Command & Response" 于 2026-09-02 REOPENED,此后无人重建核心循环)
PENDING=USER_REVIEW + REAL_HUMAN_PLAY

设计输入:审计 §1 已接受层 A1/A5/A6/A9/A10。
设计禁区:审计 §3.2 X1-X5。
每个假设必须给出:反复决策、决策代价、持续来源、10 秒可读合同、最小证伪测试、杀死条件。
四个假设并列竞争,不接受"多选全部"——真人游玩一次只能先证伪一个。

---

## H1 预备队时机循环

- THE_REPEATED_DECISION = 何时、在哪一责任区投入手中最后一支未承诺力量。
- DECISION_COST = 投入早 → 其他责任区随后失守;投入晚 → 关键地形永久丢失;预备队一旦 committed 不可撤销。
- SUSTAINED_BY = 敌军分波主动变化,进攻方向不完全可预测,迫使玩家在信息不全下反复重新评估"还押着,还是投出去"。
- READABILITY_10S = 地图上各责任区显示压力状态;预备队图标+徽记;投出后徽记变 committed 并画出投入路线(依据 Design Package §9 RESERVE/COMMITTED 合同)。
- MINIMAL_FALSIFICATION_TEST = 一次性原型:1 张图、3 责任区、2-3 波敌军、1 支预备队、无资源系统;真人玩 10-15 分钟;只记录:是否出现犹豫、投入后是否表达后悔/庆幸。
- KILL_IF = 玩家预判了敌军波次使决策退化为流程;或预备队投入变成"哪里亮了点哪里",无真实取舍。
- SOURCE_ANCHOR = A5(预备力量/再任务);Design Package §7 COMMIT RESERVE。

## H2 情报置信度循环

- THE_REPEATED_DECISION = 是否在置信度不足时提前承诺兵力,或先花侦察资源/时间等确认。
- DECISION_COST = 提前承诺可能扑空或被诱离主力方向;等待确认可能错过唯一窗口。
- SUSTAINED_BY = 敌军接触在 unconfirmed/confirmed 之间摆动;侦察手段有限且占用时间。
- READABILITY_10S = last-known 虚影标记与确认实标两种视觉状态(依据 Design Package §9 CONTACT_UNCONFIRMED/CONFIRMED)。
- MINIMAL_FALSIFICATION_TEST = 在 H1 场景上叠加"敌军默认 last-known,侦察单位延时确认";记录玩家是否主动分配侦察、是否因情报误投。
- KILL_IF = 玩家无视情报状态也能稳定获胜(情报无价值);或情报状态使玩家瘫痪、拒绝决策。
- SOURCE_ANCHOR = Design Package §9;既有 intel_tracker.gd 技术资产。
- UNKNOWN = 审计 U4(用户是否要情报进第一层核心)。

## H3 责任区恶化速率管理循环

- THE_REPEATED_DECISION = 玩家同时只能亲自处理 1-2 处时,放弃哪个责任区、把哪处放给局部自主执行、放到什么程度。
- DECISION_COST = 被放任的责任区按自身恶化速度变糟;处处亲自微操则惩罚整体节奏。
- SUSTAINED_BY = 各区压力源不同步(一处遭进攻、一处缺弹药、一处需扩大战果),注意力的稀缺制造持续取舍。
- READABILITY_10S = 各区一个综合状态色(稳定/恶化/危急)+趋势箭头;编队卡显示当前自主任务(依据 Design Package §10 八问)。
- MINIMAL_FALSIFICATION_TEST = 一次性原型:三区压力以不同时钟推进,编队局部自主可延缓但不可逆转恶化;记录玩家切换注意力频率与事后"做对了/后悔了"的表述。
- KILL_IF = 各区恶化可预测且均匀,退化成周期性巡逻;或自主执行强到玩家无事可做。
- SOURCE_ANCHOR = A5(多责任区、局部自主执行);battle01 敌军状态机/趋势资产。

## H4 弹药-补给节奏循环

- THE_REPEATED_DECISION = 何时打断战斗单位的当前任务、抽后勤卡车去补给哪条线。
- DECISION_COST = 卡车被前线征用或被袭则该线断供;补给时机错 → 关键交火时火力衰减。
- SUSTAINED_BY = 持续交火消耗弹药,低弹药状态可见并削弱持续火力(Design Package §9 LOW_AMMO 合同)。
- READABILITY_10S = 编队卡低弹药警示 + 卡车路线可见(依据 Design Package §9)。
- MINIMAL_FALSIFICATION_TEST = 在 H1/H3 原型上叠加弹药消耗与 1-2 辆卡车;记录玩家是否主动规划补给、断供是否引发可见败势。
- KILL_IF = 弹药消耗慢到整场战斗无需决策;或补给退化为开局一次性的固定操作。
- SOURCE_ANCHOR = Design Package §7 RESUPPLY;既有 battle01_resupply_controller.gd 技术资产。

---

## 组合假设(候选主循环,待真人证伪)

- COMBINED_LOOP = H3 为底盘(持续的压力差异)→ H1 为高潮决策(预备队投入)→ H2/H4 为调制器(情报与补给改变 H1/H3 的信息与资源条件)。
- RATIONALE = 唯一同时满足 A5 全部六要素(多责任区/敌军主动变化/局部自主执行/预备力量/再任务/战斗后果)的候选结构。
- THIS_IS_NOT = 对整款游戏的定义(该框架已于 2026-09-03 被用户明确拒绝);仅是第一个值得做最小证伪原型的候选结构。

## 下一步(按宪章发现循环)

- 循环:QUESTION → HYPOTHESIS → MINIMUM PLAYABLE TEST → HUMAN_PLAY → KEEP / REWORK / KILL
- NEXT(USER)= 从 H1-H4 中指认(或否决)进入最小证伪原型的假设;同时回答审计 §3.3 的 U1/U2。
- THEN = 若获授权,原型为一次性证伪载体:灰盒呈现被允许,但不得作为产品交付或 Golden Scene 实现(宪章 §11;Golden Frame §6)。
