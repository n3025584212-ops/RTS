# FRONTLINE PROJECT SYSTEM V3

STATUS=ACTIVE_PROJECT_SYSTEM
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
EXECUTION_MODEL=docs/FRONTLINE_EXECUTION_MODEL_V1.md
SUPERSEDES=docs/archive/governance/FRONTLINE_PROJECT_SYSTEM_V2.md

## 1. Core correction

FRONTLINE must not move from general theory directly to design, and from design directly to implementation.

New production order:

REAL_PRODUCT_OR_REAL_PROBLEM
-> EVIDENCE
-> CAUSAL_DECOMPOSITION
-> REPRODUCTION
-> MANUFACTURABILITY
-> DESIGN_OR_ADAPTATION
-> REAL_BUILD
-> REAL_RUNTIME
-> COMPARISON
-> USER_ACCEPTANCE

The project may skip a stage only when strong existing evidence already covers it.

## 2. What counts as progress

Progress is a real change in one of:
- production knowledge that was reproduced/verified;
- actual game artifact;
- actual runtime quality/behavior;
- actual player/user judgment.

The following are supporting work, not product progress by themselves:
- theory documents;
- workflow design;
- CI green;
- task counts;
- agent agreement;
- generated concept art;
- element-presence checklists.

## 3. Research gate

Before a major new production method is adopted, record:
- the exact production question;
- the strongest reference/source;
- what is observed versus inferred;
- a reproduction or direct technical verification where practical;
- transfer limits.

Generic advice such as "use PBR", "increase detail", "improve game feel", or "add atmosphere" is not sufficient production knowledge.

## 4. Design gate

Design must distinguish:

SUPPORTED
- there is a known/reproduced production route.

ASPIRATIONAL
- desired result exists, but the production route is not yet proven.

UNKNOWN
- neither appearance nor implementation is sufficiently understood.

A generated image can propose ASPIRATIONAL content. It cannot by itself prove manufacturability.

The Approved Golden Frame remains the current visual target. The project must now close its unsupported production gaps through evidence and reproduction rather than lowering the target or substituting proxies.

## 5. Build gate

Build tasks must start from the current real artifact.

Do not restart from an abstract plan when a scene/code/asset already exists.

Each build iteration must identify the highest-impact gap, apply a supported method, run the real game, and inspect the new result.

BUILD_LOOP:
CURRENT_ARTIFACT
-> BIGGEST_OBSERVED_GAP
-> EVIDENCE_BACKED_METHOD
-> MODIFY_REAL_ARTIFACT
-> RUN
-> CAPTURE/MEASURE
-> COMPARE
-> NEXT_GAP

## 6. Visual production rule

For visual work, "contains the right objects" is insufficient.

A visual review judges relationships and quality:
- spatial logic;
- scale;
- composition;
- material response;
- lighting;
- atmosphere;
- asset fidelity;
- motion/VFX behavior;
- damage/history detail;
- UI-to-world balance;
- similarity to the accepted target.

Presence metrics may support debugging but may not establish visual acceptance.

## 7. Spatial production rule

World construction must be driven by generating logic, not decorative placement.

For settlements/terrain/roads/units, document and reproduce relevant constraints such as:
- terrain and drainage;
- road hierarchy and access;
- parcel/building orientation;
- land use and vegetation;
- cover and sight lines;
- tactical purpose;
- movement corridors;
- camera readability.

Copying positions from a reference without understanding these rules is not accepted learning.

## 8. Proxy rule

Proxies may exist only inside isolated technical experiments.

A proxy cannot migrate into a production proof as a silent substitute.

If an approved element has no adequate production implementation, its state is INCOMPLETE or BLOCKED, not COMPLETE.

## 9. User and model roles

The user is authoritative about:
- desired product direction;
- subjective visual acceptance;
- play acceptance;
- explicit priorities.

The user is not required to provide the technical diagnosis for failures.

The assistant/agents are responsible for:
- finding evidence;
- separating fact from hypothesis;
- reproducing methods;
- implementing;
- reporting uncertainty;
- disagreeing when evidence contradicts a technical hypothesis.

## 10. Current application

Current real artifact:
- Godot Golden Scene V1 / existing development branch and evidence.

Current accepted target:
- FRONTLINE_GOLDEN_FRAME_V1.

Current verdict:
- visual target not met.

The next production cycle must not start with another broad theory or another generated visual target. It must identify one or more proven production references for the largest rejected visual gaps, reproduce the relevant methods, and then apply them to the existing Golden Scene.
