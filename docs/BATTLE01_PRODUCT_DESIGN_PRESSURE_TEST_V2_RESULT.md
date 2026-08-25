# BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V2_RESULT

TASK_ID=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V2
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
INPUT=docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md
RESULT=PASS
PASS_SCOPE=AUTHORIZE_REVISED_GAMEPLAY_IMPLEMENTATION
FULL_FINAL_ART_PRODUCTION=BLOCKED_PENDING_RUNTIME_PLAYTEST
CORE_DIRECTION=RETAIN

## 1. Plain-language verdict

The revised Battle01 design is now strong enough to implement and test as a game.

The first pressure test failed because several supposed decisions were mathematically or structurally weak: Armor dominated reserve Infantry, ammo could be abundant enough to make Supply irrelevant, RED logistics had no real function, route choice was too close to path-length selection, and deterministic fixed deployment made Recon increasingly memorized.

The V2 contract closes those design holes with one coherent structure rather than adding unrelated systems:
- role-target effectiveness makes unit roles non-interchangeable;
- capture and contest are separated so heavy firepower cannot solve ground control by itself;
- authored seeded RED postures preserve deterministic AI while making reconnaissance useful across runs;
- route identities are created through navigation/access/LOS geometry rather than buffs;
- ammo is reduced enough for logistics to matter but not made a mandatory scripted stop;
- RED logistics gains real finite resupply value;
- reserve Infantry and Armor now solve different states;
- Resupply and other actions become commander-level intents instead of parking micro.

This is a design PASS, not proof that the numbers are already perfectly balanced. The next requirement is implementation plus real play evidence.

## 2. Recurring 20-60 second decision loop

The revised loop is credible:

OBSERVE -> choose local intent -> commit -> pay positional/time/ammo cost -> enemy response/new intel -> reassess.

Examples:
- Recon identifies a Village Screen posture: player may exploit Central tempo before RED repositions, send Infantry through village foot links, or keep IFV/Recon together and probe safely.
- Player captures Bridgehead with Infantry badly damaged: reserve Infantry can restore ground-control redundancy, while reserve Armor can instead prepare for heavy open fighting; neither answer is universally correct.
- IFV is low ammo during a counterattack: continue pressure, withdraw, or issue RESUPPLY. Each gives up something real.

RESULT=PASS

## 3. Recon replay-value test

Previous failure: fixed home anchors eventually made Recon a memorized opening script.

V2 test:
- three authored RED postures use the same roster/map but shift screen/reserve/support locations;
- posture selection is seeded and reproducible;
- moment-to-moment AI remains deterministic and may not react to hidden BLUE state;
- Recon's long detection range can reveal which screen and reserve geometry is active before the main force commits.

The player can learn the posture set, but cannot safely assume which posture is active without observation. This is the desired form of mastery: learn possibilities, then read the current battlefield.

RESULT=PASS

## 4. Three-route test

### Central
Best when tempo, vehicle concentration and logistics turnaround matter. Main cost is predictable exposure at the bridge choke.

### North
Best when information, Infantry ground control and broken-LOS maneuver matter. Foot links usable by Recon/Infantry create a real access difference rather than a cosmetic route.

### South
Best for vehicle maneuver and later rear/logistics/Industrial pressure. Cost is initial travel time and temporary loss of concentration.

Important runtime requirement:
South must provide a real firing/staging or later rear-access advantage through actual geometry. If implementation reduces South to merely a longer road before converging on the same engagement, the runtime gate must fail route identity even though the paper design passes.

RESULT=PASS_WITH_RUNTIME_GEOMETRY_PROOF_REQUIRED

## 5. Unit-role and combined-arms test

V2 avoids a complex armor simulation while creating non-interchangeable roles.

Recon:
- strongest information reach;
- poor armored-target efficiency;
- cannot capture/contest.

Infantry:
- ground-control role;
- can use North foot-access geometry;
- weak against heavy armor without support.

IFV:
- active mobile anti-soft/fire-support role;
- captures/contests;
- useful but not efficient enough against heavy armor to replace Armor.

Armor:
- strongest vehicle/heavy-fire intervention;
- can contest/defend;
- cannot establish objective ownership;
- cannot use North foot links.

Logistics:
- no combat/capture role;
- finite ammunition recovery becomes strategically valuable.

The role-effectiveness matrix is intentionally small, deterministic and player-explainable.

RESULT=PASS

## 6. Reserve dominance test

Old state:
Armor had 2.8x Infantry HP, about 1.93x DPS and over 2x theoretical ammo damage for only a movement-speed penalty, so Armor was likely the dominant reserve.

V2 state:
Armor still provides superior heavy direct fire, but cannot capture ownership and has more restricted access in North complex terrain. Infantry is faster, can capture and can use foot access.

Reproducible Infantry-better state:
- player's original Infantry is destroyed/crippled;
- IFV is damaged or needed elsewhere;
- Bridgehead/Industrial ownership must be established or North village access is decisive.

Reproducible Armor-better state:
- player retains at least one healthy capture-capable Infantry/IFV;
- RED Armor/reinforcement is the decisive threat in Central/South/open Industrial space.

Neither unit is universally better under the revised objective/terrain rules.

RESULT=PASS

## 7. Logistics pressure test

V2 active BLUE base theoretical ammunition damage before role multipliers is approximately:
- Recon: 18 x 8 = 144
- Infantry: 24 x 14 = 336
- IFV: 28 x 24 = 672
- total = 1152

RED five-combat-Formation HP remains approximately 860.

1152 is intentionally above 860 so a skilled efficient run is not forced through Supply, but it is far below the old 1976 budget and role mismatch against armor reduces effective damage further.

Therefore the design can produce both:
- a strong run that preserves ammo and finishes without resupply;
- a costly/poorly matched fight where a finite Supply decision materially changes the endgame.

RED Supply now restores actual finite ammunition, so a South/rear penetration can reduce enemy sustain rather than merely kill a harmless truck.

Remaining risk:
exact capacities and thresholds cannot be proven from paper arithmetic alone. Runtime play must tune them without breaking the design intent.

RESULT=PASS_FOR_IMPLEMENTATION_AND_TUNING

## 8. Commander-workload test

The active force remains small: four starting Formations plus one possible reserve.

V2 removes the largest new micro risk by making RESUPPLY an intent rather than requiring the player to park two units inside a small radius manually.

MOVE/ADVANCE/HOLD/HOLD FIRE/WITHDRAW/RESUPPLY/STOP is a compact intent vocabulary. Routine waypoint following, spacing, local bounded engagement and rendezvous execution belong to Formation logic. Direct player input overrides automation.

This preserves the battlefield-commander fantasy instead of turning logistics/navigation into unit babysitting.

RESULT=PASS

## 9. Opening and replay test

V2 adds fixed-roster staging, not a purchase economy.

Three materially different opening plans are now supportable:

### OPENING A — CENTRAL TEMPO
IFV + Infantry concentrate toward bridge, Recon probes ahead, Supply remains short-turnaround rear support.
Good against a defense posture whose screen is displaced North/South.
Risk: strongest exposure to Bridge Lock.

### OPENING B — NORTH INFORMATION/GROUND CONTROL
Recon + Infantry exploit village foot geometry while IFV supports on streets/central cross-link.
Good for reading/turning a Central-heavy posture and protecting capture capability.
Risk: slower heavy vehicle support.

### OPENING C — SOUTH MANEUVER
IFV/Recon or later Armor use broad southern space to create a different angle and preserve vehicle mobility, with the option to pressure rear/logistics/Industrial approach later.
Good when the north/central defense is dense.
Risk: gives up initial tempo and concentration.

Because RED posture varies and each route interacts differently with unit roles, one solved opening is no longer guaranteed to dominate on design grounds.

RESULT=PASS_WITH_RUNTIME_PROOF_REQUIRED

## 10. New-complexity audit

The revision does NOT add:
- hit chance;
- critical hits;
- random penetration;
- detailed armor facings/components;
- morale/suppression;
- fuel;
- economy/production;
- new unit families;
- strategic map;
- random moment-to-moment AI tactics.

New concepts are limited to:
- one small target-class multiplier table;
- capture vs contest distinction;
- three authored pre-match defense postures;
- route-access identity;
- actual RED finite resupply;
- intent-level commands.

This is an acceptable complexity increase because each new rule directly closes a pressure-test failure.

RESULT=PASS

## 11. What remains unproven

This design pass does NOT prove:
- exact ammo capacities are final;
- role multipliers are perfectly balanced;
- South route geometry is sufficiently valuable in runtime;
- AI postures feel distinct enough when rendered and played;
- command automation feels responsive rather than intrusive;
- combat has final audiovisual satisfaction;
- final target-image visual quality.

Those require implementation and player-facing runtime validation.

## 12. Gate

DESIGN_GATE=PASS
REVISED_GAMEPLAY_IMPLEMENTATION=AUTHORIZED
FULL_FINAL_ART_PRODUCTION=NOT_YET_AUTHORIZED

Authorized next work:
- implement revised Battle01 gameplay rules inside the existing 3D-backed real runtime;
- preserve the current product scope and roster;
- then run a real playable product/decision gate before committing to full final-art production.

Implementation must not silently tune away the design relationships above. Balance tuning is allowed only when it preserves the intended role, route, logistics and reserve tradeoffs.
