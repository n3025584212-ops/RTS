# BATTLE01_PRE_BATTLE_STAGING_CONTRACT_V1

TASK_ID=DESIGN_AND_FREEZE_BATTLE01_PRE_BATTLE_STAGING_CONTRACT_V1  
OWNER_WINDOW=WINDOW_01_GAME_DESIGN  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
STATUS=FROZEN

START_MAIN_SHA=620645d82ca235f81d6d03fede96866864987813

## 0. Authority and scope

This contract freezes the Battle01 pre-battle fixed-roster staging phase only.

It inherits and does not revise:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md`
- `docs/BATTLE01_FORMATION_RULES_V2.md`
- `docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/audits/BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_RUNTIME_QA_GATE_V2.md`
- `docs/audits/BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_RUNTIME_QA_GATE_V2.md`
- `docs/audits/BATTLE01_SEEDED_RED_DEFENSE_POSTURES_RUNTIME_QA_GATE_V2.md`
- `docs/audits/BATTLE01_RESUPPLY_RED_LOGISTICS_RUNTIME_QA_GATE_V1.md`

This is a gameplay/product contract. It does not prescribe the final Node, signal, timer, state-storage, or HUD implementation architecture.

STAGING_PURPOSE=FIXED_ROSTER_DEPLOYMENT_AND_FIRST_INTENT  
FIXED_ROSTER_ONLY=YES  
ECONOMY_ADDED=NO

No currency, purchase, production, deck, loadout, commander perk, unit replacement, or unit-unlock shop is introduced.

## 1. Product intent

Battle01 staging exists to give the player one short commander-level planning moment before the tactical clock begins.

The player should be able to answer three questions before pressing START:

1. How are my four active Formations grouped inside the existing West rear space?
2. Which route/angle does each Formation initially intend to take?
3. Which combat Formations begin under HOLD FIRE discipline, if any?

Staging must create meaningful opening commitments without revealing the seeded RED posture and without granting free forward movement.

Staging is not a separate economy or metagame. It is the T=0 setup of the already-frozen Battle01 force.

## 2. Staging roster

ACTIVE_STAGING_ROSTER=
- BLUE RECON-01 x1
- BLUE INF-01 x1
- BLUE IFV-01 x1
- BLUE SUPPLY-01 x1

Current default legal fallback positions remain:

- BLUE IFV-01 `(520, 900)`
- BLUE RECON-01 `(760, 600)`
- BLUE INF-01 `(620, 1080)`
- BLUE SUPPLY-01 `(420, 1080)`

Reserve remains outside staging.

RESERVE_STAGING_ALLOWED=NO

The reserve UI may only communicate `LOCKED / NOT AVAILABLE` during staging. The player may not choose Infantry/Armor, deploy it, reposition it, or treat it as a fifth active Formation before the already-frozen first PLAYER capture of Central Bridgehead.

## 3. Formal staging state

STAGING_STATE=SIMULATION_NOT_STARTED

SIMULATION_ACTIVE_DURING_STAGING=NO  
STAGING_UI_AND_CAMERA_ACTIVE=YES

Before `START BATTLE`, the following gameplay systems do not advance real battle simulation:

- Enemy AI decision = OFF
- Enemy movement = OFF
- Friendly movement execution = OFF
- Combat fire = OFF
- Ammo consumption = OFF
- Damage = OFF
- Capture timers = OFF
- Contest resolution = OFF
- Objective ownership transition = OFF
- Resupply transfer = OFF
- BLUE reserve unlock = OFF
- RED reinforcement time/activation progression = OFF
- Victory/Defeat evaluation = OFF
- battle-time phase/timer progression = OFF

Initialization work is allowed while staging, including loading the map, spawning the fixed roster, resolving the deterministic RED posture seed, preparing navigation, rendering BLUE staging markers, and presenting terrain/objective information. None of that counts as battle simulation.

The player may spend unlimited staging time without changing the battlefield state.

## 4. Enemy FOW and posture protection

STAGING_ENEMY_INTEL=UNSEEN_NORMAL_FOW  
INTEL_LEAK_ALLOWED=NO

The seeded RED posture may already be resolved and physically initialized before START, but staging must not reveal:

- active posture name;
- RED Infantry screen locations;
- RED Armor reserve location;
- RED Supply location;
- dormant reinforcement location/status beyond normal product knowledge;
- any other hidden RED exact position.

During staging:

- RED presentation remains hidden under normal FOW semantics;
- RED detection/confirmation progression against BLUE does not run;
- BLUE detection/confirmation progression against RED does not run;
- no CONTACT or CONFIRMED state is earned before T=0;
- pre-battle camera pan/zoom cannot expose hidden RED bodies or posture labels;
- minimap/tactical overview may show terrain, objectives and BLUE staging information, but no hidden RED truth.

At `START BATTLE`, intel begins from the normal battle-start state and actual RED positions must still be discovered through Recon / LOS / CONTACT / CONFIRMED.

## 5. Seeded RED posture timing

RED_POSTURE_RESOLVED_BEFORE_START=YES  
RED_POSTURE_LOCKED_DURING_STAGING=YES

The current seeded posture sequence and all existing posture anchors remain authoritative.

The posture seed/run is resolved when the Battle01 run/scene is created, before START, and remains fixed for that staging session.

STAGING_REPOSITION_DOES_NOT_REROLL_RED_SEED=YES  
RED_POSTURE_REROLL_ON_REPOSITION=NO  
START_BATTLE_DOES_NOT_REROLL_RED_SEED=YES  
RED_POSTURE_REROLL_ON_START=NO

Restart creates the next formal Battle01 run and continues the already-frozen deterministic `A -> B -> C -> A` normal-session posture sequence. Staging itself never consumes or rerolls the sequence.

## 6. WEST_STAGING_AREA

No new map region is created.

STAGING_AREA=WEST_STAGING_AREA

The staging area is a bounded polygon inside the existing West BLUE start space. Coordinates use the existing Battle01 simulation/world plane.

STAGING_AREA_BOUNDS=
- STAGING_AREA_MIN_X=280
- STAGING_AREA_MAX_X=900
- STAGING_AREA_MIN_Y=480
- STAGING_AREA_MAX_Y=1320

STAGING_AREA_POLYGON, clockwise:

1. `(280, 480)`
2. `(680, 480)`
3. `(800, 600)`
4. `(840, 760)`
5. `(900, 900)`
6. `(840, 1040)`
7. `(800, 1200)`
8. `(680, 1320)`
9. `(280, 1320)`

Polygon edges are legal placement boundary lines subject to the normal placement validity tests below.

### 6.1 Why this shape is frozen

The polygon uses one narrow Central forward tip and shallower North/South shoulders instead of a full-width eastern rectangle.

It intentionally:

- contains all four current default BLUE positions;
- stays entirely west of the first current forward hard-blocker bands;
- stays west of the river and Central Bridgehead;
- stays west of the North forward village/foot-link geometry;
- stays north/west of the South forward maneuver entry geometry;
- gives FOOT and VEHICLE Formations legal walkable space;
- keeps BLUE SUPPLY-01 in a valid connected vehicle area;
- prevents staging from placing Recon or another Formation directly into the forward village/bridgehead combat space;
- preserves a meaningful post-START route choice.

The staging area is not a fourth route and does not change Central/North/South geometry.

## 7. Placement validity

A staged position is valid only when all are true:

1. Formation center is inside/on `WEST_STAGING_AREA` polygon.
2. Position is not inside any current hard blocker.
3. Position is not inside river geometry.
4. Position is not inside either objective core.
5. Position is walkable/reachable for that Formation's current frozen mobility class.
6. Position respects minimum separation from every other active staged BLUE Formation.

Formation-aware mobility remains:

- Recon = FOOT
- Infantry = FOOT
- IFV = VEHICLE
- Logistics = VEHICLE

Staging does not use a generic movement profile and does not bypass North foot-only rules after START.

## 8. Formation separation

STAGING_MIN_FORMATION_SEPARATION=160_WORLD_UNITS_CENTER_TO_CENTER

This is a staging-layout spacing rule only. It is not a new collision, cover, formation-shape or combat-spacing system.

All four current default positions satisfy the rule.

Purpose:

- prevent markers from being stacked into one unreadable point;
- preserve distinct route-facing deployment choices;
- make the narrow Central forward tip a real allocation choice instead of allowing the full roster to occupy the same front edge.

## 9. Placement interaction

PLACEMENT_INTERACTION=PRE_BATTLE_DRAG_PLACEMENT

Frozen interaction:

- LMB click a BLUE active Formation marker = select it.
- LMB press-and-drag beginning on a BLUE Formation marker = placement drag for that one Formation.
- Dragging the marker does not execute movement and consumes no battle time.
- The dragged marker shows legal/illegal placement feedback.
- Release on a valid position = commit staged position.
- Release on an invalid position = restore the Formation to its last valid staged position.
- LMB drag beginning on empty ground remains normal box selection; it is not interpreted as deployment dragging.
- Shift/additive selection may remain available for command queueing, but placement dragging always relocates one specific marker at a time.

INVALID_PLACEMENT_BEHAVIOR=REJECT_AND_RETURN_TO_LAST_VALID_STAGED_POSITION

There is no animated walk between staged positions.

STAGED_POSITION=T0_START_POSITION

## 10. Initial intent model

INITIAL_INTENT_LIMIT=ONE_PER_ACTIVE_FORMATION

INITIAL_INTENT_ALLOWED=
- MOVE
- ADVANCE
- HOLD

The initial intent is not executed during staging. It is a stored T=0 command.

STAGED_POSITION and INITIAL_INTENT are separate concepts:

- STAGED_POSITION = where the Formation exists when battle simulation begins.
- INITIAL_INTENT = what that Formation begins doing after T=0.

Queuing a North MOVE for Recon must not move Recon toward North during staging.

### 10.1 Queue controls

The staging command language reuses the current commander intent language:

- RMB on world terrain = queue initial MOVE for selected eligible active Formation(s).
- SHIFT + RMB = queue initial ADVANCE for selected eligible combat Formation(s).
- `HOLD / CLEAR INITIAL` staging HUD control = clear selected Formation(s)' queued MOVE/ADVANCE and return them to initial HOLD.

No new command wheel, waypoint chain, patrol, guard, attack-ground, or staging-only movement command is added.

A queued destination may use visible map/terrain knowledge, but it grants no hidden enemy information and must be legal/reachable under the same Formation-aware movement authority that will execute after T=0.

If an initial MOVE/ADVANCE target is invalid/unreachable for a Formation's mobility, that Formation's queue update is rejected and its previous valid initial intent is preserved.

If a later staged reposition makes a previously queued target invalid from the new T=0 position, the queue is cleared to HOLD with explicit feedback rather than silently substituting a different route/target.

## 11. HOLD semantics

NO_QUEUED_ORDER=INITIAL_HOLD

HOLD is the default initial intent.

If the player gives no MOVE/ADVANCE order, the Formation remains at its staged position after START until the player issues a later order or normal frozen combat/hold behavior legally applies.

Clearing a queued MOVE/ADVANCE returns the Formation to `INITIAL_HOLD`.

The staging HOLD/CLEAR control is a staging interaction control only; it does not redefine the already-frozen post-start HOLD command semantics.

## 12. HOLD FIRE preset

HOLD_FIRE_PRESET_ALLOWED=YES

HOLD FIRE is FIRE DISCIPLINE, not the one INITIAL MOVEMENT INTENT.

Therefore a combat Formation may simultaneously have:

- Initial MOVE + HOLD FIRE ON; or
- Initial ADVANCE + HOLD FIRE ON; or
- Initial HOLD + HOLD FIRE ON.

At START, HOLD FIRE carries into the real accepted HOLD FIRE authority and remains the final voluntary-fire veto until the player releases it.

Eligible staging HOLD FIRE roles:

- Recon = YES
- Infantry = YES
- IFV = YES
- Logistics = NO / unavailable because it cannot attack

The current `H` HOLD FIRE interaction may be reused during staging for eligible selected combat Formations. No staging-specific fire-discipline system is created.

## 13. Logistics initial intent

LOGISTICS_ADVANCE_ALLOWED=NO

BLUE SUPPLY-01 legal initial intents:

- MOVE
- HOLD

ADVANCE is unavailable/rejected with clear feedback. This preserves `LOGISTICS CANNOT ADVANCE` and does not give Logistics attack capability.

## 14. Commands unavailable during staging

RESUPPLY_AVAILABLE_IN_STAGING=NO  
WITHDRAW_AVAILABLE_IN_STAGING=NO

Reasons:

- all Formations enter battle with their frozen starting ammo state;
- battle has not begun, so unlimited pre-battle time cannot be converted into supply transfer value;
- there is no combat state from which to withdraw.

Reserve deployment is also unavailable while staging.

Normal F Resupply, X Withdraw and Reserve interactions become available only after START subject to their already-frozen runtime rules.

## 15. Objective state during staging

OBJECTIVE_PROGRESS_DURING_STAGING=NO

Central Bridgehead and Industrial Objective remain at their frozen initial owner/lock state during staging.

No capture progress, contest progress, ownership flip, reserve unlock, forward-rally unlock or victory evaluation may occur before START.

Placement validation already prohibits the active BLUE roster from being placed into objective cores, but simulation safety must still prevent objective progress even if an implementation defect temporarily produces an illegal location.

## 16. Camera and tactical read

During staging the player may:

- pan camera;
- zoom camera;
- inspect terrain geometry;
- inspect Central/North/South route geometry;
- inspect known objective locations/status;
- inspect the four BLUE active Formations and their staging state.

This is legitimate commander map knowledge.

Camera freedom does not override FOW. Hidden RED truth stays hidden regardless of camera position or zoom.

## 17. START BATTLE control

START_BATTLE_EXPLICIT=YES

START_BATTLE_CONTROL=HUD_MOUSE_BUTTON_REQUIRED

A clear `START BATTLE` mouse button must exist in staging HUD.

Optional keyboard alias may be ENTER, but keyboard input is not a substitute for the visible mouse control.

The battle must not start from:

- countdown timeout;
- camera movement;
- selecting a Formation;
- dragging a Formation;
- queueing the first MOVE/ADVANCE;
- any other implicit interaction.

The player may repeatedly revise staging positions, initial intents and HOLD FIRE states until START.

START is allowed when the four active staged Formation positions are legal. Queued orders are optional because HOLD is valid.

## 18. T=0 START transaction

QUEUED_ORDERS_EXECUTE_AT_T0=YES

`START BATTLE` is one explicit state transition. At the T=0 boundary:

1. Lock the four current valid staged positions as their Battle01 start positions.
2. Permanently close staging for this run.
3. Reset/start the actual battle clock at T=0.
4. Enable Battle01 simulation.
5. Enable Enemy AI decisions/movement.
6. Enable normal BLUE/RED intel, detection, LOS and FOW progression from battle-start state.
7. Enable combat, ammo consumption and damage.
8. Enable objective capture/contest progression.
9. Start normal resupply/war-flow/reinforcement timing eligibility.
10. Activate each active BLUE Formation's stored initial intent through the existing authoritative command path in the same start transaction.
11. Formations with no queued MOVE/ADVANCE begin HOLD at their staged positions.
12. Preserve each eligible Formation's pre-set HOLD FIRE state.

No Formation receives an artificial delayed start. Apparent differences after T=0 may arise only from existing pathing/mobility and player actions, not staged stagger timers.

## 19. Queued MOVE execution

Initial MOVE after START must enter the existing accepted RMB MOVE semantics.

INITIAL_MOVE_AUTHORITY=EXISTING_PLAYER_MOVE_COMMAND

It remains:

- movement-only;
- Formation-aware navigation;
- no automatic target acquisition merely because RED is CONFIRMED;
- direct player override compatible;
- subject to normal map blockers/route access.

No staging-specific MOVE executor is authorized.

## 20. Queued ADVANCE execution

Initial ADVANCE after START must enter the already accepted ADVANCE command authority.

INITIAL_ADVANCE_AUTHORITY=EXISTING_ADVANCE_COMMAND

It preserves:

- CONFIRMED-only target acquisition;
- attack range gate;
- legal LOS gate;
- no chase away from task;
- deterministic target behavior;
- Formation-aware mobility;
- HOLD FIRE final veto.

No duplicated `staging advance` implementation is authorized.

## 21. Formation-aware queued routes

Initial queue does not create a generic path layer.

At/after START:

- Recon / Infantry use FOOT mobility.
- IFV / Logistics use VEHICLE mobility.

A North queued command therefore cannot make IFV or Logistics use the frozen foot-only link.

The stored intent is a mission target/command, not a precomputed cheat path that bypasses current Navigation authority.

## 22. Reserve during staging

RESERVE_STAGING_ALLOWED=NO

Staging HUD may show:

`RESERVE — LOCKED · SECURE CENTRAL BRIDGEHEAD`

but must not provide:

- Infantry/Armor commitment choice;
- reserve placement control;
- reserve initial order;
- reserve marker as active BLUE force.

The existing irreversible reserve choice remains unlocked only by the first PLAYER capture of Central Bridgehead after battle starts.

## 23. Restart

RESTART_RETURNS_TO_STAGING=YES

After Victory/Defeat, `RESTART BATTLE01` starts a new Battle01 run at staging rather than immediately running combat.

The new run:

- receives the next seeded posture according to the frozen normal A -> B -> C -> A sequence;
- hides that posture under staging FOW;
- restores the fixed four active BLUE starting roster and default legal staging positions;
- clears previous initial MOVE/ADVANCE queues;
- restores normal fresh-run fire-discipline defaults;
- keeps reserve locked until the new run's first PLAYER Central Bridgehead capture;
- waits for a new explicit START BATTLE.

## 24. Minimum player-facing staging feedback

The staging UX must provide at minimum:

- banner/state: `PRE-BATTLE STAGING`;
- BLUE active roster: Recon / Infantry / IFV / Logistics;
- per-Formation name and role;
- per-Formation queued initial intent: HOLD / MOVE / ADVANCE;
- per-combat-Formation HOLD FIRE state;
- visible West Staging Boundary;
- valid/invalid placement feedback while dragging;
- world or equivalent target feedback for queued MOVE/ADVANCE sufficient to understand the stored first intent;
- Reserve status as LOCKED / NOT AVAILABLE, without deploy controls;
- visible `START BATTLE` button.

Not required and not authorized:

- deck UI;
- purchase UI;
- currency UI;
- unit shop;
- loadout screen;
- production queue.

Window 06 may later refine visual treatment without changing these product semantics.

## 25. Player value — Central opening

PLAYER_VALUE_CENTRAL=CENTRAL_TEMPO_AND_CONCENTRATION

Representative staging choice:

- IFV and Infantry nearer the narrow Central launch tip;
- Recon angled toward Central/North read;
- Supply held deeper/rearward.

Value:

- fastest concentration toward the shortest route;
- earlier ability to contest the predictable bridge defense;
- also the most obvious/exposed line once battle starts.

There is no stat bonus.

## 26. Player value — North opening

PLAYER_VALUE_NORTH=NORTH_INFORMATION_AND_FOOT_MANEUVER

Representative staging choice:

- Recon and/or Infantry use the North shoulder;
- IFV and Supply remain positioned for legal vehicle streets rather than the foot-only shortcut.

Value:

- earlier access to North information/ground-control geometry;
- better use of FOOT mobility identity;
- vehicle elements still pay the existing North detour cost.

There is no hidden North speed/stat modifier.

## 27. Player value — South opening

PLAYER_VALUE_SOUTH=SOUTH_VEHICLE_MANEUVER_AND_ANGLE

Representative staging choice:

- IFV nearer the South shoulder;
- Recon/Infantry remain at supporting distance;
- Supply can remain deeper for safety or commit toward the South vehicle lane.

Value:

- earlier commitment toward the wide South maneuver corridor;
- preserves the frozen longer-route tempo cost;
- can create a later vehicle angle/rear-logistics threat if the player accepts slower objective tempo.

There is no stat bonus.

## 28. No dominant all-forward deployment rationale

NO_DOMINANT_ALL_FORWARD_DEPLOYMENT_RATIONALE=

The staging area deliberately does not expose one full-height eastern edge.

- The maximum forward point `(900,900)` is a narrow Central apex.
- North/South forward shoulders taper backward.
- `160` world-unit center separation prevents all four Formations from stacking into the same narrow apex/adjacent edge.
- FOOT and VEHICLE identities make North launch positions differently valuable; vehicles do not gain the foot-only shortcut.
- The South shoulder still sits behind the frozen South maneuver entry, preserving its longer tempo cost.
- Supply gains no offensive capability from a forward spot; placing it aggressively reduces rear safety and may expose it earlier after T=0.
- A Formation committed toward one shoulder begins farther from at least one alternative route, so opening geometry creates a real route-switch cost.

Therefore `put every unit at the easternmost boundary` is neither physically possible as one stack nor universally optimal by role/route/survival.

NO_DOMINANT_FORWARD_DEPLOY_EXPLOIT=YES

## 29. Explicit non-changes

FORMATION_VALUES_CHANGED=NO  
DAMAGE_MATRIX_CHANGED=NO  
ROSTER_CHANGED=NO  
ROUTE_GEOMETRY_CHANGED=NO  
SEED_POSTURE_CHANGED=NO  
SUPPLY_RULE_CHANGED=NO  
OBJECTIVE_RULE_CHANGED=NO  
ADVANCE_RULE_CHANGED=NO  
HOLD_FIRE_RULE_CHANGED=NO  
ENEMY_AI_RULE_CHANGED=NO

This contract also adds no new map region, route, bridge, spawn outside the West staging area, weapon, unit family, economy, art/VFX system or AI redesign.

## 30. Implementation freedom

Window 02 may choose engineering details that preserve the frozen observable behavior, including:

- the runtime representation of STAGING vs ACTIVE state;
- how simulation subsystems are gated before START;
- where staged positions and queued intents are stored;
- helper functions and Typed GDScript data structures;
- signal wiring between staging, input, selection, war flow and HUD;
- placement ghost/outline implementation;
- polygon point-in-area test implementation;
- how the existing Formation-aware Navigation API is called for validation;
- exact HUD panel layout and styling before Window 06 refinement;
- CI hooks/markers and deterministic staging tests.

Implementation freedom may not change:

- staging polygon/bounds;
- 160-unit minimum separation;
- fixed active roster;
- reserve lock trigger;
- simulation-not-started semantics;
- FOW protection;
- input semantics frozen here;
- one initial intent per Formation;
- Logistics ADVANCE prohibition;
- HOLD FIRE preset allowance;
- explicit START requirement;
- T=0 transition behavior;
- seeded posture timing;
- existing MOVE/ADVANCE/HOLD FIRE authority.

## 31. Acceptance contract for implementation

Window 02 / downstream QA must be able to verify at minimum:

A. Staging boot
- Battle01 opens in PRE-BATTLE STAGING.
- Battle simulation has not started.
- four active BLUE Formations are present and reserve is locked.

B. Simulation freeze
- waiting in staging does not move RED/BLUE, consume ammo, deal damage, progress objectives, unlock reserve/reinforcement, run resupply, or evaluate victory/defeat.

C. FOW protection
- A/B/C posture may be internally seeded, but RED exact positions/posture name remain hidden under free camera/minimap use.
- no pre-start CONTACT/CONFIRMED progression occurs.

D. Placement
- all four default positions validate.
- valid drag commits instantly as placement, not movement.
- invalid out-of-polygon/blocker/river/objective/overlap release rolls back.
- minimum separation is enforced.

E. Initial intents
- each active Formation stores at most one MOVE/ADVANCE/HOLD intent.
- queueing does not physically move it before START.
- clear/HOLD returns to no queued movement order.

F. HOLD FIRE
- eligible combat Formation can enter START with HOLD FIRE preset.
- Logistics cannot use HOLD FIRE.

G. Logistics
- Logistics can queue MOVE/HOLD.
- Logistics ADVANCE is rejected/unavailable.
- F Resupply and X Withdraw are unavailable during staging.

H. START transition
- visible START BATTLE begins simulation explicitly.
- all queued valid intents activate in the same T=0 transition through existing command authorities.
- unqueued Formations HOLD.

I. Command preservation
- queued MOVE remains movement-only.
- queued ADVANCE preserves CONFIRMED/range/LOS/no-chase/formation-aware/HOLD-FIRE behavior.

J. Seed preservation
- staging reposition does not reroll posture.
- START does not reroll posture.
- Restart creates next A/B/C run and returns to staging.

K. Route-opening value
- Central/North/South staging arrangements are all legal and lead into their existing route identities without free forward deployment or geometry bypass.

## 32. Design Gate

PRODUCT_INTENT_COHERENT=YES  
STAGING_INTERACTION_UNAMBIGUOUS=YES  
NO_FOW_LEAK=YES  
NO_ECONOMY_EXPANSION=YES  
NO_DOMINANT_FORWARD_DEPLOY_EXPLOIT=YES  
INITIAL_ORDER_SEMANTICS_UNAMBIGUOUS=YES  
START_TRANSITION_UNAMBIGUOUS=YES

RESULT=PASS  
READY_FOR_IMPLEMENTATION=YES

No upstream Route, Enemy AI, Reserve trigger, Roster, Combat, Capture or Supply revision is required for staging to function.

## 33. Required summary fields

STAGING_PURPOSE=FIXED_ROSTER_DEPLOYMENT_AND_FIRST_INTENT  
FIXED_ROSTER_ONLY=YES  
ECONOMY_ADDED=NO

ACTIVE_STAGING_ROSTER=RECONx1;INFANTRYx1;IFVx1;LOGISTICSx1  
RESERVE_STAGING_ALLOWED=NO

STAGING_AREA=WEST_STAGING_AREA  
STAGING_AREA_BOUNDS=X[280,900];Y[480,1320];TAPERED_POLYGON  
STAGING_MIN_FORMATION_SEPARATION=160

SIMULATION_ACTIVE_DURING_STAGING=NO  
ENEMY_AI_ACTIVE_DURING_STAGING=NO  
COMBAT_ACTIVE_DURING_STAGING=NO  
OBJECTIVE_PROGRESS_DURING_STAGING=NO  
FOW_LEAK_ALLOWED=NO

PLACEMENT_INTERACTION=LMB_FORMATION_MARKER_DRAG;EMPTY_GROUND_DRAG_REMAINS_BOX_SELECT  
INVALID_PLACEMENT_BEHAVIOR=REJECT_AND_RETURN_TO_LAST_VALID_STAGED_POSITION

INITIAL_INTENT_LIMIT=ONE  
INITIAL_INTENTS_ALLOWED=MOVE;ADVANCE;HOLD  
LOGISTICS_ADVANCE_ALLOWED=NO  
HOLD_FIRE_PRESET_ALLOWED=YES

START_BATTLE_EXPLICIT=YES  
START_BATTLE_CONTROL=VISIBLE_HUD_MOUSE_BUTTON;ENTER_OPTIONAL_ALIAS  
QUEUED_ORDERS_EXECUTE_AT_T0=YES

RED_POSTURE_REROLL_ON_REPOSITION=NO  
RED_POSTURE_REROLL_ON_START=NO

RESUPPLY_AVAILABLE_IN_STAGING=NO  
WITHDRAW_AVAILABLE_IN_STAGING=NO

RESTART_RETURNS_TO_STAGING=YES

PLAYER_VALUE_CENTRAL=CENTRAL_TEMPO_AND_CONCENTRATION  
PLAYER_VALUE_NORTH=NORTH_INFORMATION_AND_FOOT_MANEUVER  
PLAYER_VALUE_SOUTH=SOUTH_VEHICLE_MANEUVER_AND_ANGLE

FORMATION_VALUES_CHANGED=NO  
DAMAGE_MATRIX_CHANGED=NO  
ROSTER_CHANGED=NO  
ROUTE_GEOMETRY_CHANGED=NO  
SEED_POSTURE_CHANGED=NO  
SUPPLY_RULE_CHANGED=NO  
OBJECTIVE_RULE_CHANGED=NO  
ADVANCE_RULE_CHANGED=NO  
HOLD_FIRE_RULE_CHANGED=NO  
ENEMY_AI_RULE_CHANGED=NO

## 34. Next action

NEXT_ACTION=IMPLEMENT_BATTLE01_PRE_BATTLE_STAGING_V1  
NEXT_OWNER=WINDOW_02_TECH_ARCHITECTURE  
BLOCKER=NONE
