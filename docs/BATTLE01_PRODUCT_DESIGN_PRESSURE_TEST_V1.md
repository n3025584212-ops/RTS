# BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V1

TASK_ID=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=AUTHORIZED_DESIGN_GATE
SOURCE_OF_TRUTH=GITHUB_MAIN
BASE_COMMIT=a197372ab5021a5acb0bb6124d734eb84dc7aa35
ENGINE=Godot 4.7.1
FULL_SCALE_STAGE_2_3_EXPANSION_BLOCKED_UNTIL_GATE=YES
NO_AUTOMATIC_SCOPE_EXPANSION=YES

## 1. Why this gate exists

Battle01 now has a real 3D technical foundation in main. Before adding expensive 3D gameplay closure, final world art, large asset production, or broader content, the game design itself must be pressure-tested as a playable product rather than assumed correct because individual systems exist.

The question is not whether Battle01 contains reconnaissance, movement, combat, AI, objectives, logistics and reinforcement. The question is whether those systems combine into a game that repeatedly creates understandable, interesting, consequential player decisions with good pacing and manageable command workload.

## 2. What must be pressure-tested

Evaluate the whole Battle01 player experience from briefing/deployment through victory/defeat and restart.

For every meaningful phase, identify:

- what the player knows;
- what the player is trying to achieve;
- what decisions are available;
- what each choice costs or risks;
- what new information arrives;
- how the enemy can invalidate the current plan;
- what the player can do in response;
- whether there is an obvious dominant answer;
- whether the player is making a decision or merely performing maintenance;
- whether the command workload is appropriate for Formation/Platoon-level play.

Explicitly search for:

- fake decisions;
- forced busywork;
- dead waiting time;
- excessive micro;
- systems that exist but do not materially interact;
- choices without opportunity cost;
- dominant strategies;
- unreadable failure causes;
- enemy behavior that becomes predictable after one playthrough;
- reinforcement/supply systems that are chores rather than tactical dilemmas;
- combat that is mechanically valid but emotionally flat;
- map routes that look different but produce the same decision;
- phases where the player has no meaningful reason to revise the plan.

## 3. Cross-genre distillation requirement

Do not limit references to RTS games. Distill proven design principles from relevant genres and keep only mechanisms that serve FRONTLINE's commander fantasy.

At minimum compare lessons from:

- modern real-time tactics / RTS for reconnaissance, route choice, combined arms and command workload;
- large-scale battle games for battlefield scale, unit-role clarity and changing fronts;
- FPS / vehicle combat games for impact, role readability, vehicle weight and battlefield feedback;
- action games for responsiveness and immediate command acknowledgement;
- MOBA / ARPG for combat readability, selection feedback, state signaling and information hierarchy;
- tactical / turn-based games for meaningful tradeoffs, commitment, uncertainty and recovery from mistakes;
- other genres when they provide a stronger solution to a FRONTLINE product problem.

Reference games are evidence/examples, not templates to copy wholesale.

## 4. Minimum product questions that must receive explicit answers

1. What is the player's recurring 20-60 second decision loop?
2. What makes reconnaissance a decision rather than a mandatory first click?
3. What makes route selection strategically different rather than cosmetic?
4. What makes Infantry / IFV / Armor / Recon / Logistics create different tactical options?
5. What forces plan revision after first contact?
6. What makes Central Bridgehead worth fighting for beyond being the next capture point?
7. What makes the enemy counterattack create a new problem rather than a scripted wave?
8. What makes resupply/withdrawal a risk-reward decision instead of housekeeping?
9. What makes the one reserve commitment a difficult choice?
10. What prevents one solved opening from dominating repeated plays?
11. How does the player understand why a formation succeeded, failed, or died?
12. How many simultaneous formations/commands can the player reasonably manage before commander fantasy turns into micro burden?
13. Where are the intended tension peaks, recovery windows and decisive culmination?
14. What produces immediate tactile satisfaction when issuing orders and watching combat?
15. Why would a player want to replay Battle01 after winning once?

## 5. Required outputs

Produce a compact product-design verdict, not a giant generic game-design report.

Required:

- BATTLE01_PLAYER_DECISION_LOOP_V1
- BATTLE01_PHASE_BY_PHASE_PRESSURE_TEST_V1
- BATTLE01_FAKE_DECISION_AND_BUSYWORK_AUDIT_V1
- BATTLE01_COMMAND_WORKLOAD_AUDIT_V1
- BATTLE01_CROSS_GENRE_MECHANIC_DISTILLATION_V1
- BATTLE01_DESIGN_CHANGES_REQUIRED_V1
- BATTLE01_PRODUCT_DESIGN_GATE_V1

For every proposed design change state:

- current problem;
- player-facing consequence;
- proposed change;
- why it is better;
- what existing frozen rule it would affect;
- whether it is essential for Battle01 or should remain future scope.

Do not silently modify frozen implementation contracts. Window 00 must adjudicate conflicts after this design gate.

## 6. Gate result

Allowed results:

- PASS — current design is strong enough for Stage 2/3 implementation with only minor tuning;
- REVISE — specific design changes are required before expensive implementation continues;
- FAIL_DIRECTION — the core Battle01 loop is not strong enough and requires structural redesign.

A PASS must show that the game has meaningful recurring decisions, understandable tradeoffs, manageable command workload, plan revision, combat satisfaction, and at least two materially different viable approaches.

## 7. Implementation hold

The already-landed 3D foundation is retained as technical infrastructure and is not automatically reverted.

Until this gate closes:

- do not expand into large final-art production;
- do not mass-produce units/buildings/VFX;
- do not add new gameplay scope;
- do not perform broad Stage 2/3 migration based on unreviewed assumptions;
- focused fixes needed to keep the current build bootable/testable remain allowed.

The purpose is to avoid spending heavily on a game design that has not yet survived product-level scrutiny.

## 8. Human-readable closeout

The result must first explain in ordinary language:

- what kind of game Battle01 currently feels like;
- what is genuinely fun/strong;
- what is weak, repetitive, fake, tedious or unclear;
- what should change before more implementation;
- what mechanics were distilled from other games and why they fit FRONTLINE;
- whether full 3D/gameplay/art expansion is now safe to resume.

Technical markers may follow, but cannot replace this explanation.
