# LEARNING SPRINT 01 — End-to-End RTS Production Reproduction Contract

STATUS=READY
WORK_ID=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
ACTIVE_ISSUE=#39

## Goal

不是继续修最近一次视觉失败，也不是再写一套游戏理论。

目标是证明我们真的理解并能复现一条成熟 RTS 从内容制作到玩家实际看到/操作的完整生产链。

学习对象必须是真实可检查的成熟工程或制作资料，而不是模型自己拼出的“最佳实践”。

---

## Stage 1 — Select the primary reference

选取至少一个：

- 已成熟发布；
- 3D RTS / real-time tactics / 相近实时策略类型；
- 可以检查真实源码、数据、地图/场景或内容管线；
- 有足够官方/源码证据追踪实际运行链。

商业闭源游戏可以作为结果参照，但不能凭截图猜内部制作方法。

输出：`docs/learning/sprint01/REFERENCE_SELECTION.md`

必须说明为什么选它、能证明什么、不能证明什么。

---

## Stage 2 — Evidence Register

建立：`docs/learning/sprint01/EVIDENCE_REGISTER.md`

每个重要结论都记录：

- CLAIM
- STATUS=`OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- SOURCE
- WHAT_THE_SOURCE_ACTUALLY_PROVES
- WHAT_IT_DOES_NOT_PROVE

模型总结、论坛共识、用户直觉都不能自动成为 VERIFIED FACT。

---

## Stage 3 — Reconstruct one real playable chain

从一个真实可玩的切片追踪：

1. map/world authoring；
2. terrain / roads / settlement / vegetation；
3. unit model / material / animation / data definition；
4. player selection / input / command path；
5. movement / navigation；
6. targeting / combat / damage；
7. AI / opponent behavior；
8. UI and world-space feedback；
9. camera / readability；
10. lighting / materials / VFX / audio；
11. content loading / build / runtime。

输出：`docs/learning/sprint01/END_TO_END_CHAIN.md`

重点不是“列出模块”，而是说明：

> 一个玩家动作怎样真正穿过这些层，最后变成屏幕上的游戏结果。

---

## Stage 4 — Reconstruct world causality

世界空间必须单独拆解：

`terrain -> transport -> parcels/land-use -> settlement -> vegetation -> tactical space -> materials -> lighting -> camera`

输出：`docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

禁止只学习参考图的坐标和物体清单。

---

## Stage 5 — Independent reproduction

在隔离 learning 路径做一个内容规模小但链条完整的实物：

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

要求：

- 有因果合理的真实环境；
- 有真实资产/content pipeline；
- 不以盒子/色块作为交付画面；
- 不复制参考地图坐标；
- 不直接套 FRONTLINE 既有玩法假设；
- 可以复用 Godot 工具链，但要明确哪些是复用、哪些是新学到的。

建议隔离路径：

- `scenes/learning/sprint01/`
- `scripts/learning/sprint01/`
- `tools/learning/sprint01/`
- `artifacts/learning/sprint01/`

---

## Stage 6 — Real comparison

实际运行、实际操作、实际截图/录像。

输出：`docs/learning/sprint01/REPRODUCTION_RESULT.md`

必须明确：

- REPRODUCED
- PARTIALLY_REPRODUCED
- FAILED
- UNKNOWN

不得用：

- CI green；
- 节点数量；
- unit count；
- “所有功能都存在”；

替代实际判断。

---

## Stage 7 — FRONTLINE transfer decision

只有 Stage 1–6 完成后，才输出：

`docs/learning/sprint01/FRONTLINE_TRANSFER_DECISION.md`

必须区分：

- 可以直接复用的生产方法；
- 需要改造的方法；
- 只适用于参考游戏的方法；
- 尚未理解的方法；
- 与 FRONTLINE 目标冲突的方法。

在此之前：`PRODUCT_PRODUCTION_RESUME=NO`。

---

## Hard rules

- 一个优秀解释不等于学会；
- 一个漂亮参考图不等于知道怎么造；
- 一个源码函数不等于知道完整生产链；
- 一次语义原型不等于游戏成品；
- 用户提出的假设和模型提出的假设必须同样接受证据检验；
- 不允许窗口/Agent凭身份自我审核；
- 不允许重新生成更漂亮的 FRONTLINE 目标图来逃避复现；
- 不允许继续旧 Golden Scene 的盲调作为本 Sprint 主要工作。

## Exit

PASS 只有一个含义：

> 至少一条真实成熟 RTS 生产链已经有证据地被拆解，并且我们在不同内容上独立复现了一个小而完整、真实运行的游戏切片。

只有文章、没有实物：FAIL。
只有实物、说不清为什么成立：PARTIAL / NOT LEARNED.
