# FRONTLINE — Sprint 01 Stage 4 World Method Audit Task V1

STATUS=ACTIVE
TASK_ID=AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
ACTIVE_ISSUE=#39
CONTROL_WINDOW=00

## Audit input

WINDOW_01_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
INPUT_ARTIFACT=docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md
PARENT_CONTROL_TASK=docs/learning/sprint01/TASK_01_WORLD_CAUSAL_DECOMPOSITION_V1.md
AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Mission

Independently audit whether Window 01 actually closed a source-grounded world-production method suitable for the next isolated reproduction.

Do not restate Window 01. Falsify it.

The audit must apply all six hard checks:

1. PRIMARY_SOURCE_INTEGRITY
2. VERSION_IDENTITY
3. RUNTIME_SEMANTICS
4. GENERALIZATION_BOUNDARY
5. ALTERNATIVE_EXPLANATIONS
6. COUNTEREXAMPLE_SEARCH

## Mandatory audit targets

Audit the proposed world chain as a branching constraint graph, not a decorative object list:

- terrain / authoritative topology;
- movement corridor continuity;
- land-use / semantic spatial constraints;
- built-content anchors;
- vegetation grouping and spacing;
- topology -> passability relationship;
- surface/material role -> real asset/material vocabulary;
- lighting/environment state;
- camera/readability boundary;
- player-visible result boundary.

## Specific falsification questions

### A. 0 A.D. source/version

Confirm or reject every important claim derived from inspected source state:

a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d

Do not upgrade it to proven exact authoritative Release 28 identity unless new authoritative evidence closes that relation.

The allowed current relation is:

RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28

### B. Selected world route

Independently inspect the Alpine Valley route and determine whether Window 01 correctly distinguishes:

- observed source behavior;
- project-specific inference;
- cross-project pattern;
- reproduction candidate;
- unsupported generalization.

Particular attention:

- local CityPatch road surface must not be promoted into a map-wide road-network proof;
- passage preservation must not be promoted into designer-authored tactical chokepoint intent without evidence;
- tile classes must not be promoted into required RTS land-use architecture;
- camera/global render configuration must not be presented as map-specific authored causality unless source supports it.

### C. Counterexample discipline

Verify that Warzone materially falsifies the necessity of 0 A.D.-style procedural rmgen for mature RTS world production.

If a stronger counterexample is needed for any proposed necessary condition, inspect Warzone and/or BAR/Recoil independently.

### D. Candidate methods W-C1..W-C7

Audit each reproduction candidate separately:

W-C1 topology before decoration
W-C2 functional anchors drive local built content
W-C3 constraint layers control overlap
W-C4 surface material follows landform/function
W-C5 coherent vegetation regions plus stragglers
W-C6 camera/environment as acceptance inputs
W-C7 reuse sanctioned real assets without restoring old scene coordinates

For each candidate return one of:

PASS_FOR_REPRODUCTION
DOWNGRADE
FIX
REJECT
UNKNOWN

No candidate is automatically a FRONTLINE product rule.

## Explicit UNKNOWN preservation

Audit whether the following remain correctly UNKNOWN or need correction:

- exact authoritative R28 identity;
- Alpine Valley map-wide road network;
- bridge/ford production chain;
- vegetation LOS/concealment semantics;
- unique tactical intent for every corridor/chokepoint;
- map-specific Alpine Valley camera composition;
- qualitative Stage-4 player result without a fresh runtime capture;
- complete Warzone renderer trace;
- complete BAR/Recoil world-authoring pipeline;
- whether W-C1..W-C7 improve FRONTLINE reproduction before Window 02 tests them.

## Output

Create:

docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md

The final header must contain:

WINDOW_03_WORLD_METHOD_AUDIT=
BLOCKING_DEFECTS=
VERSION_IDENTITY_VERDICT=
WORLD_CAUSAL_MODEL_VERDICT=
REPRODUCTION_CANDIDATES_VERDICT=
WINDOW_02_ROUTING=
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

Allowed WINDOW_02_ROUTING values:

READY_FOR_02_WORLD_REPRODUCTION
RETURN_TO_01_FOR_REPAIR
BLOCKED_UNKNOWN

## Completion rule

Window 03 completes only with a committed audit artifact and commit SHA.

If and only if the audit passes the method sufficiently for reproduction:

01 -> HOLD
03 -> HOLD_AFTER_AUDIT
02 -> ACTIVE_FOR_WORLD_REPRODUCTION

Do not authorize product production. This gate authorizes only the next isolated learning reproduction.
