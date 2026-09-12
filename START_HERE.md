# FRONTLINE — START HERE

STATUS=CURRENT_ENTRYPOINT
PROJECT=FRONTLINE《战线》

如果你刚打开这个仓库，不要从历史 Issue、旧 PR、旧 Battle01 文档开始。

## 当前只读顺序

1. `docs/current/CURRENT_STATE.md`
2. `docs/FRONTLINE_LEARNING_SYSTEM_V1.md`
3. `docs/FRONTLINE_PROJECT_SYSTEM_V3.md`
4. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
5. `docs/current/ACTIVE_WORK.md`

以上五项之后，才按当前任务读取代码、资产和历史证据。

## 四窗口仍然存在

FRONTLINE 保留固定的四个 GPT 工作窗口：

- `00` — 中控 / 整合：维护唯一状态、派工、整合或拒绝结果；
- `01` — 证据 / 学习：研究真实成品、真实工程、真实生产资料；
- `02` — 复现 / 施工：把已得到证据的方法做成真实可运行实物；
- `03` — 独立审核 / 反证：检查来源、实物和结论，主动寻找错误和替代解释。

四窗口共享一个 `CURRENT_STATE`、一个当前 Issue 和一套证据语言。

重要修正：窗口编号不再等于“这个窗口天然是专家”。01 的结论必须有证据，02 必须有实物，03 必须从实际来源/实物审核，00 不能靠治理文本替代产品结果。

## 当前原则

- 模型总结、通用理论、用户临时技术假设都不是已验证事实；
- 重要结论必须标记为 `OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED`；
- 优先研究真实成品、真实工程、真实开发资料和可复现制作链；
- 没有复现或直接验证，不允许声称“已经学会怎么做”；
- 设计必须同时说明制造路径；纯生成图只能是视觉提案；
- Codex 负责执行已定义、可验证的施工；不得用自由发挥替代缺失的生产知识；
- CI、元素数量、代码存在都不能替代实际游戏结果；
- 四窗口一致也不能作为正确性的证据。

## 历史状态

旧 Battle01、Prototype B、Golden Scene V1、River Town 视觉尝试均保留为：

- 技术资产；
- 失败证据；
- 可复用代码/工具/资产来源；
- 不再自动拥有产品设计权威。

不要为了“历史上已经做了很多”而继续错误路线，也不要为了重启而删除仍可复用的技术资产。

## 现在要做什么

当前唯一产品学习任务是 Issue #39。

当前四窗口分工：

`00 定义/整合 -> 01 证据学习 -> 02 实物复现 -> 03 反证审核 -> 00 决定是否迁移到 FRONTLINE`

当前阶段 01 和 03 可以并行：01 追 0 A.D. Release 28 的真实端到端生产链，03 审核资料选择和证据强度；02 等到出现可复现链后开始真实复现。

具体当前任务只看 `docs/current/ACTIVE_WORK.md`。
