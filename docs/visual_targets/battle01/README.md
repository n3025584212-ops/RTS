# Battle01 Visual Target Assets

STATUS=BINARY_IMPORT_PENDING
SOURCE=CHATGPT_FILE_LIBRARY
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ALIGNMENT_GATE=docs/BATTLE01_VISUAL_TARGET_ALIGNMENT_REWORK_V1.md

This directory is the required first-class visual source for the Battle01 visual rework. Coding agents must not treat the text spec alone as sufficient visual input.

## Required canonical target files

1. `P0-01_FULL_COMBAT_HUD.png`
   - File Library source: `完整战斗HUD设计参考图.png`
   - File id: `file_00000000c928820985132aad2ad96165`
   - Located: YES
   - Binary imported to GitHub: NO

2. `P0-02_RESERVE_DEPLOYMENT_REFERENCE.png`
   - File Library source: `image-gen-1.png`
   - File id: `file_00000000204482078de2a3fe9c72a6eb`
   - Located: YES
   - Note: old purchase/economy details are reference-only and must be adapted to current Reserve Commitment rules.
   - Binary imported to GitHub: NO

3. `P0-03_COMMAND_FEEDBACK.png`
   - File Library source: `P0-03 指挥体系与命令反馈总览.png`
   - File id: `file_00000000dadc82309224c9e19d319ca5`
   - Located: YES
   - Binary imported to GitHub: NO

4. `P0-04_TERRAIN_OBJECTIVE_LAYER.png`
   - File Library source: `战场地形与占点功能图鉴.png`
   - File id: `file_00000000794c81f899447ad6f2fed858`
   - Located: YES
   - Binary imported to GitHub: NO

5. `P0-05_HIGH_INTENSITY_COMBAT.png`
   - File Library source: `高强度交战状态目标图.png`
   - File id: `file_0000000068c0820988b281a5a6b386a1`
   - Located: YES
   - Binary imported to GitHub: NO

6. `P1-06_UNIT_READABILITY_ZOOM.png`
   - Located in project history / File Library: EXPECTED
   - Exact binary source mapping: PENDING
   - Binary imported to GitHub: NO

7. `P1-07_BUILDING_OBJECTIVE_STATE.png`
   - Located in project history / File Library: EXPECTED
   - Exact binary source mapping: PENDING
   - Binary imported to GitHub: NO

8. `FINAL-01_FINAL_BATTLE_PRESENTATION.png`
   - Located in project history / File Library: EXPECTED
   - Exact binary source mapping: PENDING
   - Binary imported to GitHub: NO

## Hard gate

`TARGET_IMAGES_PRESENT_IN_REPOSITORY=NO`

Do not start the next visual rework implementation until the required canonical PNGs are physically present under this directory.

File Library references are not equivalent to repository binaries. The current ChatGPT file-library interface exposes searchable references and multimodal content but does not provide raw PNG bytes to the GitHub write connector. Therefore this manifest records the exact known mappings without falsely claiming that the binaries were committed.

Once the binaries are available, replace each `Binary imported to GitHub: NO` with `YES`, then perform Target-vs-Runtime paired visual acceptance.
