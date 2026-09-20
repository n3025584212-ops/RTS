# FRONTLINE GPT FOUR-WINDOW SYSTEM V5

ARCHIVED=2026-09-20 — non-authoritative. Retired with the window system; superseded by docs/FRONTLINE_EXECUTION_MODEL_V1.md
STATUS=ACTIVE
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
CORE_LEARNING_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md
SUPERSEDES=docs/archive/governance/GPT_COLLABORATION_SYSTEM_V4.md

## 1. Four windows are retained

The 00/01/02/03 system remains the standard FRONTLINE collaboration structure.

The correction is not to abolish the windows. The correction is to abolish the idea that a window number itself proves expertise, independence, or correctness.

WINDOW_COUNT=4
SHARED_PROJECT_STATE=YES
INDEPENDENT_WINDOW_PROJECT_STATES=NO
WINDOW_NUMBER_AS_EXPERTISE=NO
WINDOW_NUMBER_AS_EVIDENCE=NO

## 2. Window 00 — CONTROL / INTEGRATION

Purpose:
- maintain the one current project state;
- choose the current question and task boundary;
- route work to 01/02/03;
- integrate only evidence-supported results;
- keep GitHub understandable;
- prevent old branches, documents, or internal theories from silently regaining authority.

Window 00 does NOT:
- invent missing design knowledge and declare it final;
- approve its own unverified theory;
- substitute governance documents for a real game artifact.

Sprint 01 responsibility (that route is stopped; see docs/current/ACTIVE_WORK.md):
- maintain Issue #39, evidence status, current branch and transfer gate;
- enforce the 13-layer end-to-end learning mainline;
- decide when evidence is strong enough to move from learning to reproduction and from reproduction to product transfer.

## 3. Window 01 — EVIDENCE / LEARNING

Purpose:
- inspect real shipped products, real open projects, source/data/maps/assets, official production documentation and FRONTLINE's own failed artifacts;
- build the linked evidence graph from data/content through systems, behavior, state, feedback, render and final player-visible result;
- maintain the evidence register;
- distinguish OBSERVED / REPRODUCED / INFERRED / HYPOTHESIS / UNKNOWN / REJECTED;
- actively search for competing explanations rather than only sources that agree.

Window 01 does NOT:
- research map, AI, materials, UI, combat or VFX as disconnected essays;
- become a permanent design oracle;
- invent hidden implementation from screenshots;
- promote one reference project's implementation into a universal RTS rule;
- send broad speculative requirements to Codex.

### Core learning mainline

Window 01 must follow:
1. map loading / battle-space construction;
2. unit data source of truth;
3. model/material/asset binding and scalable reuse;
4. player selection;
5. command routing;
6. pathfinding and movement execution;
7. detection and target selection;
8. fire / hit / damage / death;
9. AI command generation;
10. UI state acquisition;
11. animation / VFX / audio feedback;
12. camera / render presentation;
13. final player-visible result.

Macro chain:
`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

Canonical contract:
`docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md`

Sprint 01 responsibility (that route is stopped; see docs/current/ACTIVE_WORK.md):
- use 0 A.D. Release 28 as the first primary inspectable reference;
- cross-check important conclusions with BAR/Recoil and Warzone 2100 where useful;
- trace at least one real playable path through all thirteen layers;
- compare the reference chain with FRONTLINE's current/historical implementation without assuming either is correct;
- produce `REFERENCE_SELECTION`, `EVIDENCE_REGISTER`, `END_TO_END_CHAIN`, and linked evidence for each edge.

Exit from Window 01 work requires enough concrete evidence to define a reproducible small complete chain and to identify its unknown links explicitly.

## 4. Window 02 — REPRODUCTION / BUILD

Purpose:
- turn evidence from 01 into a real, runnable reproduction;
- use Codex where helpful for concrete implementation;
- run Godot/other required tools;
- produce actual scene/code/assets/runtime screenshots/logs;
- later apply proven methods to FRONTLINE production.

Window 02 does NOT:
- fill missing production knowledge by guessing;
- downgrade visual/product targets to boxes or semantic placeholders;
- scan or refactor the repository broadly unless the current task requires it;
- report PASS because code exists or CI is green.

Sprint 01 responsibility (that route is stopped; see docs/current/ACTIVE_WORK.md):
- after Window 01 supplies a concrete linked chain, implement the isolated learning slice on `learning/sprint01-end-to-end-rts-production`;
- required small complete chain: `PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`;
- environment must be causally authored, not arbitrary object placement;
- asset/content binding must be real enough to test the same chain, not hidden behind boxes;
- capture real runtime evidence;
- report which specific evidence-graph edge failed when the result is poor.

## 5. Window 03 — INDEPENDENT REVIEW / FALSIFICATION

Canonical hard contract:
`docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`

Purpose:
- try to disprove claims made by 01 and 02;
- inspect actual sources and artifacts rather than their summaries;
- audit the exact boundary between evidence, fact, inference, pattern and recommendation;
- identify source/version mistakes, hidden assumptions, unsupported generalization, alternate explanations and mature counterexamples;
- later review the actual reproduction against pre-stated criteria.

Window 03 does NOT:
- become independent merely because it has a different number;
- repeat Window 01's prose and call that review;
- invent new acceptance criteria after seeing the result;
- approve an artifact on CI or prose alone;
- decide subjective player acceptance in place of the user.

### Six mandatory audit checks

1. `PRIMARY_SOURCE_INTEGRITY`
   - no secondary article may be disguised as source-code proof.
2. `VERSION_IDENTITY`
   - every core claim must identify the project/source/release/tag/commit as applicable.
3. `RUNTIME_SEMANTICS`
   - symbol existence is not enough; inspect caller -> callee, state/data flow, conditions, side effects and bypass paths.
4. `GENERALIZATION_BOUNDARY`
   - separate project fact from cross-project pattern and FRONTLINE recommendation.
5. `ALTERNATIVE_EXPLANATIONS`
   - actively test at least one serious competing explanation for important causal claims.
6. `COUNTEREXAMPLE_SEARCH`
   - use BAR/Recoil, Warzone 2100 or another mature implementation to attack claims of necessity/universality.

Sprint 01 responsibility (that route is stopped; see docs/current/ACTIVE_WORK.md):
- audit every major edge of the 13-layer chain rather than only the final summary;
- verify versions and primary-source provenance;
- treat the archived `0ad/0ad` GitHub mirror as historical unless the exact revision is matched to the release being discussed;
- check whether 0 A.D.-specific behavior has been generalized without support;
- use BAR/Recoil and Warzone 2100 as counterexample pools, not merely confirmation samples;
- later review whether Window 02's actual reproduction tests the claimed links and visibly reaches the PLAYER layer.

Allowed audit verdicts:
- PASS
- DOWNGRADE
- FIX
- REJECT
- UNKNOWN

Allowed epistemic/generalization levels:
- SOURCE_FACT
- PROJECT_SPECIFIC_INFERENCE
- CROSS_PROJECT_PATTERN
- DESIGN_RECOMMENDATION
- UNSUPPORTED_GENERALIZATION

## 6. Required chain between windows

The default chain is:

00 DEFINE QUESTION
-> 01 BUILD LINKED EVIDENCE GRAPH
-> 02 REPRODUCE / BUILD REAL ARTIFACT
-> 03 FALSIFY / REVIEW
-> 00 INTEGRATE OR REJECT

This is not a rigid waterfall. Window 03 audits Window 01 in parallel before reproduction; Window 02 may expose missing knowledge and send the chain back to 01; Window 03 may send work back to either. No window may close the loop using only its own claims.

## 7. Shared evidence language

Every important claim must be tagged:
- OBSERVED
- REPRODUCED
- INFERRED
- HYPOTHESIS
- UNKNOWN
- REJECTED

USER_PREFERENCE is authoritative for desired product direction.
USER_HYPOTHESIS is not automatically a technical fact.
MODEL_HYPOTHESIS is not automatically a technical fact.

Every important evidence-graph edge should record:
- source;
- version identity;
- status;
- what the source proves;
- what it does not prove;
- FRONTLINE current implementation if known;
- external reference implementation if inspected;
- gap;
- whether reproduction is required.

Every important 03 audit record should additionally record:
- runtime semantics;
- hidden assumptions;
- alternative explanation;
- counterexample search/result;
- allowed generalization level;
- allowed final wording.

## 8. Task packet

Every substantial dispatch must state:

WINDOW=
TASK_TYPE=
GOAL=
CURRENT_REAL_ARTIFACT=
SOURCE_OR_REFERENCE=
CHAIN_LAYER_OR_EDGE=
KNOWN_FACTS=
HYPOTHESES=
UNKNOWNS=
ALLOWED_ACTIONS=
FORBIDDEN_SUBSTITUTIONS=
REQUIRED_EVIDENCE=
EXIT_CONDITION=

## 9. Current allocation

Window allocation is stated in exactly one place: `docs/current/CURRENT_STATE.md` (see the
`WINDOW_0x_STATUS` keys). It is deliberately not repeated here — this section used to carry a
snapshot of the Learning Sprint 01 allocation and drifted out of date.

One project, one active issue, one shared truth. No four independent roadmaps.

## 10. After Sprint 01

If the end-to-end reproduction passes:
- 00 selects a small FRONTLINE product slice;
- 01 uses the same 13-layer graph to identify unresolved production choices;
- 02 builds the real product slice;
- 03 independently reviews the real artifact and broken/missing links under the same strict evidence contract;
- user performs subjective product/visual/play judgment where required.

FOUR_WINDOWS_RETAINED=YES
FIXED_EXPERT_MYTH=NO
EVIDENCE_BEFORE_AUTHORITY=YES
LEARN_CONNECTIONS_NOT_ISOLATED_MODULES=YES
WINDOW_03_FALSIFICATION_CONTRACT=MANDATORY
