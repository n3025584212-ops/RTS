# FRONTLINE Branch Cleanup Register — 2026-09-09

BASE_MAIN=bdaa6f05557576f6709e0cadbcc48ca5ac6a31cc
CLASSIFICATION=KEEP | ARCHIVE | REMOVE | HOLD

## A. KEEP — 当前仍在工作链中

| 分支 | 原因 |
|---|---|
| `main` | 当前稳定基线 |
| `dev/godot-golden-scene-v1` | Golden Scene 大资产基线，仍是 PR #35 的 base 链 |
| `dev/visual-production-reset` | PR #35 open，当前视觉重建 |
| `dev/river-town-local-high-fidelity-v1` | 当前局部高保真施工线 |
| `dev/prototype-b-representative-battle-content-v1` | PR #30 open / Issue #31 review |
| `archive/legacy-unused` | 历史归档分支，明确无当前权威但仍需保留 |

## B. REMOVE — 可删除分支

以下分支已经合并、被明确 superseded、仅剩无价值 CI 触发提交，或其 tip 已完全落后于 main。删除的是**分支引用**，不是删除 main 当前实现。

### 已合并/已被当前 main 吸收
- `build/battle01-enemy-ai-v1`
- `build/combat-skeleton-v1`
- `build/multi-formation-command-v1`
- `build/recon-contact-v1`
- `build/terrain-los-smoke-v1`
- `design/battle01-connected-playable-contract-v1`
- `dev/core-v1-batch1-migration`
- `dev/prototype-b-core-v1-migration`
- `governance/frontline-project-charter-v2`
- `governance/game-discovery-reset-v1`
- `governance/m2-01-current-state-close`
- `governance/unified-production-system-v1`
- `m2/battle01-runtime-shell-v1`
- `state/frontline-current-product-state-v1`
- `tmp/battle01-3d-foundation-integrated-v1`
- `discovery/prototype-a-command-response-v1`

### 已明确 superseded / 历史 PR 已关闭
- `discovery/prototype-b-representative-command-battle-v1` — PR #21 已标记 SUPERSEDED，后续 Core migration 已进入 main。

### 仅 CI/QA 施工残留，无当前产品依赖
- `ci/formation-definitions-v1`
- `ci/walking-skeleton-verify`
- `qa/formal-roster-runtime-6bdd8dd`
- `chore/repository-cleanup-20260902`

**REMOVE_BRANCH_COUNT=21**

> 某些早期分支相对 main 仍显示少量“ahead commits”，原因是历史 PR 使用 merge/squash 后分支原提交不一定成为 main 的直接祖先。这里的删除判断同时参考了 PR 的 merged/superseded 状态和当前依赖，不只看 ahead/behind 数字。

## C. HOLD — 先不要删

- `discovery/prototype-b-task-reserve-v1`

原因：这是一个已过时的 thin/toy Prototype B 分支，但仍有 6 个相对 main 的独有提交，且没有发现对应的完整归档/PR 记录。它现在没有产品权威，但在把唯一实验内容归档前不做破坏性删除。

RECOMMENDED_NEXT_FOR_HOLD=
archive exact patch or source snapshot -> verify archive -> then REMOVE_BRANCH.

## D. 本次文档清理

三个已明确 superseded 的系统文件已先复制到 `archive/legacy-unused`：

- `FRONTLINE_PROJECT_SYSTEM_V1.md`
- `GPT_MULTI_WINDOW_SYSTEM_V2.md`
- `GPT_WINDOW_RUNTIME_PLAN_V1.md`

清理分支 `chore/repository-hygiene-20260909` 从 main 删除这些旧版本，并把所有入口改到：

- Project System V2
- GPT Multi-Window System V3
- GPT Runtime Plan V2

## E. “可删除分支”

本次清理工作分支：

`chore/repository-hygiene-20260909`

它用于提交仓库地图、入口同步和 main 的旧系统文件清理。**该分支在 PR 合并后本身也应删除。**

## F. 体量说明

删除上述 21 条旧分支会显著降低 GitHub 分支列表噪声，但未必立刻把仓库 644 MB 报告体量降到 main 的 0.55 MB，因为：
- Git 对象可能仍由 PR refs / 其他分支 / 历史提交引用；
- 当前视觉施工分支本身保留约 318–489 MB 的真实资产；
- 真正的历史体量压缩可能需要未来在视觉资产稳定后做 Git history / LFS 级治理。

当前不做 history rewrite，避免破坏正在施工的视觉链。
