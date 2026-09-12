# FRONTLINE LEARNING SYSTEM V1

STATUS=ACTIVE
PROJECT=FRONTLINE
PURPOSE=REPLACE_OPINION_SUMMARY_LEARNING_WITH_EVIDENCE_REPRODUCTION

## 1. Why this exists

FRONTLINE previously allowed a dangerous chain:

REFERENCE_OR_IDEA
-> MODEL_SUMMARY
-> ABSTRACT_DESIGN
-> GENERATED_TARGET
-> IMPLEMENTATION_BY_SEMANTIC_SUBSTITUTION
-> SELF_REVIEW

This produced internally coherent plans that could still fail visibly in the real game.

The new learning system does not treat fluent explanation, common advice, a generated image, CI, or an agent's self-rating as proof that something is understood.

## 2. Core rule

LEARNING_COMPLETE only when a useful claim is connected to:

SOURCE_EVIDENCE
-> CAUSAL_DECOMPOSITION
-> REPRODUCTION_OR_DIRECT_INSPECTION
-> REAL_ARTIFACT
-> COMPARISON
-> TRANSFER_DECISION

If this chain is absent, the item remains HYPOTHESIS or REFERENCE, not learned production knowledge.

## 3. Evidence classes

### E0 — Direct project reality
Highest authority for the current project.
- actual FRONTLINE runtime;
- actual screenshot/video;
- actual scene/code/asset;
- actual profiler/test result;
- actual user visual/play judgment.

### E1 — Reproducible external production evidence
Strongest external learning source.
- runnable open-source game/project;
- source code + assets + build path;
- official engine sample that can be run;
- production files that expose how the result is created.

### E2 — Primary creator evidence
Useful for intent and production explanation.
- official documentation;
- developer postmortem;
- GDC/developer talk;
- technical art breakdown by the team that shipped the product;
- source/license documentation.

### E3 — Secondary technical material
Useful for leads, never sufficient by itself to freeze a production decision.
- tutorials;
- forum answers;
- community reverse engineering;
- articles by third parties.

### E4 — Opinion / pattern / model inference
Lowest authority.
- general design theory;
- social-media claims;
- unverified best practices;
- model-generated explanations;
- user or assistant hypotheses before verification.

E4 MAY START AN INVESTIGATION.
E4 MAY NOT END ONE.

## 4. Claims must carry status

Every important claim must be one of:

OBSERVED — directly seen in a source or runtime.
REPRODUCED — recreated and verified.
INFERRED — reasoned from evidence but not directly proven.
HYPOTHESIS — plausible explanation awaiting evidence.
UNKNOWN — insufficient evidence.
REJECTED — contradicted by evidence.

Do not write INFERRED/HYPOTHESIS as if it were OBSERVED/REPRODUCED.

## 5. How to study a successful game

Do not begin with "what design principles can we summarize?"

For each selected reference game or open project:

1. RUN_OR_VIEW_REAL_PRODUCT
   - actual gameplay footage / build / source project;
   - record the exact scene or behavior being studied.

2. PICK_ONE_PRODUCTION_QUESTION
   Examples:
   - why does this town layout read naturally?
   - how does unit readability survive the command-camera distance?
   - what creates the ground material richness?
   - how are smoke and explosions layered?
   - how are orders represented without covering the battlefield?

3. COLLECT_PRIMARY_EVIDENCE
   - source code/project when available;
   - official docs;
   - creator breakdowns;
   - asset/material/shader structure;
   - runtime observation.

4. DECOMPOSE CAUSALLY
   Do not list objects only. Explain relationships and constraints.

   Bad:
   - road
   - houses
   - trees
   - tank

   Better:
   - road defines settlement axis;
   - parcels orient buildings to road;
   - vegetation follows unused edges and terrain;
   - open fields create sight lines;
   - bridge creates traffic choke;
   - unit positions follow cover, access and mission state.

5. REPRODUCE A SMALL RELEVANT SLICE
   Reproduce the mechanism, not a decorative screenshot.

6. COMPARE
   Put source behavior/visual and reproduction together.
   Record what still differs.

7. TRANSFER
   Only after reproduction decide whether the method transfers to FRONTLINE.

## 6. Production knowledge unit

A reusable learned item must contain:

CLAIM=
STATUS=
QUESTION=
SOURCE_PRODUCT=
SOURCE_EVIDENCE=
EVIDENCE_CLASS=
WHAT_WAS_OBSERVED=
CAUSAL_EXPLANATION=
REPRODUCTION=
ARTIFACT_PATH=
RESULT=
DIFFERENCES=
TRANSFER_TO_FRONTLINE=
LIMITS=

Without these fields, the item is notes, not production knowledge.

## 7. Design rule

A visual/design target must separate:

SUPPORTED_DESIGN
- backed by known production routes/assets/tools/reproduced methods.

ASPIRATIONAL_DESIGN
- visually desired but production route not yet established.

Generated imagery may be used to explore appearance, but it cannot silently convert ASPIRATIONAL elements into implementation promises.

Before a design becomes an implementation contract, each major visible system must have a MANUFACTURABILITY MAP:
- real asset source or creation method;
- material/shader route;
- scene/layout method;
- animation/VFX route;
- runtime cost concern;
- engine support;
- known unknowns.

## 8. Spatial design rule

Do not learn placement by copying coordinates from screenshots.

For environment/unit layout, capture the generating rules:
- terrain constraints;
- road hierarchy;
- parcel/building orientation;
- vegetation ecology/land use;
- cover and sight lines;
- traffic/access;
- tactical purpose;
- camera readability.

A copied arrangement without its generating rules is not learned spatial design.

## 9. Implementation rule

Semantic presence is not visual/behavioral reproduction.

"bridge exists" != bridge quality reproduced.
"tank exists" != vehicle presentation reproduced.
"smoke exists" != production VFX reproduced.
"AI reacts" != reference behavior reproduced.

Every implementation claim must include the real artifact used for judgment.

## 10. Review rule

No agent may establish PASS by checking only criteria it invented for itself.

Review is evidence-based, not window-based.

Required review inputs as applicable:
- actual runtime;
- actual screenshot/video;
- source/reference side-by-side;
- code/scene/assets;
- performance evidence;
- user judgment for subjective visual/product acceptance.

CI is technical evidence only.

## 11. Anti-agreement rule

User statements and model statements are both hypotheses until supported when they concern uncertain causes or solutions.

The assistant must actively consider at least one competing explanation for an important diagnosis.

Do not convert the user's latest suggestion into the project's explanation merely because it is conversationally convenient.

## 12. Unknown is valid

UNKNOWN is a successful research outcome when evidence is insufficient.

Do not fill missing production knowledge with plausible prose.

If the real asset, source, runtime or production method is not known, say UNKNOWN and create the next evidence task.

## 13. Current FRONTLINE application

The current Golden Scene must not be improved by generic "more PBR / more VFX" advice alone.

For every major rejected area, select at least one strong production reference and perform targeted evidence work:
- terrain/material construction;
- river/shore/bridge construction;
- settlement/road spatial logic;
- realistic vehicle/infantry presentation;
- lighting/atmospheric depth;
- combat VFX layering;
- damage/decal/world-history treatment.

The next useful deliverable is not another theory document. It is a set of reproduced production methods and a visibly improved real runtime built from them.
