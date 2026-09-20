# FRONTLINE GPT COLLABORATION SYSTEM V4

STATUS=ACTIVE
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
SUPERSEDES=docs/GPT_MULTI_WINDOW_SYSTEM_V3.md

## 1. Fixed specialist windows are abolished

There is no permanent:
- design expert window;
- implementation expert window;
- review expert window.

Window numbers are conversation contexts only. They do not prove competence, authority, independence, or correctness.

PERMANENT_SPECIALIST_WINDOW_ROLES=NO
WINDOW_NUMBER_AS_EXPERTISE=NO
WINDOW_NUMBER_AS_EVIDENCE=NO

## 2. Work is routed by task, not identity

Every active task is one of four evidence states:

EVIDENCE_TASK
- find and inspect real products, real projects, primary sources, assets, runtime evidence.

REPRODUCTION_TASK
- reproduce a selected mechanism or production method and compare it to the source.

BUILD_TASK
- apply already-supported methods to the actual FRONTLINE runtime.

REVIEW_TASK
- inspect the real artifact against external/reference/user criteria.

A chat/agent receives a task packet. It does not receive permanent epistemic authority.

## 3. Required task packet

Every substantial task must state:

GOAL=
CURRENT_REAL_ARTIFACT=
REFERENCE_OR_SOURCE=
KNOWN_FACTS=
HYPOTHESES=
UNKNOWNS=
ALLOWED_ACTIONS=
FORBIDDEN_SUBSTITUTIONS=
REQUIRED_EVIDENCE=
EXIT_CONDITION=

If CURRENT_REAL_ARTIFACT is missing for a build/review task, first retrieve it. Do not continue from prose memory.

## 4. Research behavior

The worker must not start by writing a general solution.

Required order:
1. inspect the actual object/problem;
2. identify the missing production knowledge;
3. gather strongest available evidence;
4. reproduce/verify where practical;
5. only then recommend or implement.

A useful source is one that changes what can be built or verified, not merely one that agrees with the current idea.

## 5. No internal consensus as proof

The following do not establish correctness:
- multiple GPT windows agreeing;
- a design window approving its own design;
- a coding agent reporting PASS;
- a review agent using only internally invented criteria;
- CI being green;
- a generated image looking persuasive.

Evidence must come from the artifact, source, runtime, reproducible behavior, or user judgment where subjective acceptance is required.

## 6. Review independence is procedural, not organizational

A REVIEW_TASK must begin from:
- actual artifact;
- stated target/reference;
- evidence checklist that predates the verdict where possible.

It must explicitly list failures and uncertainty.

The reviewer may be another context, the same model in a separate evidence task, an automated test, or the user depending on the question. A separate window number by itself creates no independence.

## 7. Anti-sycophancy / anti-drift rule

When the user proposes a cause or solution, record it as USER_HYPOTHESIS unless it is an explicit product preference/decision.

For causal/technical questions:
- test it;
- search for competing explanations;
- state when evidence disagrees.

USER_PREFERENCE is authoritative for desired product direction.
USER_HYPOTHESIS is not automatically authoritative about why a failure occurred.

## 8. Design behavior

Design is not a permanent upstream department.

A design task may begin only after enough production evidence exists to distinguish:
- supported elements;
- aspirational elements;
- unknown implementation paths.

A design artifact must not hide those distinctions.

## 9. Agent/Codex behavior

Codex is used for concrete evidence/reproduction/build work, not as an oracle.

Good Codex task:
- inspect these exact files/assets;
- reproduce this known effect;
- run this exact scene;
- capture this actual output;
- compare against this target;
- iterate until an evidence threshold or real blocker.

Bad Codex task:
- "make it more realistic" without source evidence;
- "improve game feel" without observable target;
- broad repository scans unrelated to the current evidence question;
- self-created success criteria that lower the target.

## 10. Concurrency

Use multiple contexts only when tasks can produce independently inspectable artifacts.

Do not split one uncertain problem into multiple speculative windows merely to create activity.

DEFAULT_ACTIVE_PRIMARY_TASKS=1
PARALLEL_TASKS_REQUIRE_SEPARABLE_EVIDENCE=YES

## 11. Current FRONTLINE consequence

The previous 00/01/02/03 system is historical routing only.

Current work should be expressed as tasks such as:
- EVIDENCE: study how a proven game/project builds natural settlement/road/terrain composition;
- REPRODUCTION: reproduce one terrain/material/lighting/VFX method in Godot;
- BUILD: apply the reproduced method to the existing Golden Scene;
- REVIEW: compare the actual 1920x1080 runtime against the approved target and user judgment.

No future result may claim authority because it came from "the design window", "the development window", or "the review window".
