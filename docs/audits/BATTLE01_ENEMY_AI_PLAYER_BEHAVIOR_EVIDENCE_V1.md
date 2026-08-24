# Battle01 Enemy AI Player Behavior Evidence V1

## Evidence identity

```text
TASK_ID=PUBLISH_BATTLE01_ENEMY_AI_PLAYER_BEHAVIOR_EVIDENCE_V1
REPOSITORY=n3025584212-ops/-
BRANCH=main
TESTED_GAME_COMMIT=0cef3a9b1e1dd2078d9eb25966949c8dc96b1929
PUBLICATION_BASE=96dd0ba8c74e52662271c6a113dcfe31baad0b68
AUDIT_PUBLICATION_COMMIT=GIT_COMMIT_CONTAINING_THIS_FILE
GODOT_VERSION=4.7.1.stable.official.a13da4feb
TEST_TIME=2026-08-24T10:51:17Z
QA_RUNNER=tests/battle01_enemy_ai_player_behavior_evidence.gd
QA_RUNNER_SHA256=1FE68672FA126A3420541119FD638EFAF2C858DD9C405FDDDB344C703E60945C
EXIT_CODE=0
BLOCKING_RUNTIME_ERRORS=NONE
GAMEPLAY_CHANGED=NO
RESULT=PASS
```

The focused runner was invoked externally against a detached worktree whose `git rev-parse HEAD` was the exact `TESTED_GAME_COMMIT` before and after execution. It loads the tested commit's Battle01 scene, then calls its existing production perception, decision, navigation, and Formation movement methods with deterministic QA fixtures. It does not replace or modify AI/gameplay logic. The only publication additions are this audit and the standalone `tests/` runner; no full regression suite was rerun.

```powershell
$Godot = 'C:\Users\念\FRONTLINE_RUNTIME_VERIFY\godot\Godot_v4.7.1-stable_win64_console.exe'
$Runner = 'C:\Users\念\FRONTLINE_RUNTIME_VERIFY\audit_worktrees\enemy_ai_audit_main\tests\battle01_enemy_ai_player_behavior_evidence.gd'
Set-Location 'C:\Users\念\FRONTLINE_RUNTIME_VERIFY\audit_worktrees\enemy_ai_verified_0cef3a9'
& $Godot --headless --path . --script $Runner
```

## 1. Pursuit / bait return

BLUE was legitimately detected, progressed through CONTACT to CONFIRMED, and caused RED INF-01 to begin a bounded pursuit. After BLUE left legal detection, intel changed to LAST_KNOWN; RED investigated the frozen point rather than the hidden current position, then returned to its defense anchor.

```text
PLAYER_AI_TELEMETRY t=0.01 scenario=PURSUIT_RETURN event=legal_contact unit="RED INF-01" intel=CONTACT ai=HOLD mission=BRIDGEHEAD_ANCHOR route=central pos=(1370.0,900.0) legit_detected=true
PLAYER_AI_TELEMETRY t=0.77 scenario=PURSUIT_RETURN event=confirmed_engage unit="RED INF-01" intel=CONFIRMED ai=ENGAGE mission=BRIDGEHEAD_ANCHOR route=central pos=(1370.0,900.0) legit_detected=true engage_origin=(1370.0,900.0)
PLAYER_AI_TELEMETRY t=1.27 scenario=PURSUIT_RETURN event=bounded_pursuit unit="RED INF-01" intel=CONFIRMED ai=ENGAGE mission=BRIDGEHEAD_ANCHOR route=central pos=(1380.0,860.0) pursued=41.2 leash=350.0
PLAYER_AI_TELEMETRY t=1.28 scenario=PURSUIT_RETURN event=lost_confirmation unit="RED INF-01" intel=LAST_KNOWN ai=INVESTIGATE mission=BRIDGEHEAD_ANCHOR route=north pos=(1380.0,860.0) actual_blue=(520.0,900.0) frozen_last_known=(1370.0,620.0) hidden_offset=894.9
PLAYER_AI_TELEMETRY t=5.38 scenario=PURSUIT_RETURN event=return_started unit="RED INF-01" intel=LAST_KNOWN ai=RETURN mission=BRIDGEHEAD_ANCHOR route=central pos=(1380.0,860.0) home_dist=41.2
PLAYER_AI_TELEMETRY t=9.38 scenario=PURSUIT_RETURN event=recenter_complete unit="RED INF-01" intel=LAST_KNOWN ai=HOLD mission=BRIDGEHEAD_ANCHOR route=central pos=(1380.0,900.0) home_dist=10.0 target_cleared=true result=PASS
PLAYER_AI_PURSUIT_RETURN_PASS
```

## 2. Armor reserve cycle

RED ARMOR-01 began at its reserve anchor in HOLD. Legitimately confirmed bridgehead pressure committed it to ENGAGE and caused real displacement. After the objective stabilized and confirmation was lost, it completed INVESTIGATE / RETURN and restored HOLD within the arrival tolerance of its reserve anchor.

```text
PLAYER_AI_TELEMETRY t=0.00 scenario=ARMOR_RESERVE event=reserve_hold unit="RED ARMOR-01" intel=UNSEEN ai=HOLD mission=LOCAL_COUNTERATTACK_RESERVE route=central pos=(1370.0,1020.0) role=LOCAL_COUNTERATTACK_RESERVE home_dist=0.0
PLAYER_AI_TELEMETRY t=0.77 scenario=ARMOR_RESERVE event=objective_pressure_commit unit="RED ARMOR-01" intel=CONFIRMED ai=ENGAGE mission=LOCAL_COUNTERATTACK_RESERVE route=south pos=(1370.0,1020.0) objective=CONTESTED legit_detected=true selected_target=BLUE IFV-01 target_dist=336.0 path_dist=362.8
PLAYER_AI_TELEMETRY t=1.77 scenario=ARMOR_RESERVE event=commit_movement unit="RED ARMOR-01" intel=CONFIRMED ai=ENGAGE mission=LOCAL_COUNTERATTACK_RESERVE route=south pos=(1420.0,980.0) moved_from_reserve=64.0
PLAYER_AI_TELEMETRY t=5.88 scenario=ARMOR_RESERVE event=return_to_reserve unit="RED ARMOR-01" intel=LAST_KNOWN ai=RETURN mission=LOCAL_COUNTERATTACK_RESERVE route=south pos=(1420.0,980.0) home_dist=64.0
PLAYER_AI_TELEMETRY t=10.88 scenario=ARMOR_RESERVE event=reserve_restored unit="RED ARMOR-01" intel=LAST_KNOWN ai=HOLD mission=LOCAL_COUNTERATTACK_RESERVE route=south pos=(1380.0,1020.0) posture=HOLD home_dist=10.0 result=PASS
PLAYER_AI_ARMOR_RESERVE_PASS
```

## 3. Supply evade

RED SUPPLY-01 began in rear SUPPORT with combat and capture disabled. A legitimate CONFIRMED threat replaced its unsafe support destination with an opposite EVADE destination; production movement increased threat separation while the truck remained unable to attack, capture, or contest.

```text
PLAYER_AI_TELEMETRY t=0.00 scenario=SUPPLY_EVADE event=rear_support unit="RED SUPPLY-01" intel=UNSEEN ai=SUPPORT mission=REAR_SUPPORT route=central pos=(1490.0,1080.0) objective_dist=211.0 can_attack=false can_capture=false
PLAYER_AI_TELEMETRY t=0.25 scenario=SUPPLY_EVADE event=support_advance unit="RED SUPPLY-01" intel=UNSEEN ai=MOVE mission=REAR_SUPPORT route=central pos=(1490.0,1080.0) advance_destination=(2020.0,1060.0)
PLAYER_AI_TELEMETRY t=1.02 scenario=SUPPLY_EVADE event=confirmed_threat_evade unit="RED SUPPLY-01" intel=CONFIRMED ai=EVADE mission=REAR_SUPPORT route=central pos=(1490.0,1080.0) legit_detected=true prior_advance=(2020.0,1060.0) evade_destination=(1100.0,1100.0) threat_dist=180.0
PLAYER_AI_TELEMETRY t=2.02 scenario=SUPPLY_EVADE event=evade_displacement unit="RED SUPPLY-01" intel=CONFIRMED ai=EVADE mission=REAR_SUPPORT route=central pos=(1420.0,1060.0) threat_before=180.0 threat_after=250.8 objective_dist=240.8 attacks=0 captures=0 contests=0 result=PASS
PLAYER_AI_SUPPLY_EVADE_PASS
```

## 4. Flank response

BLUE Recon began on the North route outside legitimate detection. A production decision tick caused no pre-detection reaction. After BLUE moved into legitimate confirmation, RED INF-02 was the sole immediate combat responder; INF-01 and Armor remained out of the responder set, Supply remained SUPPORT, and dormant reinforcements remained inactive.

```text
PLAYER_AI_TELEMETRY t=0.00 scenario=FLANK_RESPONSE event=north_route_unseen unit="RED INF-02" intel=UNSEEN ai=HOLD mission=FLANK_SCREEN route=central pos=(1370.0,780.0) route=north legit_detected=false combat_states=RED INF-01:HOLD,RED INF-02:HOLD,RED ARMOR-01:HOLD no_pre_reaction=true
PLAYER_AI_TELEMETRY t=0.77 scenario=FLANK_RESPONSE event=north_route_confirmed unit="RED INF-02" intel=CONFIRMED ai=ENGAGE mission=FLANK_SCREEN route=north pos=(1370.0,780.0) route=north legit_detected=true intel=CONFIRMED responders=RED INF-02 supply=SUPPORT reinforcements_active=false preferred_local_only=true result=PASS
PLAYER_AI_FLANK_RESPONSE_PASS
```

## Executor conclusion

```text
PURSUIT_RETURN_EVIDENCE=PASS
ARMOR_RESERVE_CYCLE_EVIDENCE=PASS
SUPPLY_EVADE_EVIDENCE=PASS
FLANK_RESPONSE_EVIDENCE=PASS
PLAYER_BEHAVIOR_EVIDENCE=PASS
GAMEPLAY_CHANGED=NO
```
