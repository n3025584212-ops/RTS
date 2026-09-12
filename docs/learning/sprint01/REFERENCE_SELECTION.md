# Learning Sprint 01 — Reference Selection

STATUS=SELECTED_FOR_INITIAL_STUDY
WORK_ID=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
DATE=2026-09-12

## Selection rule

本文件不是选择“最像 FRONTLINE 的游戏”，也不是选择“画面最好看的游戏”。

第一学习对象必须最大化：

1. 可检查性；
2. 完整生产链覆盖；
3. 真实发布/运行证据；
4. 地图、内容、单位、simulation、UI、renderer/tooling 之间的可追踪关系；
5. 能够让我们做独立复现，而不是只看截图猜测。

视觉风格接近 FRONTLINE 只是后续验证维度，不是第一教材的首要选择条件。

---

# Primary reference: 0 A.D. Release 28 / Pyrogenesis ecosystem

SELECTION_STATUS=PRIMARY

## Why selected

0 A.D. 当前官方提供 Release 28 的完整 build source 和 game data 两套源码/数据包，而不是只提供客户端二进制。

官方来源：
- https://play0ad.com/download/source/
- https://play0ad.com/community/participate/
- https://play0ad.com/

官方页面明确说明：

- Release 28 的构建需要同时获取 `unix-build` 和 `unix-data`；
- Pyrogenesis engine 使用 C++；
- gameplay scripting 使用 JavaScript；
- game logic、artwork 和 data 可通过数据文件修改；
- 艺术资产可由外部工具创建并导出 COLLADA；
- 2026-02-18 发布的 Release 28 是项目第一次不再带 Alpha 标签的版本。

可检查的 GitHub 镜像（结构观察使用；实际当前版本优先以 Release 28 官方 source/data 为准）：
- https://github.com/0ad/0ad

镜像中 `binaries/data/mods/public/` 明确分出：
- `art/`
- `audio/`
- `gui/`
- `maps/`
- `shaders/`
- `simulation/`

`simulation/` 进一步包含：
- `ai/`
- `components/`
- `data/`
- `helpers/`
- `templates/`

`maps/` 包含：
- `random/`
- `scenarios/`
- `scripts/`
- `skirmishes/`
- `tutorials/`

这意味着同一个真实 RTS 项目里可以追踪：

`地图/内容 -> 单位数据 -> simulation -> AI -> GUI -> art -> shaders -> runtime`

而不是从多个无关教程拼出一套假想生产流程。

## What 0 A.D. is NOT being selected for

0 A.D. 不是 FRONTLINE 的：
- 最终美术风格；
- 现代军事单位模板；
- 最终玩法模板；
- 最终引擎选择依据；
- Golden Frame 的画质基准。

它首先是一个**端到端生产链教材**。

我们学习它的“东西怎样真正连接成游戏”，而不是把古代 RTS 玩法换皮成 FRONTLINE。

---

# Secondary validator A: Beyond All Reason + Recoil

SELECTION_STATUS=SECONDARY_VALIDATOR

Sources:
- https://github.com/beyond-all-reason/Beyond-All-Reason
- https://recoilengine.org/
- https://recoilengine.org/docs/lua-api/
- https://www.beyondallreason.info/

已确认事实：

- Recoil 官方将自己定义为 battle-tested open-source RTS engine；
- 官方说明其 Lua API 支持游戏 UI 和 mechanics，并面向 thousands of complex units；
- BAR 官方说明 BAR 和 Zero-K 均运行在 Recoil 上；
- BAR 游戏仓库是真实可检查的 Lua/game-content repository。

用途：
- 验证“大规模 RTS engine 与 game-specific content 分层”如何做；
- 验证 unit definitions、commands、widgets/gadgets、渲染扩展等模式；
- 对 0 A.D. 得出的结论做交叉检查，避免把单个项目的做法当成普遍真理。

不作为第一复现教材的原因：
- engine/game/lobby/map ecosystem 更分散；
- 第一轮目标是先追通一条完整生产链，而不是一开始同时理解多个仓库/发行组件。

---

# Secondary validator B: Warzone 2100

SELECTION_STATUS=SECONDARY_VALIDATOR

Source:
- https://github.com/Warzone2100/warzone2100
- https://wz2100.net/

仓库 README 明确说明：
- Warzone 2100 是 free/open-source 3D RTS；
- AI、maps、campaign 可用 JavaScript scripting；
- 仓库提供 scripting、PIE model format、animation 文档；
- 可从源码构建并运行完整游戏。

用途：
- 作为另一个完整发布 RTS 交叉检查地图、单位、脚本、AI、runtime 关系；
- 它的军事题材比 0 A.D. 更接近 FRONTLINE，可用于检查哪些生产问题与题材相关。

限制：
- 它的视觉技术和资产年代跨度很大；
- 不把其当前视觉表现当作 FRONTLINE 最终画质标准。

---

# Commercial outcome references

Examples:
- WARNO
- Broken Arrow
- Regiments

STATUS=OBSERVABLE_RESULT_ONLY unless a specific public developer/technical source exists.

它们可以帮助我们观察：
- 实际玩家镜头；
- 屏幕信息密度；
- 单位可读性；
- 战场构图；
- 战斗反馈；
- UI 和世界画面的比例关系。

但：

> 不能从一张商业游戏截图反推出其内部 production pipeline，然后把推断写成事实。

---

# Decision

PRIMARY_REFERENCE=0_AD_RELEASE_28
SECONDARY_VALIDATOR_A=BAR_RECOIL
SECONDARY_VALIDATOR_B=WARZONE_2100
COMMERCIAL_RESULT_REFERENCES=WARNO_BROKEN_ARROW_REGIMENTS

NEXT:
1. obtain/inspect current 0 A.D. Release 28 source + data structure;
2. choose one real playable slice that can be traced from map/content to player command/combat/UI/runtime;
3. populate `EVIDENCE_REGISTER.md` only with claims directly supported by inspected sources;
4. build `END_TO_END_CHAIN.md`;
5. only after the real chain is understood, specify the independent reproduction scope.

NO_FRONTLINE_TRANSFER_YET=YES
