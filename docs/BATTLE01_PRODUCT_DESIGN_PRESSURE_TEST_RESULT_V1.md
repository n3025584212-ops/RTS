# BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1

TASK_ID=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1
CONTROL_OWNER=WINDOW_00_CONTROL
DESIGN_DOMAIN=WINDOW_01_GAME_DESIGN
BASE_COMMIT=a197372ab5021a5acb0bb6124d734eb84dc7aa35
RESULT=REVISE
FULL_SCALE_STAGE_2_3_EXPANSION=BLOCKED
CORE_DIRECTION=RETAIN
CURRENT_3D_FOUNDATION=RETAIN
NO_LARGE_ART_PRODUCTION_YET=YES

## 1. Plain-language verdict

Battle01 has a viable core: reconnaissance, route choice, first contact, bridgehead fight, counterattack, preservation, reserve commitment and final objective can form a coherent modern-war command loop.

The current design is not yet strong enough for expensive full 3D gameplay/art closure. Several nominal choices are weak or mathematically dominated, and several systems that are supposed to create pressure currently do not reliably create pressure.

This is a REVISE result, not a direction failure. Keep the commander fantasy, map skeleton, limited-information model, bridgehead-to-industrial progression and 3D runtime foundation. Fix the decision structure before scaling content and art.

## 2. BATTLE01_PLAYER_DECISION_LOOP_V1

Target recurring 20-60 second loop:

1. OBSERVE — receive partial information from Recon, LOS, firing reveals and objective state.
2. FORM A LOCAL INTENT — choose where to concentrate, screen, hold, flank, withdraw or preserve.
3. COMMIT — issue Formation-level intent orders rather than low-level parking/micro.
4. PAY A COST — time, position, ammo, HP exposure, route commitment or reserve commitment.
5. ENEMY RESPONSE / NEW INFORMATION — legitimate RED reaction changes the local problem.
6. REASSESS — continue, redirect, disengage, resupply, reinforce or exploit.

The loop is strong only when more than one option is plausible and the battlefield can invalidate the previous answer.

## 3. BATTLE01_PHASE_BY_PHASE_PRESSURE_TEST_V1

### Opening / deployment — REVISE

Current strength:
- fixed small force keeps command workload manageable.
- West -> North/Central/South topology supports a commander-level opening choice.

Current problem:
- Battle01 product documents still contain stale language around purchase/deployment while the frozen war-flow explicitly has no purchase currency/economy.
- if formations simply start at fixed points and move after the match begins, the opening loses a useful strategic commitment opportunity.

Required direction:
- use a fixed-roster PRE-BATTLE DEPLOYMENT/STAGING phase, not a purchase economy.
- allow placement/grouping inside a bounded West staging zone and pre-issue initial Formation orders.
- this should create initial plan commitment without adding money, tech trees or production.

### Recon / first information — REVISE

Current strength:
- UNSEEN -> CONTACT -> CONFIRMED -> LAST_KNOWN is understandable and supports incomplete information.
- Recon has materially longer detection range.

Current problem:
- the RED starting layout and tactical decisions are fully deterministic with fixed HOME anchors and no tactical randomness.
- after one or two runs, the player can memorize where the defense is, reducing Recon from a discovery tool to a required execution step.

Required direction:
- retain no moment-to-moment tactical RNG.
- add a small set of authored, seeded PRE-MATCH RED DEFENSE POSTURE variants using the same roster and legal map sectors.
- same seed + same player actions remains deterministic.
- Recon should reveal which valid defense posture is active.

### Route choice — REVISE

Current strength:
- Central is shortest, North uses village streets/blockers, South is longest, and route families cross-link.

Current problem:
- current route differences are dominated by path length and LOS blockers.
- without stronger terrain/role consequences, North/South risk becoming visually different ways to reach the same fight.

Required route identities:
- CENTRAL: fastest concentration, bridge choke, most direct exposure, best logistics turnaround.
- NORTH/VILLAGE: slower, broken LOS, strong reconnaissance/infantry maneuver opportunities, harder vehicle geometry, useful lateral access to Central/East.
- SOUTH/MANEUVER: longest initial travel, broad vehicle movement, strongest route to threaten RED rear/logistics or approach Industrial from an unexpected angle.
- blockers must affect real movement/nav as well as LOS where appropriate; route identity cannot be painted scenery only.

### First combat / combined arms — REVISE_REQUIRED

Current strength:
- deterministic fixed damage is readable and easy to debug.

Current problem:
- roles are still largely differentiated by raw HP/range/damage/speed, with no target-class effectiveness.
- this allows units to function as differently sized versions of the same direct-fire object and weakens the combined-arms decision.

Required direction:
- keep deterministic combat; do not add hit chance, crit, random penetration, complex armor simulation or suppression for this gate.
- add a minimal deterministic ROLE-EFFECTIVENESS layer (for example fixed weapon/target classes or fixed per-target-role damage values) so Recon/Infantry/IFV/Armor do not all solve the same target equally well.
- exact balance values require a dedicated combat revision after this product gate.

### Central Bridgehead — KEEP, TUNE

Current strength:
- bridgehead is a real phase hinge: it unlocks Industrial, Reserve and forward rally and triggers RED pressure.
- victory does not occur immediately after bridgehead capture.

Current risk:
- a 15s capture can become passive waiting after defenders are cleared.
- because most combat formations currently capture, the player has little reason to assign a specific formation to secure the point while others reposition.

Required direction:
- separate CAPTURE capability from CONTEST capability.
- all relevant combat formations may deny/contest a point, but only designated ground-control roles should advance ownership.
- recommended initial design candidate: Infantry and Mechanized/IFV capture; Recon scouts; Armor contests/protects but does not by itself establish ownership; Logistics neither captures nor contests.
- this candidate must receive its own rule revision before implementation because it changes frozen capture flags.

### Counterattack — REVISE

Current strength:
- local defensive AI and limited pursuit prevent omniscient all-map rushing.
- counterattack after bridgehead creates a natural preservation decision.

Current problem:
- fixed defenders + fixed reinforcement composition + fixed route priorities make the response highly learnable.
- major counterattack pressure can become a scripted wave rather than a problem the player reads and anticipates.

Required direction:
- authored defense-posture variants should also alter which legal local sector is reinforced first, while preserving fog-limited knowledge and bounded behavior.
- major RED movement must be legible through normal battlefield cues/intel before it becomes unavoidable; no perfect-information warning is required.

### Logistics / withdrawal — REVISE_REQUIRED

Current strength:
- HP is persistent, so withdrawal can genuinely preserve combat power.
- two finite supply charges and interrupted stationary transfer create potential risk.

Critical problem 1 — ammo scarcity is not currently guaranteed to matter:
- theoretical active BLUE ammunition damage before reserve/supply is approximately Recon 320 + Infantry 504 + IFV 1152 = 1976 fixed damage.
- total HP of all five RED combat formations including reinforcements is approximately 860.
- IFV theoretical ammunition damage alone is 1152, greater than the total 860 RED combat HP.
- because combat is deterministic and has no miss system, current ammo counts can allow the battle to end without resupply becoming a real constraint.

Critical problem 2 — RED Supply is currently a fake flank reward:
- AI contract calls RED SUPPLY-01 a legitimate flank reward but does not require it to perform real resupply.
- killing a harmless non-capturing truck therefore may not materially weaken RED combat sustainability.

Critical problem 3 — player Supply risks becoming a parking minigame:
- manually positioning truck and target inside 140 units, stopping both, then waiting four seconds can create maintenance clicks rather than commander-level decisions.

Required direction:
- rebalance ammo so the expected Battle01 combat arc normally creates at least one meaningful resupply/preservation decision, without forcing resupply in every successful run.
- reuse the same finite Supply interaction for RED during legitimate lulls so rear-logistics penetration has a real consequence.
- replace low-level parking with a Formation-level RESUPPLY intent: player chooses which formation deserves supply and accepts time/position risk; units may rendezvous automatically using existing navigation, then still require the vulnerable uninterrupted transfer.
- WITHDRAW remains an intent order that concedes time/position but preserves surviving capability.

### Reserve choice — REVISE_REQUIRED

Current problem:
- current reserve choice is nominally Infantry now vs Armor later, but the raw numbers strongly favor Armor.
- Infantry: HP 100, DPS about 15.6, theoretical ammo damage 504, speed 115.
- Armor: HP 280, DPS 30, theoretical ammo damage 1080, speed 85.
- Armor has 2.8x HP, about 1.93x DPS and over 2x ammunition damage capacity while giving up only mobility.
- without terrain, capture or target-role asymmetry, Armor is likely the dominant answer.

Required direction:
- do not solve this only by arbitrary stat nerfs.
- make Infantry and Armor solve different battlefield problems through the same minimal role/capture/terrain rules: Infantry should be valuable for ground control, complex terrain and objective security; Armor should dominate heavy open direct-fire intervention but carry route/ownership limitations.
- then the single irreversible reserve commitment can become state-dependent rather than a false choice.

### Final Industrial push — REVISE

Current strength:
- requiring both objectives preserves the bridgehead's strategic relevance.

Current problem:
- if route identities and enemy posture do not vary, the final push can collapse into repeating the solved opening with more units.

Required direction:
- Industrial approach must allow at least two materially different viable solutions based on surviving force, reserve choice, RED posture and logistics state.
- South rear/logistics pressure and North complex-terrain maneuver must have actual battlefield consequences, not only longer paths.

## 4. BATTLE01_FAKE_DECISION_AND_BUSYWORK_AUDIT_V1

### Genuine or promising decisions

- continue pressure vs withdraw/preserve after attrition: STRONG CANDIDATE.
- which sector to recon / where to expose the scout: STRONG only if enemy posture can vary.
- hold bridgehead vs immediately exploit east: STRONG if counterattack timing and logistics state differ.

### Currently weak/fake decisions

1. Reserve Infantry vs Armor — LIKELY DOMINATED by Armor under current role model.
2. Supply concentration vs distribution — WEAK if starting ammo is already sufficient to clear the whole roster.
3. Attack RED Supply — WEAK/FAKE if RED does not actually consume supply.
4. North/Central/South route choice — PARTIALLY COSMETIC if route consequences are mostly path length/LOS.
5. Recon opening — BECOMES SCRIPTED once fixed deployment is memorized.

### Busywork risks

- precise manual supply parking.
- repeated individual MOVE corrections caused by lack of Formation-level intent/autonomy.
- watching a cleared 15s capture timer with no concurrent preparation choice.

## 5. BATTLE01_COMMAND_WORKLOAD_AUDIT_V1

Current active command load is healthy in quantity: four active formations plus at most one committed reserve is a reasonable vertical-slice ceiling.

The risk is not unit count; it is order granularity.

Required commander-level command philosophy:

- MOVE — go there.
- ADVANCE / ATTACK MOVE — progress while responding to legitimate confirmed contact.
- HOLD — defend this local position/sector.
- HOLD FIRE — preserve concealment/ambush until released or directly threatened according to frozen rule.
- WITHDRAW — disengage toward a friendly rally/rear intent.
- RESUPPLY — selected formation seeks/receives finite supply without parking micro.
- STOP/CANCEL — clear intent.

Player chooses intent. Formation logic handles routine path-following, spacing, stopping at the order destination and local target engagement rules. Direct player orders always override automation.

Control groups / queued pre-battle orders are quality-of-life candidates; they should not become additional gameplay systems.

## 6. BATTLE01_CROSS_GENRE_MECHANIC_DISTILLATION_V1

### WARNO / large real-time tactics
Useful lesson: AI-assisted Smart Orders / rules-of-engagement style tools reduce micro while keeping the player responsible for sector-level intent.
FRONTLINE translation: Formation intent orders and direct override, not autonomous strategy.

### Broken Arrow / modern combined-arms tactics
Useful lesson: terrain, infiltration, flank pressure and logistics disruption matter when different unit roles exploit them differently.
FRONTLINE translation: make North/Central/South tactically distinct and make RED logistics functional so a rear attack creates a real advantage.

### Company of Heroes / tactical RTS
Useful lesson: player workload can be managed with planning tools rather than reducing tactical depth.
FRONTLINE translation: pre-battle staging/queued initial orders are valuable; optional single-player pause/slow-planning can remain an accessibility/training candidate, not a core Battle01 gate.

### Battlefield / action warfare
Useful lesson: roles must be immediately understandable, and audiovisual/destruction feedback should communicate gameplay consequences rather than exist only as spectacle.
FRONTLINE translation: strong vehicle/formation silhouettes, directional fire/impact feedback, persistent wreck/impact aftermath; full systemic destruction is not required for Battle01.

### Into the Breach / tactical decision clarity
Useful lesson: consequential threats are satisfying when the player can read enough information to make a response before damage becomes unavoidable.
FRONTLINE translation: important RED commitment/counterattack cues should become legible through normal reconnaissance, movement, audio/visual cues and objective pressure; do not give perfect information.

### Darkest Dungeon / preservation and retreat
Useful lesson: retreat is meaningful when it prevents a worse loss but costs progress/time/resources.
FRONTLINE translation: WITHDRAW must concede tempo/position while preserving an irreplaceably damaged formation; never turn retreat into a stat bonus.

### League / high-chaos combat readability
Useful lesson: visuals/audio must preserve hierarchy, make important events more salient, and limit noise.
FRONTLINE translation: muzzle flashes, tracers, explosions and alerts must have priority tiers; combat intensity cannot destroy Formation, objective and threat readability.

## 7. BATTLE01_DESIGN_CHANGES_REQUIRED_V1

P0-1 — ROLE DIFFERENTIATION
Problem: direct-fire formations are too stat-driven.
Change: define minimal deterministic target-role effectiveness + separate capture/contest responsibility.
Affects frozen Combat/Formation/Objective rules: YES.
Scope: ESSENTIAL Battle01 revision; no complex armor simulation.

P0-2 — ROUTE + DEFENSE UNCERTAINTY
Problem: fixed defense and weak route semantics make repeat runs solvable.
Change: three clear route identities + small authored seeded defense-posture set using existing roster/map.
Affects Navigation/AI deployment rules: YES.
Scope: ESSENTIAL; no new map region or unit.

P0-3 — LOGISTICS MUST ACTUALLY BITE
Problem: ammo budget can exceed entire enemy HP pool; RED Supply has no real war-flow value.
Change: ammo-balance pass + RED finite resupply reuse + intent-level player Resupply.
Affects Formation ammo/Logistics/AI support rules: YES.
Scope: ESSENTIAL.

P0-4 — RESERVE CHOICE MUST BE STATE-DEPENDENT
Problem: Armor is numerically dominant over Infantry.
Change: use role/terrain/objective asymmetry to make Infantry and Armor answer different problems; then tune numbers only if still needed.
Affects Reserve/Formation rules: YES.
Scope: ESSENTIAL.

P0-5 — COMMANDER-LEVEL ORDERS
Problem: risk of parking/move micro replacing command decisions.
Change: freeze intent command philosophy and automate routine execution while preserving direct override.
Affects command implementation contract: YES.
Scope: ESSENTIAL.

P1-1 — PRE-BATTLE STAGING
Problem: stale purchase/deployment language and weak opening commitment.
Change: fixed-roster staging zone + initial queued orders; remove purchase implication from Battle01.
Scope: HIGH VALUE; no economy.

P1-2 — COMBAT FEEDBACK HIERARCHY
Problem: technically valid combat can still feel flat/unreadable.
Change: later 3D/VFX/audio stage must distinguish fire classes, impacts, major threats and aftermath while controlling noise.
Scope: REQUIRED FOR FINAL PRODUCT, not a reason to resume large art before P0 rules close.

## 8. BATTLE01_PRODUCT_DESIGN_GATE_V1

RESULT=REVISE

Why not PASS:
- ammo/logistics pressure is not currently guaranteed to exist;
- reserve choice is likely mathematically dominated;
- fixed deterministic deployment undermines replay/recon discovery;
- route choice needs stronger mechanical identities;
- combined-arms roles need more than raw stat differences;
- command granularity risks busywork.

Why not FAIL_DIRECTION:
- the core commander fantasy is coherent;
- incomplete information, bridgehead hinge, local counterattack, preservation and final objective form a valid game structure;
- required revisions can be made using the existing map, roster and 3D foundation without broad scope expansion.

FULL_3D_STAGE_2_3_RESUME=NO

Authorized design work before resume:
1. revise Formation/Combat role differentiation contract;
2. revise Capture/Contest role contract;
3. define route tactical identities and seeded RED defense postures;
4. rebalance ammo/logistics and make RED Supply functional;
5. freeze commander-level command intent set;
6. then run a second pressure test against the revised rules.

## 9. Cleanup / obsolete assumptions identified

- Treat Battle01 "Purchase" as stale for the current no-economy vertical slice; replace with fixed-roster Deployment/Staging where referenced as gameplay truth.
- Do not treat the Indirect Fire/Artillery definition as a required active Battle01 formation merely because it exists in the general FormationDefinition set; adding it now would expand command load before the core loop is proven.
- Do not continue expensive final-art production until this REVISE gate is closed.
