# BATTLE01_ENEMY_AI_CONTRACT_V2

TASK_ID=DESIGN_AND_FREEZE_BATTLE01_ENEMY_AI_CONTRACT_V2  
OWNER_WINDOW=WINDOW_01_GAME_DESIGN  
STATUS=FROZEN_FOR_IMPLEMENTATION  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_BASE=724ad4b6b18de2769dd37c4cec7aada0846b1871  
NO_NEW_UNIT=YES  
NO_NEW_ECONOMY=YES  
NO_NEW_STRATEGIC_LAYER=YES  
NO_OMNISCIENT_AI=YES  
NO_RANDOM_TACTICAL_DECISIONS=YES  
NO_SCOPE_EXPANSION=YES

## 0. Authority and scope

This contract defines the minimum playable enemy tactical AI required for the current Battle01 Vertical Slice. It is a product-behavior contract, not a required code architecture.

It inherits:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/BATTLE01_VERTICAL_SLICE_SPEC_V1.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/audits/BATTLE01_FORMAL_COMBAT_ROSTER_RUNTIME_QA_GATE_V1.md`
- the already implemented Battle01 Formation, Recon/Contact, LOS and Navigation rules

The formal enemy roster remains exactly:

- RED INF-01: Infantry
- RED INF-02: Infantry
- RED ARMOR-01: Armor / Main Battle Tank role
- RED SUPPLY-01: Supply Truck / Logistics role
- dormant RED REINFORCEMENT INF-01: Infantry
- dormant RED REINFORCEMENT ARMOR-01: Armor

No additional enemy Formation may be created by this contract.

## 1. AI PRODUCT INTENT

AI_STYLE=DEFENSIVE_WITH_LOCAL_COUNTERATTACK

The Battle01 enemy should feel like a small tactical force defending prepared ground, not a passive shooting gallery and not an omniscient rush AI.

Player-facing intent:

1. Reconnaissance should reveal useful tactical structure: where the main infantry defense is, that a second infantry element screens a flank, that armor is being held as local reserve, and that logistics sits behind the combat line.
2. A frontal rush into the Central Bridgehead should tend to meet layered resistance: infantry contact first, then armor intervention when the threat becomes confirmed or the objective is under pressure.
3. A flank should produce a real benefit: fewer defenders should be immediately present, the player may expose or threaten RED SUPPLY-01, and the enemy must spend time repositioning instead of instantly knowing and countering the maneuver.
4. A flank is not a free win after discovery. Once legitimately detected and confirmed, the AI may shift one appropriate responder and later the armor reserve toward the threatened sector.
5. Delay increases pressure deterministically. At the reinforcement timing gate, the dormant Infantry and Armor become available and reinforce the defense/counterattack posture; they do not magically path to a hidden player.
6. Pressure level is LOCAL_TACTICAL. The AI should force route choice, reconnaissance, focus fire, withdrawal and timing decisions, but it must not coordinate map-wide perfect encirclements or use hidden information.
7. Important behavior must be readable: defenders return to their sector, armor visibly commits to a threatened direction, supply visibly retreats when endangered, and reinforcements enter through the known enemy rear rather than appearing beside the player.

## 2. INITIAL DEPLOYMENT INTENT

The existing runtime spawn positions are the initial HOME_ANCHOR positions. Window 04 must not redesign the map or roster to satisfy this contract.

### RED INF-01 — Main Defense

ROLE=BRIDGEHEAD_ANCHOR

- Primary responsibility: hold the Central Bridgehead defense sector.
- Default posture: HOLD at/near its existing HOME_ANCHOR.
- It is the least willing initial Formation to leave the bridgehead area.
- It engages confirmed threats that enter its local engagement area and reacts immediately to a player capture attempt on the Central Bridgehead.
- It does not chase a scouting Formation across the map.

### RED INF-02 — Flank Screen / Mobile Support

ROLE=FLANK_SCREEN

- Primary responsibility: watch the non-central approach around its existing HOME_ANCHOR and support the bridgehead when pressure becomes real.
- Default posture: HOLD at its existing HOME_ANCHOR rather than stacking directly on RED INF-01.
- It is the preferred initial responder to a confirmed flank approach that does not yet require the armor reserve.
- It may move to support the Central Bridgehead when the objective is being captured/contested or when RED INF-01 is under confirmed local pressure.

### RED ARMOR-01 — Local Counterattack Reserve

ROLE=LOCAL_COUNTERATTACK_RESERVE

Armor is not treated as merely higher-HP infantry.

- Default posture: HOLD at its existing HOME_ANCHOR behind/adjacent to the infantry line.
- It does not lead the opening search for the player.
- It commits when a confirmed combat threat reaches the bridgehead defense area, an infantry defender is being overmatched locally, or the Central Bridgehead is being captured/lost.
- Its job is to block a breakthrough, add heavy direct fire to the decisive local fight, and then return to reserve once the local threat ends.
- It does not conduct long pursuit beyond the defensive leash.

### RED SUPPLY-01 — Rear Support / Survival

ROLE=REAR_SUPPORT

- Default posture: SUPPORT_HOLD at its existing initial position behind the combat line.
- It never captures, contests or attacks.
- It never chooses an enemy as an attack destination.
- It may reposition to remain behind the protected combat group, but it must not automatically follow the armor into the objective core.
- If threatened, survival takes priority over following/support position.

## 3. PERCEPTION / INFORMATION RULES

AI_KNOWLEDGE_MODEL=FOG_LIMITED_SHARED_RED_KNOWLEDGE

The RED side may use only information legitimately produced by RED observation plus information about its own units and the objective it is defending.

### 3.1 Always-known information

RED may always know:

- its own Formation positions, life/death and current orders/state;
- the current state of the Central Bridgehead;
- whether RED SUPPLY-01 is taking damage;
- whether one of its own Formations is taking damage or has died;
- reinforcement timer/state.

### 3.2 Enemy intel states

RED uses the same product semantics as the existing Battle01 intel model:

- UNSEEN
- CONTACT
- CONFIRMED
- LAST_KNOWN

The implementation may use a RED-specific knowledge helper; it must not read the player's hidden world truth.

### 3.3 Detection semantics

For RED knowledge:

- A BLUE Formation may be detected only by a living RED observer using that observer's existing `detection_range` and current valid LOS/visibility rules.
- Continuous legitimate detection for `0.75s` promotes CONTACT to CONFIRMED, matching the current Battle01 contact confirmation intent.
- A BLUE Formation firing while legitimately observable may be immediately exposed as CONFIRMED for `2.0s`, matching the current firing-exposure intent.
- When all legitimate RED observation is lost, a previously CONTACT/CONFIRMED BLUE Formation becomes LAST_KNOWN at its last legitimately observed position.
- LAST_KNOWN is static. It must not update from the hidden live position.

### 3.4 What each intel state authorizes

UNSEEN:
- no target selection;
- no movement toward the hidden player;
- no route choice based on hidden player position.

CONTACT:
- indicates presence only;
- may raise alert/readiness;
- does not authorize direct fire;
- does not authorize precise pursuit of the hidden current position;
- may cause a defender to prepare/recenter on its own assigned defense anchor if the contact is inside the bridgehead defense area.

CONFIRMED:
- exact currently observed position may be used while confirmation remains valid;
- direct combat targeting is allowed;
- bounded intercept/pursuit is allowed under the engagement and leash rules below.

LAST_KNOWN:
- may authorize one bounded investigation to the frozen last-known point;
- may not be continuously refreshed from world truth;
- after the bounded investigation ends without reacquisition, the Formation returns to its defensive assignment.

### 3.5 RED information sharing

A legitimately obtained CONTACT / CONFIRMED / LAST_KNOWN record may be shared among the small RED tactical force. Sharing does not make hidden information visible: only the last legitimate state/position is shared.

This is the minimal coordination assumption for Battle01 and does not introduce a strategic command layer.

## 4. BEHAVIOR MODEL

AI_STATE_COUNT=7

Common state names are frozen as:

1. HOLD
2. MOVE
3. ENGAGE
4. INVESTIGATE
5. RETURN
6. SUPPORT
7. EVADE

Combat Formations use HOLD / MOVE / ENGAGE / INVESTIGATE / RETURN.  
RED SUPPLY-01 uses SUPPORT / MOVE / EVADE / RETURN.  
No behavior tree, GOAP framework or ML policy is required.

### 4.1 HOLD

ENTRY:
- combat Formation reaches HOME_ANCHOR or assigned defense destination;
- RETURN completes;
- local threat has ended.

BEHAVIOR:
- remain in defensive sector;
- observe using legitimate perception;
- attack a CONFIRMED valid hostile already in weapon range;
- do not move toward CONTACT-only or UNSEEN enemies.

PRIORITY:
- objective defense > local confirmed threat > flank alert > idle.

EXIT:
- objective pressure / confirmed local threat -> MOVE or ENGAGE;
- confirmed target already in weapon range -> ENGAGE.

INTERRUPT:
- taking damage from a legitimately identified target;
- objective capture/contest/loss event;
- death of an assigned defender requiring local coverage.

### 4.2 MOVE

ENTRY:
- a valid defense, intercept, reinforcement or support destination is assigned.

BEHAVIOR:
- use existing Battle01 Navigation to move to the mission destination;
- do not use hidden player position to update the destination.

EXIT:
- destination reached -> HOLD / SUPPORT;
- valid CONFIRMED target enters combat conditions -> ENGAGE;
- mission becomes invalid -> RETURN.

INTERRUPT:
- higher-priority objective emergency;
- supply survival emergency for RED SUPPLY-01.

### 4.3 ENGAGE

ENTRY:
- a valid CONFIRMED enemy is in weapon range; or
- bounded movement can bring a currently CONFIRMED target into weapon range without violating the pursuit leash.

BEHAVIOR:
- use existing combat rules and combat constants;
- focus only on legitimate CONFIRMED targets;
- make no armor-penetration, suppression, morale or hidden-HP calculations.

EXIT:
- target destroyed -> reassess;
- target loses CONFIRMED status -> INVESTIGATE if eligible, otherwise RETURN/HOLD;
- pursuit leash would be exceeded -> RETURN/HOLD;
- objective emergency requires a higher-priority target -> retarget deterministically.

INTERRUPT:
- Central Bridgehead capture emergency takes priority over non-objective chase.

### 4.4 INVESTIGATE

ENTRY:
- an ENGAGE/MOVE target changes from CONFIRMED to LAST_KNOWN;
- the last-known point is within the allowed local defense/pursuit bounds.

BEHAVIOR:
- travel once toward the frozen LAST_KNOWN position;
- do not update the point unless the target is legitimately reacquired;
- maximum investigation duration from state entry: `4.0s`.

EXIT:
- target reacquired as CONFIRMED -> ENGAGE;
- reach last-known point -> RETURN;
- 4.0s expires -> RETURN;
- objective emergency -> MOVE/ENGAGE toward objective mission.

INTERRUPT:
- confirmed higher-priority threat in the objective core.

### 4.5 RETURN

ENTRY:
- chase/investigation ends;
- temporary support/counterattack mission ends;
- no valid local threat remains.

BEHAVIOR:
- path back to the Formation's HOME_ANCHOR or current assigned reserve/support anchor.

EXIT:
- anchor reached -> HOLD / SUPPORT;
- legitimate higher-priority threat appears -> MOVE/ENGAGE.

### 4.6 SUPPORT

SUPPLY_ONLY=YES

ENTRY:
- RED SUPPLY-01 is not threatened and has a valid support relationship.

BEHAVIOR:
- remain at rear support position;
- protected Formation priority is RED ARMOR-01 if alive, otherwise nearest living RED Infantry;
- only reposition if the protected Formation has moved more than `600` world units from the truck and a safe trailing destination can be found;
- desired trailing standoff is approximately `400` world units behind the protected Formation relative to RED SUPPLY-01's HOME_ANCHOR;
- do not enter a radius of `300` world units around the Central Bridgehead center as part of normal following;
- no automatic resupply mechanic is created by this contract; if an already-authorized supply transfer interaction exists at implementation time, Window 04 may invoke it without changing these positioning/survival rules.

EXIT:
- threat condition -> EVADE;
- follow reposition required -> MOVE.

### 4.7 EVADE

SUPPLY_ONLY=YES

ENTRY when any is true:
- RED SUPPLY-01 takes damage;
- a CONFIRMED BLUE Formation is within `500` world units;
- the current support destination would move the truck toward a confirmed threat.

BEHAVIOR:
- cancel forward support movement;
- move away from the nearest CONFIRMED threat using the existing walkable navigation topology;
- retreat movement is capped to a local reposition of up to `400` world units per evade decision;
- if no confirmed threat position is currently available, return toward the truck HOME_ANCHOR rather than guessing the hidden player position;
- never enter the objective core to evade.

EXIT:
- no CONFIRMED threat within 500 world units and no damage received for `3.0s` -> RETURN/SUPPORT.

## 5. DECISION UPDATE TIMING

AI_DECISION_INTERVAL=0.25s_LOGICAL_MAX

The AI must reconsider normal decisions at least every 0.25 seconds of game time, or equivalently through deterministic event-driven updates that are no slower in observable behavior.

Immediate reassessment events:

- enemy becomes CONFIRMED;
- target dies;
- target becomes LAST_KNOWN;
- Central Bridgehead begins capture/contest, changes ownership/state, or is lost;
- RED Formation takes damage or dies;
- reinforcement activation;
- RED SUPPLY-01 enters EVADE condition.

Frame rate must not change target-priority or randomize state transitions.

## 6. ENGAGEMENT RULES

### 6.1 Who may actively engage

- RED INF-01: yes, primarily inside bridgehead defense mission.
- RED INF-02: yes, local flank/bridgehead support.
- RED ARMOR-01: yes, when reserve commitment conditions are met.
- RED SUPPLY-01: no.

### 6.2 Target priority

Target selection must be simple and deterministic.

Priority order:

1. CONFIRMED BLUE capture-capable/combat Formation currently inside the Central Bridgehead objective area.
2. CONFIRMED BLUE Formation currently damaging or directly engaging this RED Formation.
3. CONFIRMED BLUE combat Formation threatening the Central Bridgehead defense area.
4. CONFIRMED BLUE combat Formation threatening RED SUPPLY-01, when objective emergency is not higher priority.
5. nearest remaining CONFIRMED BLUE Formation inside the current local mission area.

No target priority may use hidden exact HP, hidden ammo, a hard-coded counter table, armor penetration or player input information.

Tie break:

- shorter path/straight-line distance as appropriate to the existing movement/combat API;
- if still equal, stable Formation identity/display name order.

RANDOM_TARGET_SELECTION=NO

### 6.3 Pursuit leash

MAX_ACTIVE_PURSUIT_DISTANCE=350_WORLD_UNITS_FROM_ENGAGE_START

A combat Formation may follow a currently CONFIRMED target only if:

- the target remains legitimately CONFIRMED;
- the pursuit has not exceeded 350 world units from the point where the current ENGAGE pursuit began;
- the pursuit does not require abandoning an active Central Bridgehead emergency;
- the resulting destination remains on a valid existing navigation path.

When the limit is reached, the Formation stops pursuit and returns/recenters even if the player continues baiting it.

CROSS_MAP_PURSUIT=NO

### 6.4 Lost target

CONFIRMED -> LAST_KNOWN:

- one INVESTIGATE attempt is allowed if the frozen last-known point is inside the local pursuit/defense bounds;
- otherwise immediately RETURN/HOLD;
- no repeated last-known chain without a new legitimate CONFIRMED observation.

## 7. OBJECTIVE DEFENSE

PRIMARY_OBJECTIVE=CentralBridgehead

The Central Bridgehead is the decisive local AI anchor for this contract.

### 7.1 Mandatory defense conditions

The objective becomes an emergency when any is true:

- a CONFIRMED BLUE capture-capable Formation is inside the objective area;
- the objective reports active player capture/contest;
- the objective has been lost to the player.

### 7.2 Response allocation

- RED INF-01: always prioritizes objective defense over pursuing a non-objective target.
- RED INF-02: supports if not already containing a separate confirmed flank threat of equal/higher immediate relevance.
- RED ARMOR-01: commits as local counterattack reserve when the objective is under confirmed capture pressure or has been lost.
- RED SUPPLY-01: never enters the objective to contest.

### 7.3 Leaving the defense area

Combat Formations may temporarily leave their HOME_ANCHOR for:

- a bounded confirmed engagement;
- one bounded LAST_KNOWN investigation;
- flank interception;
- objective counterattack;
- return/reposition.

They may not leave for indefinite scouting or hidden-player search.

### 7.4 Recovery after breakthrough

After the objective emergency ends:

- surviving combat Formations finish any immediate in-range CONFIRMED engagement;
- then RETURN to their assigned HOME/defense anchors;
- armor returns to reserve rather than remaining permanently at the furthest chase point.

This reset is mandatory to prevent a single bait unit from permanently emptying the defense.

## 8. ARMOR ROLE CONTRACT

ARMOR_ROLE=RESERVE_FIREPOWER_AND_BREAKTHROUGH_BLOCKER

RED ARMOR-01 commits when at least one condition is true:

1. Central Bridgehead is under active player capture/contest.
2. Central Bridgehead is lost to the player.
3. A CONFIRMED BLUE combat Formation is inside the bridgehead defense area and an infantry defender is already engaged or has been destroyed.
4. A confirmed flank breakthrough threatens the rear/support area and no higher-priority bridgehead emergency exists.

Armor does not respond to CONTACT-only by chasing the contact point.

Armor returns to reserve after the local threat is destroyed, lost beyond pursuit rules, or the objective defense stabilizes.

## 9. INFANTRY ROLE CONTRACT

RED INF-01=MAIN_DEFENDER  
RED INF-02=FLANK_SCREEN_AND_SUPPORT

They must not simply occupy the same destination by default.

- INF-01 stays centered on the bridgehead defense responsibility.
- INF-02 may respond laterally to a confirmed flank contact and may reinforce the bridgehead when objective pressure becomes real.
- If simultaneous confirmed threats appear from different directions, INF-01 stays objective-oriented while INF-02 takes the nearest non-objective local threat; Armor remains reserved for the objective emergency/highest breakthrough threat.

No squad-level formation system is added.

## 10. SUPPLY TRUCK BEHAVIOR CONTRACT

CAN_ATTACK=FALSE  
CAN_CAPTURE=FALSE  
CAN_CONTEST=FALSE  
DEFAULT_STATE=SUPPORT

RED SUPPLY-01 must behave as a valuable rear support asset rather than a front-line blocker.

- It does not path to enemy positions.
- It does not follow a combat Formation into the Central Bridgehead core.
- It remains behind the combat line and moves only for support spacing or survival.
- When attacked/flanked, it uses EVADE and may be lost if the player successfully penetrates the rear; the AI is not required to make it invulnerable.
- A nearby combat Formation may respond to a CONFIRMED supply threat only if doing so does not abandon an active objective emergency and the responder remains inside its normal bounded engagement logic.

Destroying or forcing away RED SUPPLY-01 is intended to be a legitimate flank reward, not something the AI prevents through omniscient retreat.

## 11. REINFORCEMENT CONTRACT

Existing dormant force only:

- RED REINFORCEMENT INF-01 x1
- RED REINFORCEMENT ARMOR-01 x1

REINFORCEMENT_ACTIVATION_RULE=EARLIEST_OF_FIXED_TIME_OR_OBJECTIVE_LOSS

Activation occurs at the first of:

1. `150.0s` from Battle01 combat start; or
2. the first confirmed loss/capture of the Central Bridgehead by the player.

Activation is one-shot and deterministic.

No reinforcement is activated because of a hidden player's exact location.

### 11.1 Reinforcement tasks

Reinforcement Infantry:

- move from the existing authorized dormant/rear spawn into the bridgehead defense network;
- if the objective is currently under player pressure/lost, move to contest/support the Central Bridgehead;
- otherwise occupy/reinforce the secondary defensive position rather than chasing the player.

Reinforcement Armor:

- if the objective is under pressure/lost, move as a counterattack reserve toward the Central Bridgehead;
- otherwise stage behind the defense as an additional reserve and HOLD until a legitimate commitment condition occurs.

If the player simply waits beyond 150s, the enemy defense becomes materially stronger, creating pressure without an all-map attack.

## 12. ROUTE AWARENESS

Allowed existing route families:

- Central
- North
- South

No new navigation system is authorized.

### 12.1 Default movement

For HOME return, objective response, support movement and normal local intercept, use the existing Battle01 navigation path to the current legitimate destination.

### 12.2 Route choice

- Default: shortest valid existing navigation path to the authorized mission destination.
- A legitimately observed flank threat may cause RED INF-02 or Armor to intercept using the route family nearest the last legitimate CONFIRMED/LAST_KNOWN position when that route is valid.
- If the preferred route is invalid/blocked, select the next shortest valid existing path.
- Equal-cost/tie behavior must be deterministic; preferred tie order is `Central -> North -> South`.

No road-speed multiplier, hidden flank score, random route pick or strategic path planner is added.

ROUTE_CROSSING_FOR_REACQUISITION=ONLY_WHEN_SUPPORTED_BY_CURRENT_LEGITIMATE_MISSION

The AI may cross between the connected route families to reach a valid objective/intercept/return destination. It may not roam route-to-route searching for an unseen player.

## 13. ANTI-EXPLOIT CONTRACT

### 13.1 Recon bait / infinite kiting

- CONTACT-only does not authorize chase.
- CONFIRMED chase is capped by the 350-unit pursuit leash.
- LAST_KNOWN gets one bounded investigation, then RETURN.

EXPECTED_RESULT: one scout cannot pull the entire RED defense permanently away from Central Bridgehead.

### 13.2 Contact then escape

- AI remembers only the legitimate LAST_KNOWN point.
- Investigation ends after arrival or 4.0s.
- No hidden tracking after loss.

### 13.3 Flank bypass

- If the flank remains unseen, AI does not cheat-react.
- Once legitimately CONFIRMED, INF-02 is preferred first local responder; Armor may commit if the flank becomes a breakthrough/rear threat.
- The player still gains time/position from successful concealment.

### 13.4 Player waits far from objective

- Initial force remains defensive and does not launch a full-map hunt.
- At 150s, dormant reinforcements activate and strengthen the defense/reserve posture.

### 13.5 Player attacks Supply Truck

- Supply evades only from legitimate damage/CONFIRMED threat information.
- At most the locally appropriate combat defender peels off unless the objective emergency has higher priority.
- Successful rear penetration can still kill the truck.

### 13.6 Simultaneous approaches

Deterministic allocation:

- INF-01 protects Central Bridgehead.
- INF-02 handles the nearest legitimate flank/local non-objective threat.
- Armor handles the objective emergency or highest confirmed breakthrough threat.
- Reinforcements follow their role contracts after activation.

No random splitting or perfect global focus fire.

## 14. BATTLE TEMPO

These are product phases, not mandatory code states.

### EARLY — Read the defense

Intent:
- RED holds prepared positions rather than rushing BLUE.
- Player reconnaissance can reveal the defensive shape and choose Central/North/South approach.
- CONTACT alone creates alertness but not omniscient chase.

### MID — Local reaction

Triggered by legitimate CONFIRMED contact and objective approach.

Intent:
- Infantry engages locally.
- INF-02 may shift to flank pressure.
- Armor remains reserve until a meaningful threat appears.
- Player can exploit route choice and force enemy repositioning.

### PRESSURE / REINFORCEMENT

At 150s or early objective loss:

- dormant Infantry/Armor activate;
- defense becomes denser or a visible local counterattack forms;
- no hidden-player homing behavior.

### ENDGAME — Final contest

When the bridgehead is under sustained decisive pressure / lost:

- available defenders prioritize the objective;
- Armor and activated reinforcements may counterattack locally;
- Supply remains survival/support oriented;
- defenders still obey information and pursuit limits.

The AI must avoid both extremes:

- opening static targets that never react;
- opening full-force rush toward the player.

## 15. DETERMINISM

RANDOMNESS_ALLOWED=NO

The following must be deterministic for the same initial state and player actions:

- state transitions;
- target priority and tie-breaking;
- responder allocation;
- pursuit termination;
- LAST_KNOWN investigation termination;
- reinforcement activation;
- route tie-breaking;
- return destinations;
- supply threat response choice.

No random delays, random patrols, random target choice, random route selection, random retreat direction or random aggression personality.

## 16. IMPLEMENTATION_FREEDOM

Window 04 / Codex may freely choose engineering details that do not alter the frozen observable behavior, including:

- whether AI decisions run from `_process`, `_physics_process`, timers, signals or a hybrid;
- Node organization and script ownership;
- helper functions and local classes;
- signal wiring;
- timer implementation;
- target/intel caches;
- typed dictionaries/enums/resources used internally;
- how HOME_ANCHOR and mission destinations are stored;
- how the existing navigation API is wrapped;
- exact debug marker formatting beyond required semantic markers;
- focused test hooks and CI-only scenario setup;
- deterministic safe local thresholds needed only for numerical tolerance/path arrival and not visible as new gameplay rules.

Window 04 / Codex may not use implementation freedom to:

- add new enemy Formations;
- change Formation combat constants;
- add armor/penetration/suppression/morale systems;
- give RED world-truth player locations;
- add strategic map logic;
- add random tactics;
- expand the Battle01 map;
- silently change objective, victory, recon or navigation product rules.

## 17. ACCEPTANCE_CONTRACT

Acceptance is based on observable product behavior, not a required internal architecture.

### A. Opening behavior

SCENARIO:
- Start Battle01 and do not expose BLUE immediately.

EXPECTED_BEHAVIOR:
- INF-01 holds main bridgehead defense.
- INF-02 holds separate flank-screen position.
- Armor holds reserve rather than charging.
- Supply remains rear/support.
- No RED unit paths directly to hidden BLUE.

### B. First CONTACT

SCENARIO:
- BLUE enters RED detection but does not remain confirmed long enough, or generates CONTACT without CONFIRMED.

EXPECTED_BEHAVIOR:
- RED may become alert/recenter defensively.
- No direct fire at CONTACT-only.
- No precise chase to the hidden live player position.

### C. CONFIRMED player

SCENARIO:
- A BLUE Formation remains legitimately observed until CONFIRMED.

EXPECTED_BEHAVIOR:
- appropriate local RED combat Formation may engage/intercept.
- target selection follows frozen priority.
- unrelated defenders do not all abandon their sectors without objective need.

### D. Player leaves LOS/detection

SCENARIO:
- A currently engaged BLUE target breaks legitimate observation.

EXPECTED_BEHAVIOR:
- RED stops live tracking.
- target becomes LAST_KNOWN at the last observed position.
- no movement follows the hidden true position.

### E. LAST_KNOWN

SCENARIO:
- RED has a valid LAST_KNOWN point inside local bounds.

EXPECTED_BEHAVIOR:
- at most one bounded INVESTIGATE move occurs.
- target reacquisition can return to ENGAGE.
- without reacquisition, investigation ends at point/4s and RED returns.

### F. Player attempts to bait defenders from objective

SCENARIO:
- A scout repeatedly enters confirmation then retreats away from Central Bridgehead.

EXPECTED_BEHAVIOR:
- pursuit stops at the frozen bound.
- defenders return/recenter.
- a single unit cannot permanently empty the bridgehead defense.

### G. Player begins objective capture

SCENARIO:
- legitimate player unit begins capturing/contesting Central Bridgehead.

EXPECTED_BEHAVIOR:
- INF-01 prioritizes objective defense.
- INF-02 supports when not containing an equal local threat.
- Armor commits as local reserve.
- Supply does not contest.

### H. Armor participation

SCENARIO:
- player produces a confirmed bridgehead breakthrough or objective capture pressure.

EXPECTED_BEHAVIOR:
- Armor leaves reserve and adds heavy local fire/interception.
- Armor does not continue indefinite chase after the local threat ends.
- Armor returns to reserve/defense posture.

### I. Supply Truck threatened

SCENARIO:
- BLUE flanks and legitimately confirms/attacks RED SUPPLY-01.

EXPECTED_BEHAVIOR:
- Supply cancels unsafe forward follow and EVADES.
- It never attacks/captures.
- response uses legitimate threat information only.
- player can still destroy the truck through a successful rear penetration.

### J. Reinforcement activation

SCENARIO:
- reach 150s without prior objective loss, and separately test an early objective-loss case.

EXPECTED_BEHAVIOR:
- exactly the existing dormant Infantry x1 and Armor x1 activate once.
- they enter from the existing authorized rear/dormant spawn.
- they reinforce objective/defense missions, not hidden player coordinates.
- no extra Formation appears.

### K. Player flank entry

SCENARIO:
- BLUE uses North or South route and remains unseen initially, then becomes legitimately confirmed.

EXPECTED_BEHAVIOR:
- no pre-detection cheat reaction.
- after confirmation, INF-02 is preferred local responder.
- Armor may shift only if the flank becomes an objective/rear breakthrough threat.
- navigation uses existing route topology.

### L. Victory/Defeat final stage

SCENARIO:
- play into decisive objective/victory state with surviving RED defenders/reinforcements.

EXPECTED_BEHAVIOR:
- surviving combat units prioritize the final local objective contest within this contract.
- Supply remains non-combat support/survival.
- AI continues to obey fog, pursuit and deterministic rules until match completion.
- match end stops further tactical decisions as required by existing Battle01 lifecycle.

## 18. REQUIRED AI RUNTIME SMOKE SEMANTICS

Window 04 may choose exact marker strings, but the delivered high-risk implementation must make the following claims reconstructable from runtime evidence:

- AI initial role/state assignment correct.
- No hidden-player opening chase.
- CONTACT does not authorize direct fire/chase.
- CONFIRMED target can be engaged.
- LOS/detection loss freezes LAST_KNOWN rather than live-tracking.
- LAST_KNOWN investigation is bounded and returns.
- pursuit leash terminates bait chase.
- objective pressure triggers defense/counterattack allocation.
- Armor commits and returns as reserve.
- Supply never attacks/captures and evades legitimate threat.
- North/Central/South navigation remains valid for AI missions.
- reinforcement activates exactly once under both trigger families.
- same scripted scenario produces the same state/target/route decisions.

Recommended semantic markers:

- `FRONTLINE_AI_INIT_PASS`
- `FRONTLINE_AI_CONTACT_LIMIT_PASS`
- `FRONTLINE_AI_CONFIRMED_ENGAGE_PASS`
- `FRONTLINE_AI_LAST_KNOWN_PASS`
- `FRONTLINE_AI_PURSUIT_LEASH_PASS`
- `FRONTLINE_AI_OBJECTIVE_DEFENSE_PASS`
- `FRONTLINE_AI_ARMOR_RESERVE_PASS`
- `FRONTLINE_AI_SUPPLY_SURVIVAL_PASS`
- `FRONTLINE_AI_REINFORCEMENT_PASS`
- `FRONTLINE_AI_ROUTE_RESPONSE_PASS`
- `FRONTLINE_AI_DETERMINISM_PASS`
- `FRONTLINE_ENEMY_AI_SMOKE_PASS`

These names are recommended, not a forced internal architecture. Equivalent telemetry is acceptable if Window 07 can independently reconstruct the acceptance claims.

## 19. AUDIT EVIDENCE EXPECTATION FOR WINDOW 04 / WINDOW 07

ENEMY_AI_RISK=HIGH_RISK_BEHAVIOR_IMPLEMENTATION

Minimum sufficient evidence should normally include:

- START_COMMIT / FINAL_COMMIT;
- focused Git changed-file list and diff sufficient to confirm no scope growth;
- actual Godot 4.7.1 version used;
- core AI runtime smoke covering the important state/intel/objective/supply/reinforcement behaviors;
- key deterministic state/target/route telemetry;
- Navigation / Recon / LOS / Combat / Objective / Victory relevant regressions;
- one or more short runtime captures/screenshots only where logs cannot persuasively show the player-facing behavior, especially bait-return, armor reserve commitment, supply retreat or flank reaction.

Do not require by default:

- full project ZIP;
- unrelated full logs;
- all-system regression unrelated to the AI blast radius;
- large duplicate screenshot sets;
- long recordings when a short focused capture proves the claim.

## 20. Freeze result

AI_PRODUCT_INTENT_DEFINED=YES  
BEHAVIOR_MODEL_DEFINED=YES  
PERCEPTION_RULES_DEFINED=YES  
OBJECTIVE_DEFENSE_DEFINED=YES  
INFANTRY_ROLE_DEFINED=YES  
ARMOR_ROLE_DEFINED=YES  
SUPPLY_BEHAVIOR_DEFINED=YES  
REINFORCEMENT_DEFINED=YES  
ROUTE_AWARENESS_DEFINED=YES  
ANTI_EXPLOIT_DEFINED=YES  
BATTLE_TEMPO_DEFINED=YES  
IMPLEMENTATION_FREEDOM_DEFINED=YES  
ACCEPTANCE_CONTRACT_DEFINED=YES  
READY_FOR_WINDOW_04=YES  
BLOCKER=NONE
