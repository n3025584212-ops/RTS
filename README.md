# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 当前状态

- Engine baseline: Godot 4.7.1
- Operating mode: `RESTARTED_EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER`
- Active issue: `#39`
- Active Sprint branch: `learning/sprint01-end-to-end-rts-production`
- Current gate: `SPRINT01_WORLD_REPRODUCTION_RUNTIME_GATE`
- Product production resume: `NO`
- Control authority: `main:docs/current/CURRENT_STATE.md`

旧 P0 / Prototype B / Battle01 / Golden Scene / River Town 路线均已退出当前产品权威层，只保留为技术资产、实物/失败证据和可复用工具。

## 开始阅读

1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. `docs/current/WINDOW_RECOVERY_INDEX.md`
5. `docs/current/RESTART_DECISION.md`
6. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`

不要从历史 Issue、旧 PR、聊天记忆或旧窗口提示推断当前状态。

## 当前四窗口

```text
00  CONTROL / INTEGRATION                 ACTIVE_CONTROL
01  EVIDENCE / LEARNING                   HOLD_STAGE4_COMPLETE
02  REPRODUCTION / BUILD                  ACTIVE_RUNTIME_GATE
03  INDEPENDENT REVIEW / FALSIFICATION    HOLD_PENDING_FRESH_RUNTIME
```

## 当前 Sprint 01

已完成：
- 真实 RTS 端到端证据学习；
- 第一条 player causal chain fresh runtime；
- Stage 4 world causal decomposition；
- Window 03 world-method audit (`PASS_WITH_DOWNGRADES`)；
- 新 `Sprint01WorldReproduction` 场景、脚本和 workflow 实现。

当前未完成：
- 新世界复现的 fresh Godot 4.7.1 runtime；
- fresh PLAYER-visible screenshots/video；
- Window 03 新世界实物审核；
- Sprint 01 PASS；
- FRONTLINE 产品生产恢复。

当前 blocker：最近 hosted world-reproduction run 在 runner 分配前失败（`runner_id=0`, `steps=[]`），因此仍是 execution-infrastructure blocker，不是 gameplay PASS/FAIL。

## 当前关键路径

```text
docs/current/       当前状态/任务/恢复入口
docs/learning/      学习合同、证据、生产方法、复现说明
docs/audit/         独立审核
scenes/learning/    隔离复现场景
scripts/learning/   隔离复现代码
artifacts/learning/ runtime / screenshot / video 证据
assets/              可复用资产与 provenance
```

仓库导航：`docs/ops/REPOSITORY_MAP_V3.md`。
