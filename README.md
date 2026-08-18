# FRONTLINE / 战线

现代战争题材、俯视斜视角、以 Formation / Platoon 级指挥为核心的实时战术 / RTS 项目。

## 当前状态

- Engine: Godot 4.7.1
- Source of truth: 本仓库
- Previous local project: 已删除，不继承旧工程 PASS/进度
- Current phase: Battle01 rebuild / Walking Skeleton
- Product baseline: `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- Vertical slice spec: `docs/BATTLE01_VERTICAL_SLICE_SPEC_V1.md`

## Runtime verification

仓库内 `.github/workflows/godot-runtime-verify.yml` 在 push / pull request 时下载固定版本 Godot 4.7.1，并执行：

1. Godot version check
2. Headless editor parse/import
3. Main scene runtime smoke
4. `FRONTLINE_BOOT_OK` boot marker verification
5. Runtime logs artifact upload

## Repository layout

```text
project.godot
scenes/battle01/
scripts/battle01/
resources/
assets/
tests/
docs/
.github/workflows/
```

当前仓库从零重建，不恢复已删除本地工程。
