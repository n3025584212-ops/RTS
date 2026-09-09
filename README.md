# FRONTLINE / 战线

现代战争题材、Formation / Platoon 级指挥导向的实时战术游戏项目。

## 一眼看懂当前项目

```text
唯一真相
└─ docs/current/CURRENT_STATE.md
   ├─ 当前生产方向：Golden Frame / Golden Scene 高保真视觉施工
   ├─ 当前主任务：Issue #33
   ├─ 并行既有审查：PR #30 / Issue #31
   └─ Battle01 正式生产：PAUSED
```

**先看当前状态，不要从旧分支或旧文档猜项目进度。**

## 开始阅读

1. `docs/current/CURRENT_STATE.md` — 唯一当前项目状态
2. `docs/ops/REPOSITORY_MAP.md` — 仓库可视化地图：现在什么在用、什么是历史
3. `docs/FRONTLINE_PROJECT_CHARTER_V3.md` — 项目最高运行规则
4. `docs/FRONTLINE_PROJECT_SYSTEM_V2.md` — 当前生产系统
5. `docs/GPT_MULTI_WINDOW_SYSTEM_V3.md` — 四窗口协作规则
6. `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md` — 当前窗口运行规则
7. `docs/gpt_windows/` — 四个可复制的 ChatGPT 初始化入口
8. `docs/current/DECISION_LOG.md` — 项目决策历史

## 当前仓库分层

```text
main
├─ docs/current/       当前项目真相
├─ docs/design/        当前设计/Golden Frame 合同与支持材料
├─ scripts/core/       已接受的通用 RTS Core
├─ scripts/discovery/  Prototype B / 发现阶段实现
├─ scripts/battle01/   历史 Battle01 技术基线（生产暂停，但仍用于回归）
├─ scenes/             Godot 场景
├─ tests/              技术回归/集成验证
└─ assets/ui/          main 上的小型 UI 基础资产

大型真实视觉资产目前仍主要存在于视觉施工分支，不等于已经进入 main。
```

## 分支原则

- `main`：当前稳定基线，不保存所有实验历史。
- 当前施工分支：保留到对应任务/PR完成。
- 已合并或明确 superseded 的分支：进入删除候选。
- `archive/legacy-unused`：非当前权威的历史资料保留区。
- 分支删除清单见 `docs/ops/BRANCH_CLEANUP_REGISTER_20260909.md`。

## 重要边界

- Engine: Godot 4.7.1
- `TECHNICAL_PASS != PRODUCT_PASS`
- 自动化不能替代真人产品判断。
- 旧 Battle01、旧视觉目标、旧治理版本不会因为曾经 PASS/FROZEN 自动恢复为当前权威。
- 视觉施工必须服从当前 approved Golden Frame，不允许用盒子/无关占位物冒充交付。
