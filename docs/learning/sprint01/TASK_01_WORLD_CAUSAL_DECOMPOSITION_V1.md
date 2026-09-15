# FRONTLINE — Sprint 01 Stage 4 World Causal Decomposition Task V1

STATUS=ACTIVE
TASK_ID=LEARN_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1
WINDOW_ID=01
WINDOW_ROLE=EVIDENCE_AND_LEARNING
ACTIVE_ISSUE=#39
CONTROL_WINDOW=00

## Why this task exists

Sprint 01 runtime work has proven a real causal gameplay slice can execute:

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

However the independent player-layer audit failed the delivery result because the reproduction world remained a primitive test environment and the player-facing unit/world presentation was not acceptable.

The Sprint 01 contract already required Stage 4 to reconstruct world causality before the final independent reproduction:

`terrain -> transport -> parcels/land-use -> settlement -> vegetation -> tactical space -> materials -> lighting -> camera`

That Stage 4 closure is now the only active learning objective.

## Scope

Window 01 must produce:

`docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

The document must explain, with inspectable evidence, how at least one mature RTS / real-time-tactics reference creates a believable playable battlefield region from upstream world/content decisions through final player readability.

This is not a visual-style essay and not a list of scene objects.

## Required causal chain

For one concrete playable region / scenario / map-content route, trace the evidence-supported connections:

1. TERRAIN
2. TRANSPORT / ROAD / CROSSING STRUCTURE
3. PARCELS / LAND-USE / ZONING OR EQUIVALENT SPATIAL ORGANIZATION
4. SETTLEMENT / BUILT CONTENT
5. VEGETATION / NATURAL COVER
6. TACTICAL SPACE / MOVEMENT / COVER / LOS CONSEQUENCES
7. MATERIAL / SURFACE CONTENT PIPELINE
8. LIGHTING / ENVIRONMENT
9. CAMERA / SCALE / READABILITY
10. FINAL PLAYER-VISIBLE WORLD RESULT

Each important edge must record:

- CLAIM
- SOURCE
- SOURCE_VERSION / COMMIT / RELEASE
- STATUS=`OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`
- WHAT_THE_SOURCE_ACTUALLY_PROVES
- WHAT_IT_DOES_NOT_PROVE
- ALTERNATIVE_EXPLANATION
- FRONTLINE_TRANSFER_RELEVANCE

## Reference discipline

Primary-source evidence is preferred.

0 A.D. may be used where version identity is qualified consistently with the existing audit. BAR/Recoil and Warzone must be used where they provide counterexamples or alternative production structures.

Commercial games such as WARNO / Broken Arrow / Regiments may be used as player-visible result references, but screenshots/videos may not be used to invent undocumented internal production methods.

## Historical FRONTLINE material

The following are evidence/tool pools only and do not have current design authority:

- Golden Scene V1
- River Town
- Reference Region
- local high-fidelity branches
- Battle01 / Prototype B

They may be inspected to answer:

- what assets/tools already exist;
- what prior visual failures occurred;
- which prior methods are reusable after evidence support.

They may NOT be cited as proof of how a mature RTS should build a world.

## Hard prohibitions

Do not:

- continue polishing `Sprint01Reproduction.tscn`;
- modify the proven gameplay causal semantics;
- start a new FRONTLINE product slice;
- restore an old visual branch as the new baseline;
- generate a new target image instead of learning the production method;
- infer mature production logic from a screenshot alone;
- use Box/Plane/color-block presence as evidence of world-production understanding;
- convert one project-specific implementation into a universal RTS rule;
- fill UNKNOWN with plausible prose.

## Completion gate for Window 01

Window 01 is complete only when:

1. `WORLD_CAUSAL_DECOMPOSITION.md` exists;
2. at least one concrete mature reference world chain is traced end-to-end;
3. version/source identity is explicit;
4. player-visible result is connected to upstream world decisions without unsupported jumps;
5. alternatives/counterexamples are recorded;
6. explicit UNKNOWN remains where evidence is missing;
7. the document identifies which specific production methods are candidates for the next isolated reproduction;
8. the work is committed to `learning/sprint01-end-to-end-rts-production` with a commit SHA.

## Next route

After Window 01 completes this task:

`01 WORLD CAUSAL DECOMPOSITION -> 03 WORLD METHOD AUDIT`

Window 02 remains HOLD until Window 03 passes the world-production method.

Window 03 remains HOLD until Window 01 delivers the committed artifact.

PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO
