# BATTLE01 Visual Implementation Runtime Evidence V2

TASK_ID=IMPLEMENT_BATTLE01_VISUAL_IMPLEMENTATION_SPEC_V2
ENGINE=Godot 4.7.1.stable.official.a13da4feb
START_COMMIT=adc14b409dc08cb863af5316cb11b88d2daec3db
EVIDENCE_GENERATOR=`tests/battle01_visual_evidence.gd`
EVIDENCE_DIRECTORY=`docs/audits/evidence/battle01_visual_v2`

The evidence generator instantiates the real `Battle01.tscn`, waits for rendered frames, stages only focused QA states through existing runtime/test interfaces, and saves the actual 1600x900 viewport. It does not add a player-facing gameplay path.

## Player-visible evidence

1. `01_opening_hud.png` — normal-player opening HUD, prototype overlay absent, Central active, Industrial locked, Reserve locked, legal minimap.
2. `02_multi_selection_move.png` — compact multi-selection cards, exact friendly state, green MOVE routes and acknowledgements.
3. `03_far_zoom_confirmed_minimap.png` — FAR tactical-marker tier, confirmed RED identity and legal minimap marker.
4. `04_central_contested.png` — Central amber contested footprint, owner retained, tactical alert.
5. `05_central_capture_progress.png` — live 15-second capture progress in world and HUD.
6. `06_central_reserve_industrial_unlocked.png` — first Central capture hinge, Reserve and Industrial unlock.
7. `07_reserve_committed_withdraw.png` — one-choice Reserve committed/unavailable states and yellow dashed Withdraw route to Bridgehead Rally.
8. `08_ammo_supply_progress.png` — cyan AMMO-only link, actual 4-second progress and unchanged charges.
9. `09_ammo_supply_interrupted.png` — movement interruption, cleared progress/link, unchanged charges and tactical feedback.
10. `10_ammo_supply_complete.png` — real ammo restored and Supply charge decremented without HP restoration language.
11. `11_industrial_contested_high_intensity.png` — Industrial Critical contest, confirmed RED formations, simultaneous Infantry/IFV fire readability.
12. `12_victory_overlay.png` — formal dual-objective Victory and Restart.
13. `13_defeat_overlay.png` — formal irrecoverable-force Defeat and Restart.

## Runtime checks executed

- Godot editor parse/import: exit 0; no blocking parse/runtime error.
- Battle01 boot: `FRONTLINE_BOOT_OK`; exact player force, objectives, formal RED roster, Enemy AI and presentation adapter initialized.
- `formal_combat_roster_smoke.gd`: `FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS`.
- `battle01_logistics_flow_smoke.gd`: `FRONTLINE_LOGISTICS_FLOW_SMOKE_PASS` including Supply success/interruption/death, Withdraw/re-entry, 15s objectives, Reserve, Victory and Defeat.
- `battle01_enemy_ai_final_objective_smoke.gd`: `FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_SMOKE_PASS`.
- Recon/LOS/combat runtime: `FRONTLINE_TERRAIN_LOS_SMOKE_PASS`, `FRONTLINE_RECON_CONTACT_SMOKE_PASS`, `FRONTLINE_COMBAT_SMOKE_PASS`.
- Multi-selection/command runtime: `FRONTLINE_MULTI_FORMATION_COMMAND_SMOKE_PASS`.
- Navigation regression: `FRONTLINE_NAVIGATION_SMOKE_PASS`.
- Enemy AI deterministic regression: `FRONTLINE_ENEMY_AI_SMOKE_PASS`.
- Visual viewport run: `FRONTLINE_VISUAL_EVIDENCE_PASS screenshots=13`.

DEBUG_OVERLAY_DEFAULT=OFF
UNSEEN_RED_MINIMAP_LEAK=NO
LAST_KNOWN_LIVE_TRACKING=NO
GAMEPLAY_RULE_CHANGED=NO
SCOPE_EXPANSION=NO
