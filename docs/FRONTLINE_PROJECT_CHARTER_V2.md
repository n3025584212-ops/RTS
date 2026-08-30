# FRONTLINE_PROJECT_CHARTER_V2

STATUS=FROZEN_PROJECT_CHARTER
PROJECT=FRONTLINE
FINAL_PRODUCT_AUTHORITY=USER_PRODUCT_OWNER
PROJECT_INTEGRATION_AUTHORITY=WINDOW_00_GAME_DIRECTOR_PRODUCER
APPLIES_TO=ALL_FRONTLINE_DESIGN_TECH_ART_QA_EXECUTION_WORK
SOURCE_OF_TRUTH=GITHUB_MAIN
ENGINE_BASELINE=GODOT_4_7_1
FREEZE_ID=FRONTLINE_PROJECT_CHARTER_V2

SUPERSEDES_OPERATIONAL_AUTHORITY=
- docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md

LEGACY_GOVERNANCE_DISPOSITION=HISTORICAL_REFERENCE_ONLY

---

## 0. Purpose

This Charter is the highest stable project-level operating rule for FRONTLINE.

It governs how product intent becomes playable work, how authority is assigned, how design and visual decisions are accepted, how implementation is constrained, how QA is interpreted, and how Git/CI support production.

The project exists to build a coherent player experience, not to maximize document volume, test count, system count, commit count, or procedural compliance.

---

## 1. Product mandate

FRONTLINE is a modern-warfare, formation/platoon-level real-time tactical game.

PLAYER_ROLE=FRONTLINE_BATTLE_GROUP_COMMANDER

The player does not primarily play as an individual soldier, base builder, economy manager, or high-APM unit scheduler.

The central player experience is battlefield judgment under incomplete information.

CORE_DECISION_LOOP=
OBSERVE
-> INTERPRET
-> COMMIT
-> WORLD_AND_ENEMY_RESPONSE
-> REASSESS
-> PRESERVE_OR_PRESS
-> COMMIT_AGAIN

Every major system, feature, asset, AI behavior, UI element, test, and production task must be able to explain how it supports this loop.

---

## 2. Product pillars

### 2.1 INFORMATION_BEFORE_COMMITMENT

The player must not have perfect battlefield information by default.
Reconnaissance and information quality must materially change decisions.
Information gathering may expose the player's own intent and therefore may carry cost or risk.

### 2.2 TERRAIN_CREATES_TACTICAL_PROBLEMS

Terrain must change how formations can be used, observed, protected, committed, withdrawn, or supported.
Routes must not exist only as cosmetic alternatives or different path lengths.

### 2.3 ENEMY_REACTS_NOT_CHEATS

Enemy behavior must be based on legitimate information available to the enemy side plus its own state and mission knowledge.
Enemy reaction must consume finite formations, time, position, and opportunity.
Strengthening one sector must be capable of weakening another.
The enemy must not use hidden player truth merely to appear intelligent.

### 2.4 PRESERVE_COMBAT_POWER

Damage, ammunition, position, exposure, withdrawal, and force commitment must create continuing decisions.
Reasonable mistakes should usually create cost and a chance to adapt, not immediate scripted failure.

---

## 3. Product boundaries

The following are not automatic requirements for FRONTLINE or Battle01:

- base building;
- mining or traditional RTS economy;
- individual-soldier micromanagement;
- high-APM difficulty as a primary source of depth;
- feature growth solely because a system is technically possible;
- new unit families without player-facing need;
- strategic layers before the current playable proves they are required;
- complex simulation systems whose decision value has not been demonstrated.

A feature enters the production mainline only when its player-facing decision value is explicit and relevant to the current milestone.

---

## 4. Authority hierarchy

When instructions, documents, tests, or implementations conflict, use this precedence:

1. USER_EXPLICIT_DECISION
2. CURRENT_ACCEPTED_PRODUCT_STATE
3. CURRENT_MILESTONE_AND_PLAYABLE_DESIGN
4. SPECIALIST_IMPLEMENTATION_OR_ART_NOTES
5. TESTS_AND_HISTORICAL_DOCUMENTS

No test, historical contract, prior implementation, automation result, or specialist receipt may silently redefine product intent.

FINAL_MAJOR_DIRECTION_AUTHORITY=USER_PRODUCT_OWNER

WINDOW_00 integrates evidence, specialist findings, user decisions, and playable results into the current accepted product state.

Specialist roles own their work result. They do not independently own whole-project truth.

---

## 5. Single current product state

FRONTLINE must maintain one shared current state rather than independent competing CURRENT states per specialist window.

The minimum shared state is:

CURRENT_MILESTONE
CURRENT_PLAYABLE
CURRENT_GAME_DESIGN
CURRENT_ART_DIRECTION
CURRENT_IMPLEMENTATION
KNOWN_PRODUCT_BLOCKERS
KNOWN_TECHNICAL_BLOCKERS
CURRENT_BUILD
NEXT_DECISION

All specialist work reads from the same accepted current state.

A specialist result becomes project truth only after integration into the accepted current state by WINDOW_00 or by an explicit user decision.

No window-to-window receipt may mutate project truth by itself.

---

## 6. Specialist and executor roles

### 6.1 Design

Design proposes and refines player problems, decisions, rules, scenarios, and experience structures.
Design may not self-declare a whole-game or milestone PASS.

### 6.2 Engineering

Engineering implements authorized playable requirements and reports construction facts, limitations, and risks.
Engineering may not expand product scope merely to close technical gaps.

### 6.3 Visual / Art

Visual work produces references, candidates, approved traits, production assets, and runtime presentation.
A visual creator may not self-declare its own output canonical without the required review/acceptance state.

### 6.4 QA

QA reports observed technical behavior, regressions, product risks, and evidence.
QA does not possess authority to convert technical PASS into product PASS.

### 6.5 Codex and other coding agents

CODEX_ROLE=CONSTRUCTION_EXECUTOR

Codex is not the Game Director, Producer, Product Owner, roadmap authority, product designer, or final QA authority.

Codex may:
- implement a clearly authorized requirement;
- make local engineering decisions necessary to complete that requirement;
- report risks and blockers;
- run relevant technical verification.

Codex may not:
- decide what feature should be built next;
- discover gaps and automatically expand the roadmap;
- add systems because existing tests or code imply them;
- declare a milestone or product experience accepted.

Prohibited task form:
"Inspect the project for missing pieces and complete them."

Required task form:
- current milestone;
- player-facing problem;
- authorized change;
- explicit non-goals;
- completion evidence.

---

## 7. Playable-first production rule

PLAYABLE_FIRST=YES

Every production task must answer:

PLAYER_FACING_CHANGE=
WHAT_NEW_OR_CHANGED_JUDGMENT_DOES_THIS_CREATE=
CURRENT_PLAYABLE_IMPACT=

If these cannot be answered for a product feature, the feature does not automatically enter the mainline.

Technical maintenance tasks may exist without creating new gameplay, but must state the concrete stability, portability, performance, tooling, or recoverability risk they address.

Systems are means. The connected player decision chain is the product.

---

## 8. Milestone model

FRONTLINE uses the following project milestones:

### M0 PROJECT RECOVERY
Recover trustworthy project truth, provenance, runtime health, visual/design lineage, and reusable foundations.

### M1 GAME DEFINITION
Define the game promise, product pillars, Battle01 player experience, and the connected playable contract.

### M2 CONNECTED PLAYABLE
Produce a coherent approximately 10-15 minute Battle01 in which information, movement, contact, commitment, enemy response, reassessment, preservation, and end state are causally connected.
Greybox presentation is acceptable.

### M3 REPRESENTATIVE VISUAL SLICE
Bring one representative Battle01 area/sequence to a visual quality that credibly represents the intended final game direction in normal play.

### M4 PLAYER BUILD
Deliver a real Windows player build for direct human playtesting.
Human play evidence outranks automated claims about product quality.

### M5 BATTLE01 VERTICAL SLICE
Integrate representative gameplay, art, UI, audio, AI, performance, stability, and player-facing quality into a slice credible as a production benchmark.

Milestones must not be replaced by a large hierarchy of feature-specific pseudo-milestones or formal gates.

---

## 9. Design acceptance and freezing

A design is not accepted merely because:
- a document exists;
- an implementation exists;
- a test passes;
- a specialist marked it FROZEN;
- historical work depended on it.

A design may be promoted into the current accepted state when it has sufficient product rationale, relevant evidence, and WINDOW_00 integration or explicit user acceptance.

Freeze means downstream work may rely on the decision within the stated scope.
Freeze does not mean the decision can never be changed.

A frozen decision may be reopened when:
- direct player evidence contradicts it;
- product pillars are violated;
- implementation exposes a material hidden assumption;
- the user explicitly changes direction.

Reopening must be explicit. Silent drift is prohibited.

---

## 10. Visual governance

Visual artifacts follow this lineage:

SOURCE_OR_HISTORY
-> REVIEW_STATUS
-> APPROVED_VISUAL_TRAITS
-> ACTIVE_ART_DIRECTION
-> ASSET_REQUIREMENT
-> ASSET_CANDIDATE
-> ASSET_REVIEW
-> RUNTIME

Every visual artifact used for production decisions should distinguish:

DESIGN_STATUS
USER_ACCEPTANCE
APPROVED_ELEMENTS
REJECTED_ELEMENTS
IMPLEMENTATION_STATUS
CURRENT_AUTHORITY

Allowed review states include:
APPROVED
APPROVED_PARTIAL
REWORK_REQUIRED
REJECTED
EXPLORATION
SUPERSEDED
UNKNOWN

Rules:
- FILE_EXISTS does not mean APPROVED.
- INTERNAL_FORMAL_TARGET does not mean USER_APPROVED.
- RUNTIME_MATCH does not mean PRODUCT_ACCEPTED.
- A reference image normally guides visual traits, not literal screenshot duplication.
- Obsolete mechanics visible in an otherwise useful image do not regain design authority.

Major visual direction acceptance remains subject to user review.

---

## 11. QA and validation

FRONTLINE separates technical verification from product validation.

### 11.1 TECHNICAL_VERIFICATION

Answers questions such as:
- does the project parse;
- does it boot;
- does input work;
- does a state transition execute;
- is navigation valid;
- did a regression occur;
- did the build crash.

### 11.2 PRODUCT_VALIDATION

Answers questions such as:
- is reconnaissance meaningfully useful;
- are route choices real;
- does enemy reaction create new decisions;
- can reasonable mistakes be recovered from;
- does the battle create an understandable causal story;
- is the visual presentation representative and readable in normal play.

TECHNICAL_PASS != PRODUCT_PASS

Automated tests protect implementation behavior. They do not define product intent and do not prove fun, clarity, pacing, or visual acceptance.

Human playtesting becomes increasingly authoritative from M2 onward and is mandatory before M5 acceptance.

---

## 12. Evidence principle

FRONTLINE uses MINIMUM_SUFFICIENT_EVIDENCE.

Evidence should be proportional to risk, blast radius, ambiguity, and product importance.

Relevant evidence may include:
- tested revision identity;
- focused diff/scope;
- real engine execution;
- runtime traces;
- focused smoke tests;
- screenshots or captures;
- human play observations;
- visual comparisons;
- performance measurements.

Evidence collection must stop when the important claim is convincingly established and relevant failure modes are reasonably excluded.

Evidence volume itself is not a quality metric.

---

## 13. Bug and failure classification

Observed problems must be classified before assignment when practical:

ENGINE_BUG
GAMEPLAY_BUG
DESIGN_FAILURE
TEST_DEBT
ASSET_PIPELINE_BUG
PROJECT_SYSTEM_BUG

A DESIGN_FAILURE must not be routed to Codex as a generic instruction to "make tests green."

A TEST_DEBT finding must not automatically change gameplay.

---

## 14. Git and CI operating rule

MAIN_ROLE=CURRENT_STABLE_PLAYABLE

Normal production flow:

MILESTONE_OR_FEATURE_BRANCH
-> LOCAL_GODOT_VERIFICATION
-> PULL_REQUEST
-> CORE_CI
-> REVIEW
-> MERGE

Rules:
- avoid many tiny direct-to-main commits;
- batch coherent milestone/feature work;
- CI should protect a small set of high-value technical regressions;
- ordinary product progress must not be measured by workflow-run count;
- CI must not become a substitute for human play or product review;
- documentation-only work should not cause QA scope expansion merely because a workflow exists.

---

## 15. Documentation rule

The project should prefer a small set of living current documents over accumulating many overlapping contracts and audit reports.

Recommended living structure:

docs/current/CURRENT_STATE.md
docs/current/PRODUCT.md
docs/current/BATTLE01.md
docs/current/ART_DIRECTION.md
docs/current/ROADMAP.md

These files are not required to exist before the relevant information is ready, and their existence does not override this Charter.

Historical documents remain recoverable through Git history or explicit archival storage when useful, but do not retain authority merely because they once carried FROZEN or PASS labels.

---

## 16. Legacy migration rule

Existing code, tests, designs, images, and documents are not automatically kept or removed.

They are classified according to current product value and dependency evidence:

KEEP
REWORK
REMOVE
HOLD

Deletion requires sufficient confidence that unique design knowledge, provenance, runtime dependency, recoverability, and future product value are understood.

Unknown provenance or uncertain product value defaults to HOLD, not deletion.

---

## 17. Conflict, uncertainty, and truthfulness

When evidence is incomplete, the project state must say UNKNOWN, UNVERIFIED, PARTIAL, or CONFLICT rather than manufacture certainty.

Do not infer:
- user approval from an internal PASS;
- current runtime health from an old test;
- product quality from technical correctness;
- authority from file names;
- feature necessity from historical implementation cost.

The project must distinguish what is known, what is inferred, what is historical, and what still requires player or user validation.

---

## 18. Charter amendment rule

This Charter is frozen as the project-level operating baseline.

It may be amended only when a project-level operating principle materially changes.
Battle-specific balancing, unit values, AI timings, art asset lists, individual bug fixes, or ordinary implementation details do not require a Charter revision.

A future Charter revision must state:
- what project-level principle changed;
- why the previous rule became insufficient;
- what downstream authority is affected.

Version-number growth must not be used as a substitute for maintaining a clear current state.

---

## 19. Highest project rule

FRONTLINE design, code, art, AI, QA, tests, tooling, and project management exist to improve the player's battlefield judgment inside a real connected playable.

Work must not enter the mainline solely because a system is incomplete, a historical contract exists, a test expects it, or an implementation agent can build it.

PLAYER_EXPERIENCE_OVER_PROCEDURAL_COMPLETENESS=YES
CONNECTED_PLAYABLE_OVER_ISOLATED_SYSTEM_COUNT=YES
PRODUCT_TRUTH_OVER_INTERNAL_PASS_LABELS=YES
