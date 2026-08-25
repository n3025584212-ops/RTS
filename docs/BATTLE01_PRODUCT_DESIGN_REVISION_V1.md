# BATTLE01_PRODUCT_DESIGN_REVISION_V1

TASK_ID=REVISE_BATTLE01_PRODUCT_DESIGN_AFTER_PRESSURE_TEST_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=COMPLETE
UPSTREAM_RESULT=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1=REVISE
UPSTREAM_DOCUMENT=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md
OUTPUT=docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md
DOWNSTREAM_GATE=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V2_RESULT.md
DOWNSTREAM_GATE_RESULT=PASS
ENGINE=Godot 4.7.1
CURRENT_3D_FOUNDATION=RETAIN
NO_UNRELATED_SCOPE_EXPANSION=YES

## Purpose

Revise Battle01 so the commander fantasy produces repeated meaningful decisions rather than nominal systems, dominant choices or maintenance micro.

## Completed integrated revisions

1. ROLE DIFFERENTIATION — deterministic fixed target-class effectiveness now differentiates Recon / Infantry / IFV / Armor without adding random hit/penetration/suppression systems.

2. CAPTURE / CONTEST — ownership capture is separated from contest/denial so Infantry/IFV provide ground control while Armor provides heavy denial/firepower.

3. ROUTE + DEFENSE UNCERTAINTY — Central/North/South now have distinct navigation/LOS/access purposes and three authored seeded RED defense postures keep Recon relevant across repeat runs while moment-to-moment AI remains deterministic/fog-limited.

4. LOGISTICS / AMMO / RESERVE — ammo is reduced to create real sustain pressure; RED Supply gains real finite resupply; player Resupply becomes an intent rather than parking micro; Infantry-vs-Armor reserve value now depends on ground-control/terrain/heavy-fire state.

5. COMMANDER-LEVEL ORDERS — MOVE / ADVANCE / HOLD / HOLD FIRE / WITHDRAW / RESUPPLY / STOP-CANCEL are the compact intent vocabulary; routine pathing/spacing/rendezvous execution belongs to Formation logic and direct player orders override automation.

## Result

The revised design passed `PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V2` for implementation readiness.

This is not proof that exact numbers are final or that the game is already fun in runtime. The next step is to implement the revised rules inside the existing real 3D-backed Battle01, then validate them through actual playable scenarios before full final-art production resumes.
