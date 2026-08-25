# BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V1

TASK_ID=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=CLOSED_REVISE
RESULT=REVISE
RESULT_DOCUMENT=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md
SOURCE_OF_TRUTH=GITHUB_MAIN
BASE_COMMIT=a197372ab5021a5acb0bb6124d734eb84dc7aa35
ENGINE=Godot 4.7.1
FULL_SCALE_STAGE_2_3_EXPANSION_BLOCKED_UNTIL_REVISION_GATE=YES
NO_AUTOMATIC_SCOPE_EXPANSION=YES

## 1. Gate purpose

Battle01 now has a real 3D technical foundation in main. Before adding expensive 3D gameplay closure, final world art, large asset production, or broader content, the game design itself was pressure-tested as a playable product rather than assumed correct because individual systems exist.

The test asked whether reconnaissance, movement, combat, AI, objectives, logistics and reinforcement combine into understandable, interesting, consequential player decisions with good pacing and manageable Formation-level command workload.

## 2. Closed result

The gate closed as REVISE.

The core direction is retained, but expensive Stage 2/3 expansion remains blocked until the required design revisions identified in `docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md` are explicitly closed.

Critical revision areas are:

1. deterministic role differentiation beyond raw stats;
2. capture/contest responsibility;
3. meaningful route identities and limited pre-match RED defense uncertainty;
4. ammo/logistics pressure that actually matters in the match;
5. a non-dominated reserve decision;
6. commander-level intent orders that avoid parking/movement busywork.

The already-landed 3D foundation is retained. No rollback is required.

## 3. Implementation hold

Until the revision gate closes:

- do not expand into large final-art production;
- do not mass-produce units/buildings/VFX;
- do not add unrelated gameplay scope;
- do not perform broad Stage 2/3 migration based on the superseded assumptions;
- focused fixes needed to keep the current build bootable/testable remain allowed.

## 4. Human-readable reporting requirement

The result is not represented by this marker file alone. The user-facing explanation must state in ordinary language what is strong, what is fake/weak, what must change, what remains blocked, and what the next concrete design action is.
