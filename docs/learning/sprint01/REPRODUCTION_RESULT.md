# Sprint 01 Independent Complete RTS Reproduction Result

TASK_ID=BUILD_SPRINT01_INDEPENDENT_COMPLETE_REPRODUCTION_V1
REPRODUCTION_STATUS=REPRODUCED
SCENE=res://scenes/learning/sprint01/Sprint01Reproduction.tscn
COMMIT=4acec6965a585bdc82a9ce025b631b5acc20606b
GODOT_VERSION=4.7.1.stable.official.a13da4feb

PLAYER_INPUT=PASS — external X11 keyboard events were injected into the live Godot window with xdotool; runtime received KEY_1 and KEY_M in _unhandled_input.
COMMAND_ROUTE=PASS — KEY_M mutated command state from WAITING_COMMAND to MOVING with COMMAND=ATTACK_MOVE.
MOVEMENT=PASS — Abrams position changed from the logged start position and terminated at contact; final logged position: (3.873,0.180,-2.000).
CONTACT=PASS — CONTACT=PASS.
COMBAT=PASS — authoritative ammo and target HP changed on each fire event; shots=4; final target HP=0.
VISIBLE_FEEDBACK=PASS — every logical shot created same-event 3D muzzle, tracer and impact nodes; destruction additionally changed the target to wreck material/tilt/smoke and a world label.
OUTCOME=PASS — OUTCOME=TARGET_DESTROYED, and the HUD shows PLAYER CHAIN COMPLETE.

REAL_ASSET_BINDING=PASS
ABRAMS_PATH=res://assets/golden_scene/vehicles/mbt_abrams.glb
ABRAMS_GIT_BLOB=24a1410d82c4d21e361f0f15caf0a04271e172bd
ABRAMS_SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9
IFV_PATH=res://assets/golden_scene/vehicles/ifv.glb
IFV_GIT_BLOB=ffe94b094a0d220a53671aa22f73cfe62b2401d7
IFV_SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
ASSET_SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

ENVIRONMENT=PASS — isolated 3D approach road, berms, defensive barriers, contact zone, lighting, camera and HUD; no formal Battle01 modification and no Golden Scene copy.
RUNTIME_EVIDENCE=artifacts/learning/sprint01/runtime.log
INPUT_INJECTION_EVIDENCE=artifacts/learning/sprint01/input_injection.log
CHAIN_EXTRACT=artifacts/learning/sprint01/chain_extract.txt
EXACT_ASSET_EVIDENCE=artifacts/learning/sprint01/exact_asset_binding.txt
SCREENSHOT=artifacts/learning/sprint01/player_chain_final.png
FIRE_SCREENSHOT=artifacts/learning/sprint01/fire_feedback.png
VIDEO_OR_CAPTURE=artifacts/learning/sprint01/player_chain.mp4

REUSED=Godot 4.7.1 toolchain; sanctioned retained real-asset blobs; generic GitHub/Xvfb/ffmpeg capture infrastructure.
NEWLY_IMPLEMENTED=isolated player selection/input path; attack-move command state; deterministic movement/contact; authoritative ammo/HP combat; causal 3D fire/death feedback; player-readable outcome.
TESTED_EDGE=PLAYER_INPUT→COMMAND→MOVEMENT→CONTACT→COMBAT→VISIBLE_FEEDBACK→OUTCOME

CODE_EXISTS=PASS
CODE_EXECUTES=PASS
STATE_CHANGED=PASS
VISIBLE_FEEDBACK=PASS
PLAYER_LAYER=PASS
FAILED_EDGE=NONE
UNKNOWN=NONE

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
