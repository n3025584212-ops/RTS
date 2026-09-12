# LEARNING SPRINT 01 — Battlefield Construction Reproduction Contract

STATUS=READY
WORK_ID=LEARNING_SPRINT_01_BATTLEFIELD_CONSTRUCTION

## Goal

不是“设计一张更好看的 FRONTLINE 地图”，而是证明我们真的学会一条成熟 3D 战场区域的生产方法。

## Required workflow

### Stage 1 — Select evidence
选取：

- 至少一个可以查看真实工程/源码/关卡数据的成熟开源 3D RTS 或相近项目；
- 至少一个商业成熟战术/RTS 成品作为外观与空间结果观察样本；
- 必要的官方引擎/工具制作资料。

每个来源只允许支持它实际能证明的结论。

### Stage 2 — Reconstruct production logic
必须回答并给证据：

- 地形是如何形成的；
- 道路/桥/河流如何约束空间；
- 聚落为何这样布局；
- 植被为何这样分布；
- 战术空间如何从世界结构中产生；
- 材质和地表如何组合；
- 光照/大气怎样形成层次；
- RTS 镜头下资产质量需求是什么。

### Stage 3 — Independent reproduction
在独立 learning scene 中复现方法。

禁止复制参考地图的坐标。

要求换一块地，使用学到的生成规则做出合理区域。

### Stage 4 — Compare
实际运行并截图。

记录：

- 哪些效果复现成功；
- 哪些只是近似；
- 哪些失败；
- 哪些仍然不知道原因。

### Stage 5 — Transfer
只有 Stage 1–4 完成后，才写 FRONTLINE transfer proposal。

## Hard rules

- 模型总结不是证据；
- 社区观点不是生产事实；
- 截图只能证明结果，不能证明内部生产方法；
- 一个元素存在不等于该元素设计正确；
- 不用 CI / 节点数量 / 实例数量证明视觉质量；
- 不允许在复现前直接改 FRONTLINE production scene；
- 不允许把 learning scene 宣称为游戏成品。

## Deliverables

1. `docs/learning/sprint01/EVIDENCE_REGISTER.md`
2. `docs/learning/sprint01/CAUSAL_DECOMPOSITION.md`
3. isolated reproducible scene/code under learning paths
4. actual runtime screenshots under `artifacts/learning/sprint01/`
5. `docs/learning/sprint01/REPRODUCTION_RESULT.md`
6. `docs/learning/sprint01/FRONTLINE_TRANSFER_DECISION.md`

## Exit

PASS only if production logic was both evidenced and independently reproduced.

A good essay with no reproduction is FAIL.
