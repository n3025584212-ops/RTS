# FRONTLINE Repository Map V2

STATUS=CURRENT_NAVIGATION
DATE=2026-09-12

## 1. 现在从哪里开始

唯一入口：`START_HERE.md`

当前状态：`docs/current/CURRENT_STATE.md`

当前任务：`docs/current/ACTIVE_WORK.md`

当前学习规则：`docs/FRONTLINE_LEARNING_SYSTEM_V1.md`

当前生产规则：`docs/FRONTLINE_PROJECT_SYSTEM_V3.md`

当前协作规则：`docs/GPT_COLLABORATION_SYSTEM_V4.md`

---

## 2. main 上的内容分类

### CURRENT AUTHORITY
只包括：

- 当前状态；
- 当前学习/生产/协作系统；
- 用户明确批准且仍有效的目标；
- 当前唯一 Active Work。

### REUSABLE TECHNICAL FOUNDATION
可以复用，但不定义产品方向：

- Godot 4.7.1 工程；
- Formation / Task / Navigation / Combat 等已验证代码；
- 资产导入和许可证记录；
- CI / runtime / screenshot 工具；
- HUD、camera、场景工具中仍然有效的实现。

### HISTORICAL / FAILURE EVIDENCE
保留用于学习，不自动继续：

- Battle01；
- Prototype A / B；
- 三路战场方案；
- Golden Scene V1；
- River Town Visual Slice；
- 已废弃视觉目标；
- 旧治理/窗口系统；
- 被用户否决的 PARTIAL_PASS / 视觉结果。

这些内容的价值是告诉我们：

> 哪些做法已经尝试过、为什么不够、哪些技术资产仍可复用。

不是告诉我们：

> 下一步必须继续它们。

---

## 3. 重要分支

### KEEP — 证据或可复用实验

- `main` — 唯一正式当前状态；
- `archive/legacy-unused` — 历史留档；
- `dev/godot-golden-scene-v1` — Golden Scene 实物/失败证据；
- `dev/visual-production-reset` — River Town 视觉重建证据；
- `dev/river-town-local-high-fidelity-v1` — 局部高保真尝试；
- `dev/reference-region-v1` — 当前可复用 Reference Region / 资产实验，包括已合入的 repair workshop 资产包；
- `dev/prototype-b-representative-battle-content-v1` — 旧玩法实验，仅作技术/历史证据。

KEEP 不代表当前生产任务。

### DELETE CANDIDATES

分支清理候选继续由 Issue #37 维护。

原则：

- merged / superseded / CI-only 且已有 main/archive 证据的分支可删；
- 有唯一实验资产或无法确认是否归档的分支先 HOLD；
- 不为了减小列表而删除仍有唯一实物证据的视觉分支。

---

## 4. PR/Issue 视图应该怎样读

旧 PR / Issue 只要与当前学习重置冲突，就应该 CLOSED/SUPERSEDED，而不是继续保持 OPEN 造成假任务。

当前新的工作不会从旧 PR #30、#35、#36 继续滚动。

- PR #30：旧 Prototype B gameplay progression；
- PR #35：旧 visual-reset blind tuning；
- PR #36：旧 hygiene/system-sync PR，内容基于已被 V3/V4 取代的治理版本。

保留其 branch/commit 作为证据即可。

---

## 5. 新工作放哪里

学习复现：

- 文档：`docs/learning/`
- 隔离场景/代码：建议 `scenes/learning/`、`scripts/learning/`、`tools/learning/`
- 证据：`artifacts/learning/`

只有复现证明成立的内容，才允许迁移到生产目录。

不要直接把学习实验塞进 `scenes/production/`。

---

## 6. 当前仓库整理目标

不是追求“文件最少”，而是追求：

1. 打开仓库 30 秒内知道当前唯一任务；
2. 历史失败不会伪装成当前计划；
3. 技术资产不因方向重置而丢失；
4. 学习实验和正式生产清晰分开；
5. 没有证据支持的理论不会进入产品权威层。
