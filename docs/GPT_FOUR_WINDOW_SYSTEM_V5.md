# FRONTLINE GPT FOUR-WINDOW SYSTEM V5

STATUS=ACTIVE
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
SUPERSEDES=docs/GPT_COLLABORATION_SYSTEM_V4.md

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

Current Sprint 01 responsibility:
- maintain Issue #39, evidence status, current branch and transfer gate;
- decide when evidence is strong enough to move from learning to reproduction and from reproduction to product transfer.

## 3. Window 01 — EVIDENCE / LEARNING

Purpose:
- inspect real shipped products, real open projects, source/data/maps/assets, official production documentation and FRONTLINE's own failed artifacts;
- trace real production chains end-to-end;
- maintain the evidence register;
- distinguish OBSERVED / INFERRED / HYPOTHESIS / UNKNOWN;
- actively search for competing explanations rather than only sources that agree.

Window 01 does NOT:
- become a permanent design oracle;
- write a theory essay and call it learned;
- invent hidden implementation from screenshots;
- send broad speculative requirements to Codex.

Current Sprint 01 responsibility:
- primary inspection of 0 A.D. Release 28;
- cross-check with BAR/Recoil and Warzone 2100 where useful;
- produce `REFERENCE_SELECTION`, `EVIDENCE_REGISTER`, `END_TO_END_CHAIN`, and world causal decomposition.

Exit from Window 01 work requires enough concrete evidence to define a reproducible mechanism or small end-to-end chain.

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

Current Sprint 01 responsibility:
- after Window 01 supplies a concrete chain, implement the isolated learning slice on `learning/sprint01-end-to-end-rts-production`;
- required small complete chain:
  PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME;
- environment must be causally authored, not arbitrary object placement;
- capture real runtime evidence.

## 5. Window 03 — INDEPENDENT REVIEW / FALSIFICATION

Purpose:
- try to disprove claims made by 01 and 02;
- inspect actual sources and artifacts rather than their summaries;
- check whether evidence actually supports the claimed conclusion;
- compare reproduction against pre-stated criteria;
- identify hidden substitutions, unsupported inference, missing evidence and regressions.

Window 03 does NOT:
- become independent merely because it has a different number;
- invent new acceptance criteria after seeing the result;
- approve an artifact on CI or prose alone;
- decide subjective player acceptance in place of the user.

Current Sprint 01 responsibility:
- audit the evidence register and reference selection;
- verify that the selected reproduction really tests the claimed production knowledge;
- review the actual runtime reproduction;
- return PASS / FIX / REJECT with concrete evidence.

## 6. Required chain between windows

The default chain is:

00 DEFINE QUESTION
-> 01 GATHER / TRACE EVIDENCE
-> 02 REPRODUCE / BUILD REAL ARTIFACT
-> 03 FALSIFY / REVIEW
-> 00 INTEGRATE OR REJECT

This is not a rigid waterfall. 01 and 02 may iterate when reproduction exposes missing knowledge; 03 may send work back to either. But no window may close the loop using only its own claims.

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

## 8. Task packet

Every substantial dispatch must state:

WINDOW=
TASK_TYPE=
GOAL=
CURRENT_REAL_ARTIFACT=
SOURCE_OR_REFERENCE=
KNOWN_FACTS=
HYPOTHESES=
UNKNOWNS=
ALLOWED_ACTIONS=
FORBIDDEN_SUBSTITUTIONS=
REQUIRED_EVIDENCE=
EXIT_CONDITION=

## 9. Current allocation — Learning Sprint 01

WINDOW_00=ACTIVE_CONTROL_AND_INTEGRATION
WINDOW_01=ACTIVE_EVIDENCE_LEARNING
WINDOW_02=WAITING_FOR_REPRODUCIBLE_CHAIN_THEN_ACTIVE_REPRODUCTION
WINDOW_03=ACTIVE_EVIDENCE_AUDIT_THEN_REPRODUCTION_REVIEW

One project, one Issue #39, one shared truth. No four independent roadmaps.

## 10. After Sprint 01

If the end-to-end reproduction passes:
- 00 selects a small FRONTLINE product slice;
- 01 supplies evidence for unresolved production choices;
- 02 builds the real product slice;
- 03 independently reviews the real artifact;
- user performs subjective product/visual/play judgment where required.

FOUR_WINDOWS_RETAINED=YES
FIXED_EXPERT_MYTH=NO
EVIDENCE_BEFORE_AUTHORITY=YES
