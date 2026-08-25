# BATTLE01_PRODUCT_DESIGN_REVISION_V1

TASK_ID=REVISE_BATTLE01_PRODUCT_DESIGN_AFTER_PRESSURE_TEST_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=AUTHORIZED
UPSTREAM_RESULT=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1=REVISE
UPSTREAM_DOCUMENT=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md
ENGINE=Godot 4.7.1
CURRENT_3D_FOUNDATION=RETAIN
FULL_SCALE_ART_AND_STAGE_2_3=BLOCKED_UNTIL_REVISION_PASS
NO_UNRELATED_SCOPE_EXPANSION=YES

## Purpose

Revise the current Battle01 rules so the existing commander fantasy produces repeated meaningful decisions rather than nominal systems, dominant choices or maintenance micro.

This is not a new game pitch and not a roster/content expansion exercise.

## Required integrated revisions

1. ROLE DIFFERENTIATION
- keep combat deterministic;
- define the smallest fixed role/target interaction needed so Recon, Infantry, IFV and Armor solve different battlefield problems;
- no hit chance, crit, random penetration, complex armor model or suppression system.

2. CAPTURE / CONTEST RESPONSIBILITY
- separate the ability to deny/contest an objective from the ability to establish ownership;
- use this to strengthen Infantry/Mechanized ground-control identity and prevent every armed formation from being interchangeable on objectives.

3. ROUTE + DEFENSE UNCERTAINTY
- freeze Central/North/South as tactically different routes with real movement/LOS/role consequences;
- create a very small authored set of legal RED pre-match defense postures using the existing roster/map;
- posture selection may be seeded per run but moment-to-moment AI remains deterministic and fog-limited.

4. LOGISTICS / AMMO / RESERVE
- rebalance ammo so resupply can matter without becoming mandatory every run;
- make RED Supply actually support RED ammunition using the existing finite supply concept so rear penetration has value;
- convert player Resupply into a Formation-level intent rather than manual parking micro;
- make Infantry-vs-Armor reserve commitment non-dominated through role/terrain/objective asymmetry before considering raw stat tuning.

5. COMMANDER-LEVEL ORDERS
- freeze a compact Formation intent set centered on MOVE, ADVANCE, HOLD, HOLD FIRE, WITHDRAW, RESUPPLY and STOP/CANCEL;
- player chooses intent; routine pathing/spacing/local execution is automated and can always be overridden.

## Required output

Produce one coherent revised Battle01 product contract, not five disconnected mini-designs.

It must explain in plain language:
- what a normal 20-60 second player decision loop becomes;
- how three different opening approaches genuinely differ;
- why Recon remains valuable after repeated runs;
- why Infantry / IFV / Armor / Logistics are not interchangeable;
- why reserve Infantry and reserve Armor can both be correct in different states;
- when Supply matters and why attacking enemy logistics matters;
- what player micro is deliberately automated;
- what old frozen rules need superseding.

After revision, run PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V2 before broad 3D/art implementation resumes.
