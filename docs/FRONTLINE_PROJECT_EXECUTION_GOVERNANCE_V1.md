# FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1

STATUS=FROZEN_PROJECT_LEVEL_RULE
OWNER=WINDOW_00_CONTROL
APPLIES_TO=ALL_REGISTERED_FRONTLINE_WINDOWS_AND_EXTERNAL_CODE_EXECUTORS
SOURCE_OF_TRUTH=GITHUB_MAIN
ENGINE_BASELINE=GODOT_4_7_1
FREEZE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
SYSTEM_WIDE_SYNC=YES
DEFAULT_PROJECT_EXECUTION_AND_ACCEPTANCE_PROTOCOL=YES

## 1. Purpose

This protocol governs how FRONTLINE design decisions become implementation work, how implementation freedom is used, how acceptance is judged, and what evidence is required before a result becomes project truth.

The project shall optimize for product quality, implementation coherence, and credible verification rather than mechanical compliance or excessive paperwork.

## 2. Authority hierarchy

When instructions conflict, use this order unless Window 00 explicitly overrides it:

1. PRODUCT_INTENT
2. CURRENT_FROZEN_DESIGN
3. SYSTEM_COHERENCE_AND_PLAYER_EXPERIENCE
4. IMPLEMENTATION_CONTRACT
5. IMPLEMENTATION_CONVENIENCE

A frozen rule is authoritative where it explicitly decides a product or gameplay question. It must not be extended into unrelated prohibitions that prevent necessary implementation logic.

## 3. Five-layer implementation contract

Every formal construction task shall be understood through five layers.

### 3.1 DESIGN_INTENT

Defines what the player should experience and what the system is supposed to accomplish.

Examples include tactical pressure, readability, decision quality, battlefield command feel, route choice, information uncertainty, interaction clarity, or visual hierarchy.

### 3.2 FROZEN_CONTRACT

Defines what is already decided and must not be silently changed, such as:

- frozen gameplay constants;
- unit roles and allowed scope;
- accepted map/navigation topology;
- objective/victory rules;
- approved product direction;
- approved visual target direction;
- explicitly frozen Battle01 boundaries.

### 3.3 IMPLEMENTATION_FREEDOM

Within the authorized feature and frozen scope, the responsible implementation owner and Codex may complete missing local logic without requesting approval for every engineering detail.

Normally allowed:

- node and signal organization;
- state transitions required by the authorized feature;
- initialization order;
- helper functions;
- local thresholds or timings not frozen elsewhere;
- safe Typed GDScript implementation choices;
- target reconsideration or prioritization details inside an already-authorized AI feature;
- diagnostics, assertions, and focused test hooks;
- interaction glue required to make the frozen design function coherently.

This freedom is for completing the intended system, not for expanding the product.

Explicit authorization is still required for major additions such as:

- new unit classes;
- new major gameplay loops;
- new economy/resource families;
- new armor/penetration or morale systems;
- new map regions;
- new strategic layers;
- other scope-expanding systems not already implied by the authorized design.

## 4. Executor role

Codex and other coding agents are construction executors, not final project authorities.

They are expected to:

- understand the design intent, not only copy literal wording;
- implement missing local logic when necessary;
- preserve frozen rules;
- avoid unnecessary refactors and scope growth;
- run the required checks when the environment supports them;
- return evidence that allows independent review.

They may report:

EXECUTOR_RESULT=PASS

This is an implementation report, not the final project acceptance decision.

## 5. Acceptance authority

The responsible integration/QA gate determines whether a construction result becomes accepted project truth.

Formal acceptance is represented by:

QA_GATE_RESULT=PASS

A downstream dependency may rely on the result only after the responsible gate has enough evidence to independently support that conclusion.

The gate shall evaluate both:

- CONSTRUCTION_CORRECTNESS
- PRODUCT_CORRECTNESS when relevant

A mechanical test PASS does not automatically prove that the implemented behavior matches the intended RTS experience.

## 6. Evidence principle

The project uses MINIMUM_SUFFICIENT_EVIDENCE.

"Minimum" does not mean the smallest possible file count. It means no more evidence than is needed after the important claims are convincingly established.

Evidence volume is determined by:

- importance of the claim;
- risk of the change;
- blast radius;
- ambiguity of the result;
- likely failure modes;
- difficulty of reproducing the behavior.

The reviewer shall stop requesting more evidence once the important conclusions can be independently justified and the likely relevant failure modes are reasonably excluded.

## 7. Five claims a meaningful implementation audit should establish

For a normal code/system task, evidence should be sufficient to establish the claims that materially apply.

### 7.1 VERSION_IDENTITY

What revision/build was actually tested?

Typical evidence:

- FINAL_COMMIT;
- START_COMMIT when useful;
- repository state sufficient to prevent test-version/delivery-version ambiguity.

### 7.2 CHANGE_SCOPE

What materially changed?

Typical evidence:

- changed-file list;
- focused diff or diff summary;
- enough detail to identify unintended frozen-rule changes, scope growth, or unrelated refactoring.

A full repository archive is not required by default.

### 7.3 REAL_EXECUTION

What actually ran?

Typical evidence:

- engine/runtime version;
- executed command or scenario identity;
- exit code or an equally unambiguous completion result;
- raw runtime output for the important checks.

Runtime requirements cannot be accepted solely from static inspection.

### 7.4 CORE_BEHAVIOR

Did the feature actually do the important thing it was built to do?

Use the most persuasive evidence appropriate to the feature:

- runtime assertions;
- state/count/value output;
- focused smoke tests;
- scenario traces;
- screenshots;
- short targeted captures;
- telemetry;
- interactive QA observations.

A single aggregate PASS statement is insufficient when the underlying important behavior cannot be reconstructed from it.

### 7.5 RELEVANT_REGRESSION

Did the change break systems plausibly affected by it?

Regression scope is proportional to the blast radius.

Do not require unrelated full-project regression after an isolated low-risk change.

## 8. Risk-scaled evidence

### LOW_RISK

Examples:
- text correction;
- minor HUD alignment;
- isolated reference repair with no behavioral impact.

Typical evidence:
- focused diff;
- one relevant runtime check or screenshot.

### MEDIUM_RISK

Examples:
- unit spawning;
- objective logic;
- supply behavior;
- one AI behavior;
- scene initialization changes.

Typical evidence:
- focused change evidence;
- direct runtime behavior evidence;
- related subsystem regression.

### HIGH_RISK

Examples:
- enemy AI architecture;
- navigation;
- combat core;
- save/restart lifecycle;
- broad command/control changes;
- large scene-structure changes.

Typical evidence:
- design-to-behavior trace for important claims;
- multiple runtime scenarios;
- blast-radius regressions;
- product-behavior evidence where mechanical checks alone are insufficient.

## 9. Construction correctness and product correctness

### CONSTRUCTION_CORRECTNESS

Examples:
- project parses;
- scene loads;
- scripts have no blocking runtime/parse error;
- expected states/counts/values are present;
- tests complete successfully;
- relevant regressions remain valid.

### PRODUCT_CORRECTNESS

Examples:
- AI creates the intended tactical pressure rather than merely changing state;
- command interactions are understandable and not unnecessarily burdensome;
- HUD exposes useful battlefield information;
- navigation supports meaningful route choice;
- combat behavior remains readable and consistent with unit roles;
- the implemented result feels like the intended Formation/Platoon-level RTS rather than a technically passing but mismatched prototype.

When product correctness matters, use targeted runtime observation instead of replacing behavioral judgment with more log volume.

## 10. Visual target implementation

Approved target images are product/visual references, not pixel-lock constraints.

Implementation should preserve:

- information hierarchy;
- modern-war atmosphere;
- battlefield density;
- unit/formation readability;
- command feedback;
- intended visual language.

Runtime usability may justify adapting layout or interaction details when the adaptation better serves the frozen product intent.

Visual acceptance should compare:

- target reference;
- actual Godot runtime result;
- material deviation if any;
- effect of that deviation on readability and intended experience.

Use only the screenshots/captures necessary to judge the relevant states. Do not require large visual archives by default.

## 11. Anti-over-audit rule

The following are not mandatory by default:

- complete project ZIP;
- full repository mirror;
- hash manifest for every project file;
- all historical commits;
- unrelated runtime logs;
- long recordings where a short capture proves the point;
- duplicated logs containing the same evidence;
- complete game regression for every isolated change.

Additional evidence is justified only when risk, ambiguity, reproducibility, or a discovered failure requires it.

## 12. Default executor handoff

A normal formal implementation handoff should provide or make retrievable, as applicable:

TASK_ID=
EXECUTOR_RESULT=
ENGINE=
START_COMMIT=
FINAL_COMMIT=
FILES_CHANGED=
TESTS_OR_SCENARIOS_EXECUTED=
CORE_RUNTIME_EVIDENCE=
RELEVANT_REGRESSION_EVIDENCE=
RUNTIME_ERRORS=
KNOWN_LIMITATIONS=
BLOCKER=

The executor should include focused raw evidence sufficient for the important claims. It should not produce bulk archives unless the task risk actually requires them.

## 13. Window behavior

All registered FRONTLINE windows shall apply this protocol within their domain.

- Design windows define intent and frozen decisions without over-specifying engineering details unnecessarily.
- Implementation windows preserve design authority while filling necessary local logic.
- Visual windows treat approved target assets as direction and acceptance references while preserving practical usability.
- Integration/QA verifies the delivered behavior independently and scales evidence to risk.
- Window 00 resolves cross-window conflicts and is the authority for project-level freezes and scope changes.

No window should turn implementation safeguards into a substitute for design judgment.

## 14. Completion rule

A task is complete when:

- the intended result exists;
- frozen decisions remain respected;
- necessary local logic is coherent;
- the important acceptance claims are independently supported;
- relevant regressions are acceptable;
- evidence is sufficient for the task risk;
- no unresolved blocker remains.

The goal is a credible, playable, internally coherent FRONTLINE product—not maximum procedural compliance.
