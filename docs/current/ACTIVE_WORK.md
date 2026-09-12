# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
ACTIVE_ISSUE=#39
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md

## 当前任务本质

当前不是分别研究“地图、单位、AI、材质、VFX、镜头”。

Window 01 的核心学习主线是把这些东西串成一条完整因果链：

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

外部成熟 RTS 用来提供真实证据和反例；FRONTLINE 自己的代码、场景、失败实机用来建立当前实现图谱和问题证据。

目标是回答：

> 一个玩家最终看到和感受到的战争画面，前面到底经过了哪些数据、系统、行为、状态和反馈链？当前 FRONTLINE 的每一条关键连接究竟存在、缺失、重复、错误，还是未知？

---

## 01窗口必须逐层建立证据的13层

### 1. 地图怎么加载
`Battle/Main -> Map Scene -> Terrain / Navigation / Buildings / Capture / Spawn`

必须追出：
`地图资源 -> 场景节点 -> 导航数据 -> 战斗空间`

### 2. 单位数据从哪里来
追到单位事实源：HP / Speed / Ammo / Damage / Range / Faction / Model / Animation 等到底来自 `.tres/.res`、脚本常量、JSON/CSV、Scene 属性还是混合来源。

### 3. 模型 / 材质如何绑定
追：
`单位类型 -> 单位Scene -> Mesh -> Imported Asset -> Material -> Texture -> Shader -> LOD/Shadow/Normal/Roughness -> 最终渲染`

重点检查高质量资产怎样成为可批量复用资产，而不是只能局部做漂亮。

### 4. 玩家怎么选单位
追：
`Input -> Screen Position -> Camera Ray/Selection Area -> Query -> Unit -> SelectionManager -> selected_units[] -> Selection/HUD Feedback`

### 5. 点击命令走到哪里
追：
`Input -> World Hit -> Context Classification -> MOVE / ATTACK / CAPTURE / FOLLOW / REJECT -> Command System`

### 6. 寻路怎么执行
追：
`Move Command -> Destination -> Formation Position -> Navigation -> Path -> Steering/Velocity -> Body -> Transform`

检查河流、建筑、拥挤、编队、单位类型差异和路径失败。

### 7. 如何发现 / 选择目标
区分：
- 玩家主动指定；
- 单位/AI自动发现。

追：
`Detection -> Candidates -> Faction -> LOS -> Target Class -> Priority -> Valid Target -> current_target`

### 8. 伤害怎么产生
追：
`Target -> Weapon Ready -> Ammo -> Cooldown -> Range -> LOS -> Fire -> Ammo-1 -> Hit -> Damage -> HP -> Death`

明确谁负责开火、弹药、命中、伤害、HP和死亡。

### 9. AI怎样下命令
追：
`AI Perception/State -> Tactical Decision -> Command -> same execution chain -> Unit Behavior`

若 AI 绕过正常命令链直接改 position/HP，必须单独标记。

### 10. UI怎样拿到状态
追：
`Authoritative Game State -> Signal/Event/Query -> HUD/World UI -> Display`

检查 UI 是表达状态还是重新计算战争。

### 11. 动画 / VFX / 声音怎样反馈
把逻辑事实和玩家感知分开：

`FIRE confirmed -> Animation + Muzzle + Projectile/Tracer + Impact + Sound + Camera + HUD feedback`

### 12. 镜头怎样呈现
正式检查：高度、FOV、倾角、单位屏幕尺寸、密度、光照方向、雾、LOD、阴影距离和后处理。

Camera 属于最终渲染系统，而不是简单移动视角。

### 13. 最后玩家看到什么
前12层最终汇聚：

`地图 + 单位资产 + 材质 + 光照 + 战斗状态 + 动画 + VFX + UI + Camera + Audio -> PLAYER EXPERIENCE`

玩家最终只判断：
- 点下命令以后是否像军队一样行动；
- 坦克/步兵是否有重量和可读性；
- 战斗是否有力量；
- 战场是否活着且空间合理；
- 是否一眼看懂局势；
- 是否像想玩的战争游戏。

---

## 证据记录格式

每一个关键连接都必须记录：

- `CLAIM`
- `CHAIN_LAYER / EDGE`
- `SOURCE`
- `STATUS=OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- `WHAT_THE_SOURCE_ACTUALLY_PROVES`
- `WHAT_IT_DOES_NOT_PROVE`
- `FRONTLINE_CURRENT_IMPLEMENTATION`
- `EXTERNAL_REFERENCE_IMPLEMENTATION`
- `GAP`
- `REPRODUCTION_REQUIRED=YES|NO`

禁止把十三层写成十三篇互不连接的知识笔记。

---

## 当前参考证据

PRIMARY_REFERENCE=0_AD_RELEASE_28
SECONDARY_VALIDATOR_A=BEYOND_ALL_REASON_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

0 A.D. 是第一条真实链的主要可检查教材，不是 FRONTLINE 模板，也不是“RTS标准答案”。

BAR/Recoil、Warzone 用于验证哪些结论可能更一般，哪些只是 0 A.D. 特有实现。

商业闭源游戏主要证明玩家最终能看到什么，除非有公开制作资料，否则不能用截图臆测内部实现。

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

现在就审核01：版本、源码、结论跨度、二手资料、反例、未知连接。

之后审核02：实际复现是否真的连接到最终 PLAYER 层，而不是只完成代码/CI。

---

## 当前禁止事项

- 不继续旧 Golden Scene 盲调；
- 不继续扩 Formation / AI 作为独立系统工程；
- 不把某一个参考工程的实现提升成 RTS 普遍规律；
- 不生成新的幻想目标图来替代生产知识；
- 不用节点数、文件数、CI PASS 或代码存在证明最终体验；
- 不允许用流畅文字填补 UNKNOWN 链路。

---

## Sprint 01 完成条件

只有同时满足以下条件才 PASS：

1. 至少一条真实 playable chain 被从内容/数据追到 PLAYER 层；
2. 十三层之间的重要连接有来源和证据等级；
3. UNKNOWN 被明确保留，没有脑补桥梁；
4. 02在不同内容上独立复现一条小而完整的运行链；
5. 实物有真实运行、截图/录像和操作证据；
6. 03完成反证和实物审核；
7. 00能根据证据图谱明确判断 FRONTLINE 当前差距属于哪一层或哪些跨层连接；
8. 只有经过支持/复现的方法才进入 FRONTLINE transfer decision。

完成前：`PRODUCT_PRODUCTION_RESUME=NO`。
