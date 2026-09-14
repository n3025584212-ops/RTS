# FRONTLINE — WINDOW 03 EVIDENCE AUDIT CONTRACT V1

STATUS=ACTIVE
PROJECT=FRONTLINE《战线》
WINDOW=03_INDEPENDENT_REVIEW_AND_FALSIFICATION
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
ACTIVE_ISSUE=#39

## 1. Mission

Window 03 does not restate Window 01. It audits whether Window 01's chain from evidence -> fact -> inference -> recommendation crosses the boundary of what the evidence actually supports.

The default posture is falsification-first:
- look for source mistakes;
- look for version mistakes;
- look for broken caller/callee or data-flow claims;
- look for unsupported generalization;
- look for competing explanations;
- look for mature counterexamples.

A different window number does not create independence. Independence must come from separate source inspection, explicit counterevidence search, and pre-stated audit criteria.

## 2. Six hard audit checks

### CHECK_01 — PRIMARY_SOURCE_INTEGRITY
Question: Is a secondary article being presented as source-code evidence?

PASS requires core implementation claims to trace to the project's authoritative source repository / release source / exact file, function, component, commit, tag, or equivalent primary artifact.

Official documentation may explain the implementation but must not be mislabeled as source-code proof.

Forums, wiki pages, blogs, Reddit, videos, articles, model summaries, and community explanations may be leads or contextual evidence only unless the claim itself is explicitly about those sources.

Typical FAIL:
- "an article says 0 A.D. works this way" -> "the source code proves..."

### CHECK_02 — VERSION_IDENTITY
Question: Is the evidence from the correct version?

Every important implementation claim must record:
- PROJECT
- AUTHORITATIVE_REPOSITORY_OR_SOURCE
- BRANCH / TAG / RELEASE
- COMMIT when available
- SOURCE_DATE or retrieval date where relevant

Historical source may be used only when labeled historical.

Current verified warning for Sprint 01:
- the GitHub repository `0ad/0ad` is archived and describes itself as a deprecated Git mirror;
- it states that development source migrated to Wildfire Games Gitea on 2024-08-20;
- therefore GitHub `master` cannot, by itself, prove the 2026 current implementation or Release 28 implementation.

Release-28 documentation may support Release-28 documented component facts, but source-code claims still need a Release-28-matched authoritative source snapshot when available.

Typical FAIL:
- old GitHub mirror code -> claim about current 2026 source without qualification.

### CHECK_03 — RUNTIME_SEMANTICS
Question: Does the cited code actually support the claimed runtime behavior?

The audit must distinguish:
- symbol/class/component existence;
- configuration/data declaration;
- callable path;
- actual caller -> callee chain;
- runtime condition / guard;
- state source;
- data mutation / side effect;
- alternate or bypass path;
- observed runtime behavior.

For critical edges, source presence alone is insufficient. Trace the call/data path and use runtime evidence where practical.

Typical FAIL:
- finding `UnitAI` or `Pathfinder` and concluding that all commands necessarily pass through a claimed route.

### CHECK_04 — GENERALIZATION_BOUNDARY
Question: Did a project-specific fact get promoted into an RTS rule?

Every conclusion must be classified as one of:
- SOURCE_FACT
- PROJECT_SPECIFIC_INFERENCE
- CROSS_PROJECT_PATTERN
- DESIGN_RECOMMENDATION
- UNSUPPORTED_GENERALIZATION

Allowed escalation:
`source fact -> project-specific inference -> cross-project pattern -> design recommendation`

Each step requires new evidence.

One project's architecture is never sufficient to establish a universal RTS rule.

Typical FAIL:
- "0 A.D. uses a component system" -> "RTS should use a component system."

### CHECK_05 — ALTERNATIVE_EXPLANATIONS
Question: Did Window 01 search for at least one serious competing explanation?

For important causal claims, Window 03 must test whether the observed implementation could instead be explained by:
- historical evolution / legacy constraint;
- deterministic simulation or networking requirements;
- scripting convenience;
- engine boundary;
- performance constraint;
- tooling constraint;
- content-authoring needs;
- backwards compatibility;
- project-specific gameplay requirements.

Code structure alone must not be converted into a unique design motive unless direct evidence supports that motive.

Typical FAIL:
- architecture X exists -> therefore designers chose X for reason Y, with no direct evidence and no alternative considered.

### CHECK_06 — COUNTEREXAMPLE_SEARCH
Question: Do BAR/Recoil, Warzone 2100, or another mature RTS achieve the same player function with a materially different implementation boundary?

Window 03 must actively look for counterexamples when Window 01 proposes a necessary condition, general rule, or strong recommendation.

Current verified counterexample warnings:
- Beyond All Reason explicitly separates game code from the Recoil RTS Engine and also has a separate lobby/client layer. Reading only the BAR game repository does not reveal the whole engine/game/runtime architecture.
- Recoil is itself an RTS engine with a Lua API; this is a different engine/game boundary from 0 A.D.'s documented entity-component / scripted-wrapper organization.
- Warzone 2100 documents JavaScript scripting for AIs, campaigns, and some game rules on top of its native engine/core, demonstrating another materially different boundary.

A mature counterexample does not automatically make the original project wrong. It lowers claims of necessity or universality.

Typical FAIL:
- a different mature architecture exists but Window 01 still labels one implementation as required for RTS.

## 3. Required audit record for each important Window 01 claim

ORIGINAL_CLAIM=
CHAIN_LAYER_OR_EDGE=
SOURCE_FACT=
SOURCE_LOCATION=
PROJECT=
VERSION_TAG_COMMIT=
SOURCE_TYPE=SOURCE_CODE|OFFICIAL_DOC|RUNTIME|SECONDARY
RUNTIME_SEMANTICS=
WINDOW_01_CONCLUSION=
HIDDEN_ASSUMPTIONS=
ALTERNATIVE_EXPLANATION=
COUNTEREXAMPLE_SEARCH=
COUNTEREXAMPLE_RESULT=
GENERALIZATION_LEVEL=
VERDICT=PASS|DOWNGRADE|FIX|REJECT|UNKNOWN
ALLOWED_FINAL_WORDING=

## 4. Generalization taxonomy

### SOURCE_FACT
Directly supported by the correctly versioned primary source or observed runtime.

### PROJECT_SPECIFIC_INFERENCE
Reasonable inference about the selected project, but not directly encoded as a fact and not generalized beyond that project.

### CROSS_PROJECT_PATTERN
Observed independently across multiple materially different mature implementations. This is still a pattern, not a law.

### DESIGN_RECOMMENDATION
A proposed choice for FRONTLINE based on evidence plus FRONTLINE-specific constraints. It is a recommendation, not an external fact.

### UNSUPPORTED_GENERALIZATION
The wording claims more scope, necessity, causality, or universality than the evidence supports.

## 5. FRONTLINE transfer gate

`0 A.D. does X` is never sufficient for `FRONTLINE should do X`.

Before transfer, the evidence chain must explicitly address FRONTLINE-specific conditions where relevant:
- Godot 4.7.1 architecture and available APIs;
- current unit / formation scale;
- expected battle density;
- AI requirements;
- deterministic or networking requirements if any;
- performance budget;
- content-production workflow;
- maintainability and iteration cost;
- visual/readability target;
- already verified reusable code.

The final transfer statement must be labeled DESIGN_RECOMMENDATION unless directly about an existing FRONTLINE implementation fact.

## 6. Relation to the 13-layer evidence graph

Window 03 audits edges, not only documents.

For every critical edge in:
`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

Window 03 asks:
1. What exactly is the source fact?
2. Which exact source/version proves it?
3. Does the runtime path actually connect A -> B?
4. What assumptions are needed to get from fact to conclusion?
5. Is there another explanation?
6. Do BAR/Recoil, Warzone, or another mature project provide a counterexample?
7. What wording and generalization level are actually allowed?

## 7. Audit behavior toward Window 02

The same standard applies to reproduction/build claims.

Window 03 must distinguish:
- code exists;
- code executes;
- intended state change occurs;
- presentation feedback occurs;
- player-visible result actually matches the tested claim.

CI green, node counts, files, or screenshots that hide missing behavior cannot substitute for the real artifact.

## 8. Current verified alerts for Sprint 01

ALERT_01_0AD_GITHUB_CURRENT_SOURCE=ACTIVE
The archived `0ad/0ad` GitHub mirror is historical evidence unless its exact revision is matched to the release being discussed. It must not be cited as current 2026 source by default.

ALERT_02_ENGINE_GAME_BOUNDARY=ACTIVE
BAR, Recoil, Warzone 2100, and 0 A.D. divide engine, game logic, scripting, UI/lobby, simulation, and content differently. This is direct reason to treat architectural generalization cautiously.

ALERT_03_COMPONENT_EXISTENCE_NOT_CALL_CHAIN=ACTIVE
0 A.D. Release-28 component documentation lists system components, script wrappers, scripted components, `UnitAI`, `Pathfinder`, `GuiInterface`, and other component types. That taxonomy does not by itself establish the exact runtime command chain for a specific player action.

## 9. Verdict rules

PASS = evidence, version, semantics, scope, alternatives, and wording are all supported.
DOWNGRADE = underlying evidence is usable but conclusion/generalization must be narrowed.
FIX = likely repairable evidence gap; Window 01 must obtain better source/version/runtime tracing.
REJECT = source or reasoning materially contradicts the claim.
UNKNOWN = available evidence is insufficient; do not fill with plausible prose.

Window 03 should prefer DOWNGRADE/FIX/UNKNOWN over inventing a stronger alternative conclusion without evidence.

## 10. Exit condition

Window 03 audit for a chain segment is complete only when:
- core sources are primary and version-identified;
- critical runtime edges have semantic tracing, not symbol existence alone;
- project-specific facts are separated from cross-project patterns;
- competing explanations were actively considered;
- counterexamples were searched where generalization is attempted;
- final wording states only what the evidence supports;
- unresolved gaps remain explicitly UNKNOWN.

AUDIT_PRIORITY=FIND_FAILURES_BEFORE_SUPPORTING_ARGUMENTS
INTERNAL_AGREEMENT_IS_NOT_EVIDENCE=YES
WINDOW_01_PASS_IS_NOT_SELF_AUTHORIZING=YES
WINDOW_03_TITLE_IS_NOT_PROOF_OF_INDEPENDENCE=YES
