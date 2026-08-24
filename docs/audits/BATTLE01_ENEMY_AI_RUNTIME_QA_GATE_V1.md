# BATTLE01 Enemy AI Runtime QA Gate V1

TASK_ID=VERIFY_BATTLE01_ENEMY_AI_RUNTIME_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA
STATUS=BLOCKED_PRODUCT_BEHAVIOR_EVIDENCE
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ENGINE=4.7.1.stable.official.a13da4feb
VERIFIED_SHA=0cef3a9b1e1dd2078d9eb25966949c8dc96b1929
INPUT_CONTRACT=docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md
SOURCE_AUDIT=docs/audits/BATTLE01_ENEMY_AI_RUNTIME_AUDIT_V1.md
SOURCE_AUDIT_COMMIT=935b09ef0c6bce7f0958ff9ff88a296182ef1b38

## Independent QA findings

- Version identity is proven: runtime executed in a detached worktree at the exact verified SHA.
- Godot 4.7.1 identity, commands, exit codes, blocking-error scan and tracked-worktree integrity are proven.
- Enemy AI smoke passed with the required state/intel/objective/route/pursuit/supply/reinforcement/dead-target/determinism markers.
- Navigation, Recon/LOS, Combat, Objective, Victory and multi-formation related regressions passed.
- The audit publication commit adds only the audit document and does not modify gameplay code or assets.
- Static contract-to-code traceability confirms the seven-state controller, fog-limited knowledge, 4.0s INVESTIGATE, 350 world-unit pursuit leash, objective defense, armor reserve logic, Supply SUPPORT/EVADE, deterministic route/target tie-break and one-shot reinforcement guard.

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS
RUNTIME_EXECUTION=PASS
AI_BEHAVIOR_SMOKE=PASS
FOG_KNOWLEDGE_PASS=PASS_TECHNICAL
OBJECTIVE_DEFENSE_PASS=PASS_TECHNICAL
ARMOR_ROLE_PASS=PRODUCT_EVIDENCE_PENDING
SUPPLY_ROLE_PASS=PRODUCT_EVIDENCE_PENDING
REINFORCEMENT_PASS=PASS_TECHNICAL
ROUTE_RESPONSE_PASS=PRODUCT_EVIDENCE_PENDING
PURSUIT_ANTI_EXPLOIT_PASS=PRODUCT_EVIDENCE_PENDING
DETERMINISM_PASS=PASS
RELEVANT_REGRESSION_PASS=PASS
PRODUCT_CORRECTNESS_PASS=PENDING_FOCUSED_PLAYER_VISIBLE_EVIDENCE
QA_GATE_RESULT=BLOCKED
READY_FOR_NEXT_STAGE=NO
BLOCKER=FOCUSED_PLAYER_VISIBLE_AI_BEHAVIOR_EVIDENCE_REQUIRED

## Minimum remaining evidence

Do not rerun the whole audit suite and do not upload a full project archive.

One compact focused runtime evidence item is sufficient if it persuasively demonstrates the four player-visible behaviors that boolean smoke markers alone do not reconstruct:

1. bait/pursuit reaches the leash or loses confirmation, then the defender returns/recenters instead of following hidden BLUE;
2. armor starts in reserve, commits on legitimate bridgehead pressure, then returns to reserve/defense posture after the local threat ends;
3. Supply Truck visibly cancels unsafe support movement and EVADES a legitimately confirmed threat while remaining non-combat/non-capture;
4. an initially unseen North or South flank causes no pre-detection reaction, then after legitimate confirmation INF-02 becomes the preferred local responder without omniscient map-wide reaction.

Acceptable proof may be either:

- one short focused runtime capture covering these behaviors; or
- concise runtime telemetry containing actual state transitions, unit identity, route/mission changes and return/evade endpoints sufficient to reconstruct the same behaviors.

No unrelated regression rerun, large log bundle, duplicate screenshots or full-project ZIP is required.
