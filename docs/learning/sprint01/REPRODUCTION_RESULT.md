# Sprint 01 Independent Complete RTS Reproduction Result

TASK_ID=BUILD_SPRINT01_INDEPENDENT_COMPLETE_REPRODUCTION_V1
GATE_TASK_ID=COMPLETE_SPRINT01_RUNTIME_PLAYER_GATE_V1
REPRODUCTION_STATUS=REPRODUCED
SCENE=res://scenes/learning/sprint01/Sprint01Reproduction.tscn
IMPLEMENTATION_COMMIT=399b181fdf9b66bbd17ecded617ef7a124be8231
BRANCH_HEAD_BEFORE_RUNTIME=09df299e8c39b37479a35c55b5301321acdb9222
GODOT_VERSION=4.7.1.stable.official.a13da4feb
RUNTIME_ROUTE=LOCAL_LINUX_X11_XVFB_WITH_EXTERNAL_PYTHON_XTEST_INPUT

PLAYER_INPUT=PASS — external X11 keyboard events were injected into the live Godot window through XTest; runtime received KEY_1 and KEY_M in _unhandled_input.
COMMAND_ROUTE=PASS — KEY_M mutated command state from WAITING_COMMAND to MOVING with COMMAND=ATTACK_MOVE.
MOVEMENT=PASS — Abrams moved from (-18.000,0.180,-2.000) to contact at approximately (3.966,0.180,-2.000); movement delta 21.97.
CONTACT=PASS — RED_IFV_01 was contacted at logged range 10.03.
COMBAT=PASS — four authoritative FIRE events reduced ammo 4→0 and target HP 100→0.
VISIBLE_FEEDBACK=PASS — every logical shot produced same-event 3D muzzle/tracer/impact feedback; fresh screenshot visibly shows tracer/impact/hit feedback; destruction visibly changes the target to a dark wreck/tilted state with smoke/label and final HUD outcome.
OUTCOME=PASS — OUTCOME=TARGET_DESTROYED and final HUD visibly shows TARGET DESTROYED / PLAYER CHAIN COMPLETE.

REAL_ASSET_BINDING=PASS
ABRAMS_PATH=res://assets/golden_scene/vehicles/mbt_abrams.glb
ABRAMS_GIT_BLOB=24a1410d82c4d21e361f0f15caf0a04271e172bd
ABRAMS_SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9
IFV_PATH=res://assets/golden_scene/vehicles/ifv.glb
IFV_GIT_BLOB=ffe94b094a0d220a53671aa22f73cfe62b2401d7
IFV_SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
ASSET_SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

SOURCE_BYTE_VERIFICATION=PASS
PROJECT_GIT_BLOB=4c2313a4132f10de8162abe5f194b9f9328869f0
SCENE_GIT_BLOB=504a6893a969f10f656d7bbbbc9789aefaf555b1
SCRIPT_GIT_BLOB=ba2dfa71cf59473171e541acb2fb04e7ed4ba380

RUNTIME_EVIDENCE=artifacts/learning/sprint01/runtime.log
RUNTIME_EVIDENCE_SHA256=7bf1c354b06a9221215361b94249be1d94ce486756a00a21ef5cd9ab4afb30fd
INPUT_INJECTION_EVIDENCE=artifacts/learning/sprint01/input_injection.log
INPUT_INJECTION_EVIDENCE_SHA256=f5da8dec9be10cc0efd4d9c63de15b38524cb6003364ed2b44b595afd6f09119
CHAIN_EXTRACT=artifacts/learning/sprint01/chain_extract.txt
CHAIN_EXTRACT_SHA256=782b8d7939634edbdb4434c730fa89dbe2495b1f6408ba87f6789233c3fb9368
EXACT_ASSET_EVIDENCE=artifacts/learning/sprint01/exact_asset_binding.txt
EXACT_ASSET_EVIDENCE_SHA256=ff498fe00ce59c9685dc92a8f5c6b5e9f19805aa2575a79ea4649c7d89009904
FIRE_SCREENSHOT=artifacts/learning/sprint01/fire_feedback.png
FIRE_SCREENSHOT_SHA256=365d2c0744c10500dd1512e26eb1eba02453290dd2156e3e68e118a6386fa1c1
FINAL_SCREENSHOT=artifacts/learning/sprint01/player_chain_final.png
FINAL_SCREENSHOT_SHA256=4701381842346a267e669fcb9b90019a40bdb03efa4d805b706cd3f2d5609e90
VIDEO_OR_CAPTURE=artifacts/learning/sprint01/player_chain.mp4
VIDEO_OR_CAPTURE_SHA256=3287285fbc3cbfd8891971d472b17ace2ef470d6541cef99432af28c4f3c8adf
VIDEO_DURATION_SECONDS=9.533333
GITHUB_TEXT_EVIDENCE_PERSISTENCE=PASS
BINARY_CAPTURE_PRODUCTION=PASS_FRESH_LOCAL_FILES
BINARY_CAPTURE_GITHUB_PERSISTENCE=PENDING_CONNECTOR_BINARY_UPLOAD_LIMIT
WINDOW03_BINARY_EVIDENCE_TRANSFER=REQUIRED_BEFORE_INDEPENDENT_VISUAL_AUDIT

RUNTIME_NOTE=The isolated local runtime package intentionally contained only the exact Sprint01 scene/script/project bytes plus the two sanctioned GLBs. Godot editor import successfully imported both GLBs but reported the unrelated formal Battle01 main scene missing from this minimal package. No Battle01 placeholder was created and no formal Battle01 file was modified. The explicit Sprint01 scene then executed successfully in graphical X11 mode. ALSA was unavailable in the container and Godot fell back to the dummy audio driver; this reproduction has no audio acceptance edge and the player chain was unaffected.

REUSED=Godot 4.7.1 toolchain; sanctioned retained real-asset blobs; generic Xvfb/ffmpeg capture infrastructure.
NEWLY_IMPLEMENTED=none during this gate; the already-audited implementation at 399b181f was executed without redesign.
TESTED_EDGE=PLAYER_INPUT→COMMAND→MOVEMENT→CONTACT→COMBAT→VISIBLE_FEEDBACK→OUTCOME

CODE_EXISTS=PASS
CODE_EXECUTES=PASS
STATE_CHANGED=PASS
VISIBLE_FEEDBACK=PASS
PLAYER_LAYER=PASS
PLAYER_CHAIN_PASS=YES
FAILED_EDGE=NONE
UNKNOWN=NONE

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
NEXT_ROUTE=WINDOW_03_INDEPENDENT_RUNTIME_AND_PHYSICAL_AUDIT
