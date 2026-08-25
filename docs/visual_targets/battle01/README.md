# Battle01 Visual Target Assets

STATUS=BINARY_IMPORT_READY_LOCAL_EXECUTOR
SOURCE_PACKAGE=`FRONTLINE_BATTLE01_VISUAL_TARGETS_V1(1).zip`
SOURCE_PACKAGE_VALIDATED=YES
IMAGE_COUNT=8
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ALIGNMENT_GATE=docs/BATTLE01_VISUAL_TARGET_ALIGNMENT_REWORK_V1.md

This directory is the required first-class visual source for the Battle01 visual rework. Coding agents must not treat the text specification alone as sufficient visual input.

The packaged source has been opened and validated by Window 06. It contains exactly the eight canonical PNG target assets below; there are no missing, duplicate, or process images.

## Canonical target files and immutable source hashes

| Target | Dimensions | SHA256 | Binary imported to GitHub |
|---|---:|---|---|
| `P0-01_FULL_COMBAT_HUD.png` | 1536x1024 | `db5c45730280dba79be70b6864a0b7c2559432c4c83d685f9d5d9ce9ef1c43d2` | NO |
| `P0-02_RESERVE_DEPLOYMENT_REFERENCE.png` | 1536x1024 | `d5b37c46e6d33af895cc07daeebdeb200acd33a60dce549c54fdb6fc1ecb3f11` | NO |
| `P0-03_COMMAND_FEEDBACK.png` | 1536x1024 | `95590ea8d3957101ad312dd08e38215dcee798bd3b0f46e96bd1b1aa5b77ff82` | NO |
| `P0-04_TERRAIN_OBJECTIVE_LAYER.png` | 1536x1024 | `1fb65bb062f5fdd71681be71ec203b6b9281fb23388dda6916ddf4d2c6e060d0` | NO |
| `P0-05_HIGH_INTENSITY_COMBAT.png` | 1536x1024 | `25d8b0fd99cea1922c4d03ca0d84f3f44697421de4a4db8a46be5b783f82c6b9` | NO |
| `P1-06_UNIT_READABILITY_ZOOM.png` | 1672x941 | `f00d1384642152dc7d656c41fe3b1d865176e67e99591af0763758bc527dd76b` | NO |
| `P1-07_BUILDING_OBJECTIVE_STATE.png` | 1672x941 | `83c3826c28c763d9f134c7fab6b70dc4dca633ba6b9096e8c8d5780834cdbea0` | NO |
| `FINAL-01_FINAL_BATTLE_PRESENTATION.png` | 1672x941 | `92e0d8bdf53bb2542f0eedc04ad548c047cc0fc11701bb7dad8253e56ad784a3` | NO |

## Gameplay adaptation note

`P0-02_RESERVE_DEPLOYMENT_REFERENCE.png` preserves the visual hierarchy and clarity of a deployment decision only. Any old purchase/currency/economy semantics in the image must be adapted to the current frozen one-choice Reserve Commitment contract. Target imagery never overrides current gameplay.

## Binary import gate

`TARGET_IMAGES_PRESENT_IN_REPOSITORY=NO`

The canonical originals have now been packaged and verified, but the ChatGPT-to-GitHub connector cannot pass local binary file paths to GitHub's binary-write endpoint. Do not substitute recompressed or regenerated images and do not mark the gate complete until the exact PNG files above are present with matching SHA256 values.

The local coding executor shall locate the already-existing package on the user's Windows machine, extract these exact eight files into this directory, verify all hashes, commit, and push to `origin/main`.

After exact binary import, update this manifest to:

- `STATUS=BINARY_IMPORT_COMPLETE`
- every `Binary imported to GitHub` value = `YES`
- `TARGET_IMAGES_PRESENT_IN_REPOSITORY=YES`

Only then may `REWORK_BATTLE01_VISUAL_TARGET_ALIGNMENT_V1` begin. Final acceptance requires Target-vs-Runtime paired visual comparison; functional state coverage alone is insufficient.
