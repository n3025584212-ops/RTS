# FRONTLINE_TASK_CLOSEOUT_AUDIT_AND_CLEANUP_V1

STATUS=FROZEN_PROJECT_LEVEL_RULE
OWNER=WINDOW_00_CONTROL
APPLIES_TO=ALL_REGISTERED_FRONTLINE_WINDOWS_AND_EXTERNAL_CODE_EXECUTORS
SOURCE_OF_TRUTH=GITHUB_MAIN
TASK_CLOSEOUT_AUDIT_REQUIRED=YES
ACTIVE_STATE_CLEANUP_REQUIRED=YES
HUMAN_READABLE_RESULT_REQUIRED=YES
MACHINE_ONLY_RESULT_IS_INSUFFICIENT=YES
GIT_HISTORY_IS_PRIMARY_RECOVERY=YES
PLAYABLE_RUNTIME_INTEGRATION_REQUIRED=YES
BEAUTY_SCENE_IS_NOT_PRODUCT_COMPLETION=YES

## 1. Purpose

Every formal FRONTLINE task must end in a clean active project state and a result the user can understand without decoding internal markers, commit hashes, or engineering shorthand.

This rule supplements `FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1` and inherits its minimum-sufficient-evidence, risk-scaled-audit, anti-over-audit, and project-hygiene rules.

## 2. Clean wrong and superseded content from the active project

A task is not cleanly closed if known-wrong, superseded, duplicate, or abandoned content is left mixed with current project truth without a continuing runtime dependency.

After a result is rejected, superseded, killed, or replaced, the responsible window/executor must identify and remove from the active source tree, as applicable:

- wrong-direction implementation documents;
- obsolete acceptance/evidence documents that could be mistaken for current truth;
- generated screenshots/logs/evidence for a rejected direction when they have no continuing diagnostic value;
- abandoned temporary scripts, QA runners, transfer packages, duplicated assets, and stale branches;
- replaced implementation assets and code once the accepted replacement no longer depends on them.

Git history is the recovery mechanism. Keeping a wrong file in current `main` merely because it might be useful someday is not a valid retention reason.

Do not delete unique external source assets, still-valid frozen gameplay rules, or evidence that is the only support for a currently accepted QA gate.

If a rejected implementation is temporarily required to keep the current playable build bootable until its replacement lands, it may remain only as a clearly temporary runtime dependency. The replacement task must remove it when the dependency ends.

There must not be two competing files that both appear to be the current authority for the same decision.

## 3. Task-closeout audit after every formal task

Every formal task performs a focused closeout audit before it is reported complete.

The audit must answer the materially relevant questions:

- Did the delivered result actually satisfy the task intent?
- Did it preserve current frozen rules and avoid unintended scope growth?
- Is the result based on the correct current revision?
- Was the important behavior really executed or otherwise credibly demonstrated where runtime proof is required?
- Were only relevant regressions checked for the task risk?
- Did the task leave wrong, duplicate, superseded, or disposable content behind?
- Is the active project state now unambiguous about what is current truth?
- Is further independent QA required under the project governance?

This closeout audit does not mean every task must be routed through Window 07 or receive a full-project regression. Independent `QA_GATE_RESULT` remains separate and is used when the task risk or downstream acceptance requires it.

## 4. Human-readable user result is mandatory

Every formal task result presented to the user must start with a plain-language summary before machine fields or detailed evidence.

The minimum user-facing result structure is:

### 这次做完了什么
Explain concretely what was added, changed, removed, frozen, or verified.

### 游戏里现在有什么变化
Explain what the player can now see, do, experience, or rely on. If the task did not change runtime gameplay, say so plainly.

### 我实际检查了什么
State the meaningful checks in ordinary language. Do not substitute a wall of markers or filenames for an explanation.

### 结果
Say `通过 / 失败 / 阻塞` and explain why in one or two clear sentences.

### 这次清理了什么
State what obsolete, wrong, duplicate, or temporary content was removed, or say that there was nothing disposable.

### 现在还缺什么
State the important remaining limitation or gap. Do not hide known limitations behind `PASS`.

### 下一步
Give the single current next action, owner/window, and purpose when a next action exists.

Technical fields such as `TASK_ID`, `EXECUTOR_RESULT`, `QA_GATE_RESULT`, commit SHA, CI run, markers, and file lists may follow this explanation. They are supporting evidence, not a replacement for understandable feedback.

## 5. Failure and rework behavior

When a task fails product direction or is killed:

1. Say plainly what failed from the player's/product point of view.
2. Stop expanding the failed direction.
3. Clean disposable outputs from the active tree.
4. Preserve only unique evidence or temporary runtime dependencies that still have a specific purpose.
5. Define the smallest next task that can prove the corrected direction before scaling it up.

A technically successful build is not a successful task if the product result is wrong.

## 6. Visual work must remain part of the playable RTS

The product target is the complete playable FRONTLINE / Battle01 RTS, not a screenshot, isolated camera composition, disconnected visual demo, or standalone beauty scene.

Visual target images define how the real game should look when its actual gameplay is running. They must be translated into the live Battle01 runtime rather than reproduced as a separate showcase that does not contain the real command and combat loop.

For any visual/runtime migration task:

- the work must live in, or be directly integrated toward, the real playable Battle01 runtime;
- selection, movement, combat, reconnaissance/FOW, objectives, enemy AI, logistics/reinforcement flow, victory/defeat, and HUD remain the product context that the visual layer must support;
- a visual checkpoint may validate one area or state, but it is only a checkpoint inside the full-game migration, not the project destination;
- screenshot similarity alone cannot produce `TASK_RESULT=PASS` when the playable RTS loop is absent or broken;
- a standalone beauty scene may be used only for isolated technical experimentation and must never be mistaken for product completion or final acceptance;
- each migration stage should leave a real playable build whenever technically feasible, so visual quality and gameplay integration advance together rather than diverge;
- final acceptance asks whether the target images have effectively become the playable game world, not whether one staged view resembles a target image.

The correct relationship is:

`FULL_PLAYABLE_RTS = PRODUCT_GOAL`

`VISUAL_TARGET_CHECKPOINT = ONE_ACCEPTANCE_AXIS`

`BEAUTY_SCENE = NOT_PRODUCT_COMPLETION`

## 7. Completion condition

A formal task is not fully closed until both are true:

- TASK_RESULT_IS_CREDIBLY_AUDITED=YES
- ACTIVE_PROJECT_STATE_IS_CLEAN=YES

And the user-facing reply must be understandable without reading internal project files.
