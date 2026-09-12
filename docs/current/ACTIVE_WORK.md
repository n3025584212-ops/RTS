# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_BATTLEFIELD_CONSTRUCTION
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER

## 为什么现在不继续直接修 Golden Scene

Golden Scene / River Town 已经证明：

- Godot 可以运行；
- 3D 资产可以导入；
- 自动截图可以工作；
- HUD、河流、桥、单位、VFX 可以“存在”。

但这些证据没有证明我们掌握了成熟 RTS 战场的真实生产方法。继续在旧场景上盲调 PBR、曝光、实例数量，只会再次把“有元素”误当成“会做成品”。

因此当前第一任务不是增加更多功能，而是学习并复现一条真实生产链。

---

## 当前唯一任务

### LEARNING_SPRINT_01 — 可信战场区域如何被真正构建

研究问题：

> 一个成熟 3D RTS / 战术游戏里的可信战场区域，从地形、交通、聚落、植被、材质、光照到镜头表现，实际上是怎样形成的？

重点不是记住一张图的坐标，而是找到生成结果的规则和生产方法。

### 必须覆盖的因果层

1. 地形骨架：高低、坡度、河谷/水系如何影响布局；
2. 交通网络：主路、支路、桥、路口为什么在那里；
3. 聚落：建筑为什么沿某种道路/地块关系生长，朝向为什么合理；
4. 土地用途：农田、林地、工业、住宅、空地如何分区；
5. 植被：不是随机撒树，而是与地形、道路、地块、视线关系一致；
6. 战术空间：射界、掩体、节点、通行、部署区域如何从世界结构中产生；
7. 材质：地面不是单一贴图，材料与道路、泥土、河岸、受损区域如何过渡；
8. 光照/大气：近中远层级怎样产生；
9. 镜头：实际 RTS 视角下单位、建筑、道路、植被需要达到什么屏幕可读性。

---

## 证据要求

至少包含：

- `E0`：FRONTLINE 自己现有失败实机截图/场景，作为问题证据；
- `E1`：至少一个可以检查真实工程/源码/关卡数据的成熟开源 3D RTS 或相近项目；
- `E2`：实际出品团队、引擎/工具作者的官方技术资料或制作说明；
- 商业成熟游戏只能用于观察成品现象，不能凭截图臆测其内部实现。

社区教程、论坛、视频观点可以帮助寻找线索，但不能单独升级为生产规则。

---

## 学习输出不是“总结文章”

必须交付以下实物：

### A. Evidence Register
每个重要结论记录：

- CLAIM
- STATUS=`OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- SOURCE
- WHAT_THE_SOURCE_ACTUALLY_PROVES
- WHAT_IT_DOES_NOT_PROVE

### B. Causal Decomposition
选定一个成熟参考区域，拆成：

`terrain -> transport -> parcels/land-use -> settlement -> vegetation -> tactical space -> materials -> lighting -> camera`

禁止只写“这里有房子、这里有树”。

### C. Reproduction
在隔离学习场景中，不使用 FRONTLINE 玩法逻辑，复现上述生成关系。

目标不是复制原地图坐标，而是证明：

> 换一块地，仍能依照学到的规则生成合理世界。

### D. Comparison
输出实际引擎截图，与参考现象逐项比较。

失败必须记录为失败；不得用“结构已经存在”代替视觉/空间判断。

### E. Transfer Decision
只有复现成立之后，才判断：

- 哪些规则可以迁移到 FRONTLINE；
- 哪些只适用于参考项目；
- 哪些仍然不知道。

---

## 现有仓库资产怎么处理

### KEEP / REUSE AS TOOLING
- Godot 4.7.1 工程；
- 真实资产导入工具链；
- 截图和运行自动化；
- 合法资产来源/许可证记录；
- 可复用 camera / HUD / Formation / navigation / combat 技术代码。

### HISTORICAL EVIDENCE, NOT AUTHORITY
- Battle01；
- Prototype B；
- Golden Scene V1；
- River Town Visual Slice；
- 旧设计图和旧窗口合同。

### DO NOT DO NOW
- 不继续扩编队系统；
- 不新增 AI 架构；
- 不继续在旧 Golden Scene 上随机调参数；
- 不再生成一个更漂亮的目标图来替代学习；
- 不以 CI 或元素计数宣布进展。

---

## 完成条件

LEARNING_SPRINT_01 只有在下面同时成立时完成：

1. 关键结论有来源和证据等级；
2. 至少一条成熟战场生产链被真实拆解；
3. 已做独立复现，而不是只写总结；
4. 复现结果有实际截图/运行证据；
5. 能明确指出成功、失败和仍未知部分；
6. 可以把一小部分规则迁移到 FRONTLINE，并解释为什么，而不是“感觉应该可以”。

完成前：`PRODUCT_PRODUCTION_RESUME=NO`。
