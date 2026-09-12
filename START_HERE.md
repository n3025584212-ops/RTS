# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》

如果你刚打开这个仓库，不要从历史 Issue、旧 PR 或旧 Battle01 文档开始。

## 当前只读顺序

1. `docs/current/CURRENT_STATE.md`
2. `docs/FRONTLINE_LEARNING_SYSTEM_V1.md`
3. `docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md`
4. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
5. `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`
6. `docs/FRONTLINE_PROJECT_SYSTEM_V3.md`
7. `docs/current/ACTIVE_WORK.md`

以上之后，才按当前任务读取代码、资产和历史证据。

## 当前四窗口

- `00`：中控 / 整合；维护唯一状态、派工和迁移门槛。
- `01`：证据 / 学习；沿13层建立端到端证据图谱。
- `02`：复现 / 施工；把已证明的链做成真实运行实物。
- `03`：独立审核 / 反证；按硬审计合同检查证据、版本、运行语义、泛化、替代解释和反例。

窗口编号不代表能力或正确性；四个窗口共用同一 `CURRENT_STATE` 和 Issue #39。

## 当前核心链

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

重点不是分别积累地图、AI、材质、UI知识，而是证明它们怎样连接并最终形成玩家实际看到和感受到的战争。

## 当前证据原则

- 模型总结、通用理论、用户临时假设都不是已验证事实。
- 重要结论必须标记为 `OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED`。
- 二手文章不能冒充源码证据。
- 核心源码结论必须确认版本身份。
- 类/函数/组件存在不等于运行时真的走该链。
- 单一项目事实不能自动泛化成 RTS 通则。
- 重要因果解释必须寻找替代解释。
- 泛化结论必须主动寻找 BAR/Recoil、Warzone 或其他成熟项目反例。
- 没有复现或直接验证，不允许声称“已经学会怎么做”。
- CI、元素数量、代码存在都不能替代实际玩家结果。

## 当前重要版本警报

`0ad/0ad` GitHub 仓库已经归档，并注明源码于 2024-08-20 迁往 Wildfire Games Gitea。

因此 GitHub `master` 默认是历史证据，不得直接冒充 2026 / Release 28 当前源码。01必须证明版本匹配；03必须优先审这一点。

## 历史状态

旧 Battle01、Prototype B、Golden Scene V1、River Town 视觉尝试均保留为技术资产、失败证据和可复用工具，不再自动拥有产品设计权威。

## 现在要做什么

当前第一阶段：

`真实参考/FRONTLINE实物 -> 13层证据图谱 -> 03反证 -> 02小型完整复现 -> 03实物审核 -> 00迁移决定`

具体任务只看 `docs/current/ACTIVE_WORK.md` 和 Issue #39。
