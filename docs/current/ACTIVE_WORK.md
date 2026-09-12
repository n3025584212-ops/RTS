# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
ACTIVE_ISSUE=#39
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER

## 为什么现在不继续旧生产

过去已经证明：

- Godot 可以运行；
- 3D 资产可以导入；
- Formation / Task / Navigation / Combat 等代码可以工作；
- 自动截图、CI、HUD、河流、桥、单位、VFX 都可以“存在”。

但这些证据没有证明我们真正理解：

> 一个成熟 RTS 怎样从地图/内容制作、玩家输入、单位行为、战斗、UI、镜头、资产、光照、VFX一路组合成一个完整可玩的游戏结果。

因此现在不能只盯住最近一次视觉失败，也不能继续扩玩法系统。

当前第一任务是重建一条真实成熟 RTS 的端到端生产链，并独立复现一个小而完整的运行切片。

---

## 当前唯一产品相关任务

### LEARNING_SPRINT_01 — Reconstruct one real RTS production chain end-to-end

正式执行入口：GitHub Issue #39

合同：`docs/learning/LEARNING_SPRINT_01_CONTRACT.md`

核心问题：

> 一个真实成熟 RTS 是怎样从世界/内容制作和玩家操作，经过单位、导航、战斗、AI、UI、镜头和视觉呈现，最终变成屏幕上可运行、可理解、可玩的战斗？

---

## 必须追踪的完整链

1. map/world authoring；
2. terrain / roads / settlement / vegetation；
3. unit asset / material / animation / data；
4. player selection / input / command；
5. movement / path / navigation；
6. targeting / combat / damage；
7. AI / opponent behavior；
8. UI / world-space feedback；
9. camera / readability；
10. lighting / materials / VFX / audio；
11. content loading / build / runtime。

世界空间仍需单独做因果拆解：

`terrain -> transport -> parcels/land-use -> settlement -> vegetation -> tactical space -> materials -> lighting -> camera`

但它只是完整学习链的一部分，不再把“画质/地图”误当成整个游戏问题。

---

## 证据要求

至少包含：

- `E0`：FRONTLINE 自己的失败/半成品实机和代码，作为问题证据；
- `E1`：至少一个成熟、可检查源码/数据/地图/内容管线的 3D RTS 或相近实时策略项目；
- `E2`：实际开发团队、引擎或工具作者的官方制作资料；
- 商业闭源成熟游戏可以用于观察最终结果，不能凭截图猜它内部怎么做。

每个结论必须区分：

`OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED`

---

## 学习输出不是“总结文章”

必须交付：

1. `docs/learning/sprint01/EVIDENCE_REGISTER.md`
2. `docs/learning/sprint01/REFERENCE_SELECTION.md`
3. `docs/learning/sprint01/END_TO_END_CHAIN.md`
4. `docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`
5. 隔离 learning scene / code / tools
6. `artifacts/learning/sprint01/` 下真实运行证据
7. `docs/learning/sprint01/REPRODUCTION_RESULT.md`
8. `docs/learning/sprint01/FRONTLINE_TRANSFER_DECISION.md`

### 复现实物最低要求

内容可以小，但链必须完整：

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

同时必须有一个因果合理的真实环境和真实内容管线。

不能用盒子/色块作为最后交付，再解释“以后会换”。

---

## 现有仓库资产怎么处理

### KEEP / REUSE AS TOOLING
- Godot 4.7.1 工程；
- Core / Formation / Task / Navigation / Combat 技术代码；
- 真实资产导入和许可证记录；
- 截图、CI、runtime 工具；
- camera / HUD / 场景工具；
- 保留分支上的可用真实资产和实验成果。

### HISTORICAL EVIDENCE, NOT AUTHORITY
- Battle01；
- Prototype A / B；
- Golden Scene V1；
- River Town Visual Slice；
- Reference Region 现有实验；
- 旧设计图和旧窗口合同。

### DO NOT DO NOW
- 不继续旧 Golden Scene 盲调；
- 不继续扩 Formation / AI；
- 不再生成新的 FRONTLINE 幻想目标图来替代学习；
- 不把“系统齐全”当成学习完成；
- 不让一个窗口/模型自己定义标准又自己判 PASS。

---

## 完成条件

LEARNING_SPRINT_01 只有在下面同时成立时完成：

1. 关键结论有真实来源和证据等级；
2. 至少一条成熟 RTS 端到端生产链被真实追踪；
3. 能解释各层如何连接，而不是只列模块；
4. 已在不同内容上做独立复现；
5. 复现有实际运行和截图/录像证据；
6. 明确记录成功、失败、近似和 UNKNOWN；
7. 只有经复现的部分才进入 FRONTLINE transfer decision。

完成前：`PRODUCT_PRODUCTION_RESUME=NO`。
