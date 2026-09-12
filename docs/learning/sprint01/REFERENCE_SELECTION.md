# Learning Sprint 01 — Reference Selection

STATUS=CONDITIONAL_PRIMARY_REFERENCE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-13
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Selection rule

本文件不是选择“最像 FRONTLINE 的游戏”，也不是选择“画面最好看的游戏”。

第一学习对象必须最大化：
1. 可检查性；
2. 完整生产链覆盖；
3. 真实发布/运行证据；
4. 地图、内容、单位、simulation、UI、renderer/tooling 之间的可追踪关系；
5. 能够让我们做独立复现，而不是只看截图猜测；
6. 关键源码结论能锁定到正确版本。

视觉风格接近 FRONTLINE 只是后续验证维度，不是第一教材的首要选择条件。

---

# Primary candidate: 0 A.D. Release 28 / Pyrogenesis ecosystem

SELECTION_STATUS=CONDITIONAL_PRIMARY

## Why still selected conditionally

0 A.D. 官方提供 Release 28 的 build source 和 game data 下载，并提供 Release-28 entity-component documentation，因此它仍然是很强的端到端追踪候选。

官方来源：
- https://play0ad.com/download/source/
- https://play0ad.com/community/participate/
- https://docs.wildfiregames.com/entity-docs/r28/components/
- https://play0ad.com/

这些资料可以支持：
- Release 28 source/data distribution 存在；
- 官方描述的 C++ engine / JavaScript gameplay / data-driven content 分工；
- Release-28 文档中的 component taxonomy。

## Critical version warning

`https://github.com/0ad/0ad` 已经归档，并明确注明：源码于 2024-08-20 迁往 Wildfire Games Gitea。

因此：
- GitHub `master` 默认只能作为历史镜像证据；
- 不能直接拿它证明 2026 当前实现；
- 不能直接拿它证明 Release 28 实现；
- 若某条源码结论需要证明 Release 28，01必须取得并检查版本匹配的 Release-28 权威 source/data；
- 03必须优先审核版本身份。

历史 GitHub mirror 仍可用于结构线索，但必须明确标成历史，不得伪装为 current source.

## Primary-reference retention test

0 A.D. 只有在下面成立时继续保持 PRIMARY：
1. 01能够获得/检查 Release-28 版本匹配的权威 source/data；
2. 至少一条真实 playable chain 可以从内容/数据追到 runtime / PLAYER；
3. 关键 caller/data/runtime edges 不只停留在组件名或文档目录；
4. 03能够独立复核核心证据。

如果上述条件失败，不替 0 A.D. 辩护，直接重新评估主参考。

## What 0 A.D. is NOT being selected for

0 A.D. 不是 FRONTLINE 的：
- 最终美术风格；
- 现代军事单位模板；
- 最终玩法模板；
- 最终引擎选择依据；
- Golden Frame 的画质基准；
- RTS架构标准答案。

它只是当前第一候选的**端到端生产链教材**。

---

# Secondary validator / counterexample A: Beyond All Reason + Recoil

SELECTION_STATUS=SECONDARY_VALIDATOR_AND_COUNTEREXAMPLE_POOL

Sources:
- https://github.com/beyond-all-reason/Beyond-All-Reason
- https://github.com/beyond-all-reason/RecoilEngine
- https://recoilengine.org/

已确认的边界事实：
- BAR 是建立在 Recoil RTS Engine 上的 game code；
- Recoil 是独立 RTS engine；
- BAR 还存在独立 lobby/client 层。

用途：
- 专门攻击“0 A.D.这种边界是RTS必要条件”的说法；
- 检查 engine/game/lobby 分层；
- 检查 Lua game API、unit definitions、commands 和大型 RTS 运行边界。

重要规则：
> 只读 BAR game repo 不足以推断完整 RTS engine/runtime architecture。

---

# Secondary validator / counterexample B: Warzone 2100

SELECTION_STATUS=SECONDARY_VALIDATOR_AND_COUNTEREXAMPLE_POOL

Sources:
- https://github.com/Warzone2100/warzone2100
- https://github.com/Warzone2100/warzone2100/blob/master/doc/Scripting.md
- https://wz2100.net/

已确认事实：
- Warzone 2100 是完整开源 3D RTS；
- 官方 scripting 文档说明 JavaScript 用于 AI、campaign 和部分 game rules；
- 这提供了与 0 A.D. 不同的 native/core + scripting boundary。

用途：
- 主动寻找“不按0 A.D.方式组织但仍能做成熟RTS”的实现；
- 对任何必要性/通则结论进行降级测试。

---

# Commercial outcome references

Examples:
- WARNO
- Broken Arrow
- Regiments

STATUS=OBSERVABLE_RESULT_ONLY unless a specific public developer/technical source exists.

它们可以用于观察：
- 玩家镜头；
- 屏幕信息密度；
- 单位可读性；
- 战场构图；
- 战斗反馈；
- UI / world 比例关系。

但不能从成品截图反推隐藏 production pipeline。

---

# Decision

PRIMARY_REFERENCE=0_AD_RELEASE_28_CONDITIONAL
SECONDARY_VALIDATOR_A=BAR_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

NEXT:
1. obtain/inspect authoritative version-matched 0 A.D. Release 28 source + data;
2. choose one real playable slice;
3. trace actual caller/data/runtime edges through the 13-layer chain;
4. let Window 03 audit source identity, version, semantics, inference scope, alternatives and counterexamples in parallel;
5. if authoritative tracing fails, reconsider the primary reference rather than filling gaps with archived GitHub evidence;
6. only after a real chain survives audit, define Window 02 reproduction scope.

NO_FRONTLINE_TRANSFER_YET=YES
