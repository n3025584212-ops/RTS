# BATTLE01 Enemy AI Runtime QA Gate V1

TASK_ID=VERIFY_BATTLE01_ENEMY_AI_RUNTIME_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA
STATUS=PENDING_RUNTIME_EVIDENCE
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ENGINE=Godot 4.7.1
VERIFIED_SHA=0cef3a9b1e1dd2078d9eb25966949c8dc96b1929
INPUT_CONTRACT=docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md

## Independent QA findings

- Main is exactly `0cef3a9b1e1dd2078d9eb25966949c8dc96b1929` at this gate review.
- The frozen enemy AI contract is present and defines fog-limited knowledge, deterministic decisions, 4.0s INVESTIGATE, 350 world-unit pursuit leash, objective defense, infantry/armor/supply roles, deterministic route handling, and one-shot reinforcement behavior.
- `scripts/battle01/enemy_ai_controller.gd` implements the seven-state controller, 0.25s decision cadence, CONTACT/CONFIRMED/LAST_KNOWN semantics, legitimate LOS/range observation, static LAST_KNOWN, objective priority, armor reserve conditions, Supply Truck SUPPORT/EVADE, 150s/objective-loss reinforcement activation guard, dead-target cleanup, deterministic target tie-break, and deterministic route tie-break.
- Battle01 scene integrates `EnemyAIController`.
- The runtime workflow contains an enemy-AI smoke command and assertions for the required AI markers.
- The provided Window 04 marker list matches actual smoke assertions embedded in the current controller implementation.
- No readable CI status or workflow run is attached to the verified SHA, and no repository audit currently binds the local Godot 4.7.1 run to the exact SHA with command/exit-code evidence.

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS_STATIC_AND_TRACEABILITY
AI_BEHAVIOR_PASS=RUNTIME_EVIDENCE_PENDING
FOG_KNOWLEDGE_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
OBJECTIVE_DEFENSE_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
ARMOR_ROLE_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
SUPPLY_ROLE_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
REINFORCEMENT_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
ROUTE_RESPONSE_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
PURSUIT_ANTI_EXPLOIT_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
DETERMINISM_PASS=STATIC_PASS_RUNTIME_UNVERIFIED
RELEVANT_REGRESSION_PASS=RUNTIME_EVIDENCE_PENDING
PRODUCT_CORRECTNESS_PASS=RUNTIME_EVIDENCE_PENDING
QA_GATE_RESULT=BLOCKED
READY_FOR_NEXT_STAGE=NO
BLOCKER=MINIMUM_VERSION_BOUND_RUNTIME_EVIDENCE_NOT_YET_PUBLISHED_FOR_0cef3a9b1e1dd2078d9eb25966949c8dc96b1929

## Minimum evidence needed to close the gate

A compact repository audit is sufficient. It must bind the run to the exact verified SHA and include:

1. `git rev-parse HEAD` showing the verified SHA;
2. Godot `--version` showing 4.7.1;
3. the actual enemy-AI smoke command and exit code;
4. the required AI PASS markers, including reinforcement one-shot and deterministic replay;
5. the relevant Navigation / Recon / LOS / Combat / Objective / Victory regression commands, exit codes, and final PASS markers;
6. tracked worktree status before/after validation.

No full-project archive, full raw logs, redundant screenshots, or unrelated regression evidence is required.