# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前项目状态

- Engine baseline: Godot 4.7.1
- Operating mode: `RESTARTED_EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER`
- Active issue: `#39`
- Active Sprint branch: `learning/sprint01-end-to-end-rts-production`
- Current gate: `SPRINT01_WORLD_REPRODUCTION_RUNTIME_GATE`
- Product production resume: `NO`
- Source of truth for routing: `docs/current/CURRENT_STATE.md`

旧的 P0 / Prototype B / Battle01 / Golden Scene / River Town 路线已经退出当前产品权威层。它们保留为技术资产、实物/失败证据和可复用工具。

## 开始阅读

任何新窗口、恢复窗口、上下文断档窗口都按以下顺序：

1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. `docs/current/WINDOW_RECOVERY_INDEX.md`
5. `docs/current/RESTART_DECISION.md`
6. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

然后读取 `CURRENT_STATE.md` 指定的 active branch 最新 HEAD 和对应 Sprint 产物。

不要从历史 Issue、旧 PR、旧 README 片段或聊天记忆推断当前状态。

## 当前四窗口

```text
00  CONTROL / INTEGRATION                 唯一控制、路由、整合、迁移决定
01  EVIDENCE / LEARNING                   证据、源码、生产方法学习
02  REPRODUCTION / BUILD                  Godot 独立复现与运行证据
03  INDEPENDENT REVIEW / FALSIFICATION    独立审核、反证、实物验收
```

当前分配：

```text
00 = ACTIVE_CONTROL
01 = HOLD_STAGE4_COMPLETE
02 = ACTIVE_RUNTIME_GATE
03 = HOLD_PENDING_FRESH_RUNTIME
```

## 当前 Sprint 01 状态

已完成：
- 真实 RTS 端到端证据链学习；
- 一条实际 player causal chain 的独立 runtime；
- Stage 4 world causal decomposition；
- Window 03 对 world method 的独立审核，结果 `PASS_WITH_DOWNGRADES`；
- 新 `Sprint01WorldReproduction` 场景、脚本和 CI workflow 已构建。

未完成：
- 新世界复现的 fresh Godot 4.7.1 runtime；
- fresh PLAYER-visible screenshots/video；
- Window 03 对新世界实物的最终审核；
- Sprint 01 PASS；
- FRONTLINE 产品生产恢复。

最近一次 hosted world-reproduction run 在 runner 分配前失败（`runner_id=0`, `steps=[]`），因此当前是执行基础设施 blocker，不是 gameplay PASS/FAIL。

## Repository roles

```text
docs/current/       当前控制状态、任务、恢复入口
docs/learning/      学习合同、证据、世界生产方法
scenes/learning/    隔离复现场景
scripts/learning/   隔离复现代码
artifacts/learning/ runtime / screenshot / video 证据
assets/              可复用资产与 provenance
archive / dev/*      历史证据、旧实验、可复用工具
```

完整仓库导航见：`docs/ops/REPOSITORY_MAP_V3.md`。
