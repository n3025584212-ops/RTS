# BATTLE01_VISUAL_IMPLEMENTATION_SPEC_V2

TASK_ID=FREEZE_BATTLE01_VISUAL_IMPLEMENTATION_SPEC_V2  
OWNER_WINDOW=WINDOW_06_UI_VISUAL  
STATUS=FROZEN_FOR_IMPLEMENTATION  
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
SOURCE_QA_BASE=de3661981fc8eb1dfe19986da2a8c80a883cc609  
NO_GAMEPLAY_RULE_CHANGE=YES  
NO_SCOPE_EXPANSION=YES  
NO_NEW_VISUAL_GAMEPLAY_SYSTEM=YES

## 0. Authority, purpose, and scope

This document freezes the player-visible Battle01 UI, battlefield readability, intel presentation, objective feedback, logistics feedback, reserve decision presentation, command feedback, minimap rules, combat readability, alert priority, prototype cleanup, implementation freedom, and visual QA contract.

It must be read with:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/BATTLE01_VERTICAL_SLICE_SPEC_V1.md`
- `docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md`
- `docs/BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_V1.md`
- `docs/audits/BATTLE01_ENEMY_AI_RUNTIME_QA_GATE_V1.md`
- `docs/audits/BATTLE01_FINAL_INDUSTRIAL_AI_QA_GATE_V1.md`
- `docs/audits/BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_QA_GATE_V1.md`
- current Battle01 runtime implementation at `SOURCE_QA_BASE`.

The visual target assets from Window 08 are PRODUCT DIRECTION / TARGET REFERENCE, not old gameplay authority and not a pixel-lock contract.

Authority for every implementation decision is:

1. current frozen Battle01 gameplay and QA-accepted runtime behavior;
2. player readability and product intent;
3. this visual implementation contract;
4. Window 08 target-image composition and style reference;
5. implementation convenience.

If any target-image detail conflicts with current frozen gameplay, the target-image detail is adapted or discarded. Visual implementation must never reintroduce removed or nonexistent gameplay.

This document does not modify Combat, Enemy AI, Navigation, Recon/FOW, Supply values, Reserve rules, Objective rules, Victory/Defeat rules, or any other gameplay contract.

## 1. Frozen current Battle01 facts the UI must represent

The UI is designed around the QA-accepted Battle01 runtime, not the older mockups.

### 1.1 Player active force

At combat start the player has:

- `BLUE RECON-01`
- `BLUE IFV-01`
- `BLUE INF-01`
- `BLUE SUPPLY-01`

The UI must treat these as Formation-level command objects. It must not imply individual-soldier micro as the primary command layer.

### 1.2 Player reserve

The player reserve pool contains:

- `BLUE RESERVE INF-01`
- `BLUE RESERVE ARMOR-01`

`PLAYER_RESERVE_COMMITMENTS=1`.

The player may choose exactly one after the first complete PLAYER capture of Central Bridgehead. There is no currency, income tick, mining, purchase cost, production queue, tech tree, population cap, factory construction loop, or refund.

### 1.3 Objectives

There are exactly two formal Battle01 objectives:

- `CENTRAL_BRIDGEHEAD` — intermediate tactical hinge; starts AI-controlled; player-capturable from the opening phase.
- `INDUSTRIAL_OBJECTIVE` — final decisive objective; starts AI-controlled and visible but is initially `LOCKED_FOR_PLAYER_CAPTURE`.

Both use `CAPTURE_TIME=15.0s` and `CAPTURE_RADIUS=150`.

Ownership is one of `NEUTRAL / PLAYER / AI`. `CONTESTED` is a separate temporary state.

Supply formations do not capture or contest.

The first complete PLAYER capture of Central:

- permanently unlocks the one player Reserve commitment;
- permanently unlocks Industrial for player capture;
- activates the Bridgehead Forward Rally while Central remains PLAYER-owned and uncontested.

Victory requires Central and Industrial both PLAYER-owned and uncontested at the same time. Central alone never causes Victory.

### 1.4 Supply

Battle01 Supply is:

- `AMMO ONLY`
- range `140` world units
- duration `4.0s` uninterrupted
- Supply Truck charges `2`
- one completed charge restores `50%` of target maximum ammo, capped at maximum
- `HP RESTORE=NO`
- interruption resets progress and consumes no charge.

Supply must never be presented as healing, repair, HP regeneration, a passive aura, or a base resource economy.

### 1.5 Withdraw and rallies

`WITHDRAW / REVERSE` is tactical movement intent only.

It grants no speed, armor, evasion, invulnerability, healing, damage reduction, or other stat bonus.

Formal rally locations:

- `WEST_REAR_RALLY` — always available regroup destination.
- `BRIDGEHEAD_FORWARD_RALLY` — active only while Central is PLAYER-owned and uncontested.

The reserve Formation enters physically from `WEST_REAR_ENTRY` and then behaves as a normal Formation.

### 1.6 Player-facing intel states

The player-visible Recon/FOW language is:

- `UNSEEN`
- `CONTACT`
- `CONFIRMED`
- `LAST_KNOWN`

`CONTACT` is presence without full identity. `CONFIRMED` is legally observed current information. `LAST_KNOWN` is a frozen historical position and must never visually behave like a live tracker.

### 1.7 Current implementation status relevant to UI

At `SOURCE_QA_BASE`, current player input/runtime support includes:

- single selection — IMPLEMENTED
- box / multi-selection — IMPLEMENTED
- MOVE — IMPLEMENTED
- SUPPLY — IMPLEMENTED
- WITHDRAW / REVERSE — IMPLEMENTED
- direct WEST_REAR withdrawal modifier — IMPLEMENTED
- Reserve Infantry commitment — IMPLEMENTED
- Reserve Armor commitment — IMPLEMENTED
- Victory / Defeat / Restart runtime path — IMPLEMENTED

The following final command-language items are frozen visually by this document but are not yet complete player commands in the current runtime and must not be displayed as working buttons until their behavior is formally implemented:

- FAST MOVE — `IMPLEMENTATION_REQUIRED`
- ATTACK MOVE / ADVANCE — `IMPLEMENTATION_REQUIRED`
- HOLD as an explicit player-issued command — `IMPLEMENTATION_REQUIRED`
- HOLD FIRE — `IMPLEMENTATION_REQUIRED`
- STOP / CANCEL as an explicit player-issued command — `IMPLEMENTATION_REQUIRED`

The current player combat binding against the baseline Recon target occurs from legal `CONFIRMED` intel rather than from a complete explicit player ATTACK / ATTACK MOVE command UI. The visual implementation must not fabricate an interactive attack command that the runtime does not accept.

## 2. Product visual principles

Battle01 is a modern-war Formation/Platoon command game. The visual objective is not maximum information density; it is fast command comprehension under pressure.

Frozen principles:

1. `READABILITY BEFORE SPECTACLE`.
2. Battlefield remains the largest visual surface.
3. Healthy, unselected Formations remain visually quiet.
4. Selection, critical state, objectives, legal intel, and current command intent outrank decorative effects.
5. Color is semantic, not ornamental.
6. Faction identity and command intent must not depend on color alone; shape/icon/line style must reinforce meaning.
7. Far zoom is a tactical-symbol mode, not a demand to identify tiny 3D models.
8. UI may summarize gameplay state but may not invent hidden gameplay state.
9. Target-image drama may be preserved only when it does not imply nonexistent mechanics.
10. Debug strings and runtime QA labels are not final-player UI.

## 3. Frozen color and symbol language

The target-image set contains older green-friendly and newer blue-friendly variants. V2 resolves the conflict in favor of the currently accepted Battle01 faction language and command-color separation.

### 3.1 Faction / ownership colors

| Semantic | Frozen visual color | Use |
|---|---|---|
| PLAYER / BLUE | `#4D8CFF` | friendly identity, player ownership, selection family |
| AI / RED | `#FF4D4D` | legally known enemy identity, AI ownership |
| NEUTRAL | `#B0B0B0` | neutral ownership / inactive neutral state |
| CONTESTED | `#FFC857` | contested objective / tactical contention |
| LOCKED | desaturated neutral-blue/gray | unavailable player capture / unavailable decision |
| UNKNOWN / STALE INTEL | desaturated amber-gray | CONTACT / LAST_KNOWN family, differentiated by shape |

### 3.2 Command colors

| Command / feedback | Frozen color | Secondary discriminator |
|---|---|---|
| MOVE | `#6CCB6C` | directional chevrons / route |
| ATTACK intent where formally implemented | `#FF4D4D` | target reticle |
| HOLD | `#4D8CFF` | shield / anchor icon |
| WITHDRAW / REVERSE | `#FFC857` | rearward double-chevron / dashed route |
| SUPPLY | `#4DD0E1` | ammo-box link / transfer progress |
| INVALID | `#FF5544` | X / blocked cursor / concise reason |
| INFO | cool blue-white | info glyph |
| CRITICAL | `#FF5544` | critical triangle / persistent high-priority treatment |

Friendly identity remains BLUE even when a friendly Formation is executing green MOVE or yellow WITHDRAW. Command color is shown in route/destination/order glyphs; faction color remains on the Formation identity marker.

### 3.3 Color-accessibility rule

Every critical semantic state must also have a non-color discriminator:

- BLUE vs RED: faction frame shape + unit-class glyph.
- CONTACT vs CONFIRMED: hollow unknown-contact brackets vs solid identified Formation marker.
- CONFIRMED vs LAST_KNOWN: solid live marker vs dashed/ghost historical marker with age/stale glyph.
- CAPTURING vs CONTESTED: progress arc vs interruption/contest cross-hatch.
- MOVE vs WITHDRAW: forward chevrons/solid route vs rearward double-chevron/dashed route.

## 4. Final HUD information architecture

The final HUD must replace the current developer-text stack with a compact command interface. Exact pixels, node names, and container choices are implementation freedom; the following information zones and priorities are frozen.

### 4.1 Zone A — Mission / Battle State

Purpose: tell the player what phase matters now without a paragraph.

Always-visible compact content:

- current mission intent: secure Central, then secure Industrial while retaining Central;
- Central state chip;
- Industrial state chip;
- explicit Industrial `LOCKED` state before unlock;
- current decisive condition when both objectives matter.

The Mission area must not show the current long prototype sentence. It should use one concise action line plus objective state chips.

Examples of valid concise states:

- `SECURE CENTRAL BRIDGEHEAD`
- `CENTRAL SECURED — RESERVE / INDUSTRIAL UNLOCKED`
- `SECURE INDUSTRIAL — HOLD CENTRAL`
- `INDUSTRIAL CONTESTED`

These are presentation summaries derived from existing state; they do not create new mission states.

### 4.2 Zone B — Selection Summary

Visible when one or more friendly Formations are selected.

Single selection must show:

- Formation name / callsign;
- unit class / role glyph;
- HP current/max with bar;
- ammo current/max if the Formation uses ammo;
- Supply charges if it is a Supply Truck;
- current order;
- critical state indicators such as LOW AMMO / EMPTY / UNDER FIRE / DESTROYED only when applicable;
- contextual command availability.

Supply Truck selection must prioritize `CHARGES x/2` over irrelevant weapon information.

Multi-selection must not concatenate every Formation into one long sentence. It must show a compact Formation-card row/grid with, at minimum:

- faction/class glyph;
- abbreviated callsign;
- HP bar;
- ammo warning state;
- current-order glyph;
- selected state.

A compact aggregate header such as `4 FORMATIONS SELECTED` is allowed, but individual critical states must remain inspectable.

### 4.3 Zone C — Selected Formation Status / Command Area

This is the primary action area for the current selection.

It contains only commands that are actually legal in the current runtime build. Frozen final command slots may exist in implementation code/theme resources, but unfinished commands must not appear as enabled player controls.

Current build player-visible actions:

- MOVE
- SUPPLY when Supply context is valid
- WITHDRAW / REVERSE
- Reserve choice is not a normal Formation command and belongs to the Reserve panel.

Future frozen command visual language is defined in Section 11 and tagged `IMPLEMENTATION_REQUIRED` where necessary.

### 4.4 Zone D — Objective / Reserve State

Objective state is persistent and compact. Reserve decision is persistent in a collapsed state and expands only when it becomes actionable.

Before Central capture:

- Central = AI-controlled / capturable.
- Industrial = AI-controlled + `LOCKED` for player capture.
- Reserve Infantry = LOCKED.
- Reserve Armor = LOCKED.
- one reserve commitment exists but is not spendable.

After first PLAYER Central capture:

- Reserve panel expands or strongly highlights once.
- Industrial lock visibly clears.
- one badge explicitly states `1 COMMITMENT — CHOOSE ONE`.

After commitment:

- chosen Reserve = `COMMITTED`;
- unchosen Reserve = `UNAVAILABLE — COMMITMENT SPENT`;
- the panel returns to compact status and must not resemble a shop.

### 4.5 Zone E — Enemy Intel

This area is a compact list / event strip for legally known enemy information, not a debug feed.

It may show:

- CONTACT
- CONFIRMED class/identity when legally known
- LAST KNOWN and stale age
- contact lost / re-confirmed transitions

It must never show:

- hidden RED live coordinates;
- hidden RED HP;
- a live-updating LAST_KNOWN coordinate;
- hidden reinforcement location;
- omniscient route/AI-state labels such as HOLD / ENGAGE / RETURN unless such information is explicitly player-observable through gameplay (it currently is not).

The current `Enemy Intel: LAST KNOWN @ x,y` developer presentation must be replaced by player-facing spatial markers and concise status language. Raw world coordinates are DEBUG_MODE_ONLY.

### 4.6 Zone F — Critical Alerts

Transient alert stack for battlefield events. It must support the priority rules in Section 14.

Maximum simultaneous final-player alerts should remain small enough that the battlefield is not covered by a scrolling developer log. Older alerts collapse/fade unless they represent an unresolved critical condition.

### 4.7 Zone G — Minimap / Tactical Overview

A functional minimap is mandatory. It is not decorative.

Minimum content is defined in Section 12.

### 4.8 Zone H — Victory / Defeat / Restart

Victory and Defeat use a centered terminal overlay above normal HUD, but do not erase the battlefield instantly.

Victory must communicate:

- `VICTORY`
- Central held
- Industrial held
- concise mission-complete message
- `RESTART BATTLE01` action.

Defeat must communicate:

- `DEFEAT`
- combat/capture power is irrecoverable under the formal rule;
- concise mission-failed message;
- `RESTART BATTLE01` action.

Do not show mockup rewards, XP, currency, stars, campaign progression, or unrelated statistics.

## 5. Formation world readability contract

### 5.1 What every readable friendly Formation must answer

At the relevant zoom tier the player must be able to determine quickly:

1. What class is this Formation?
2. Is it BLUE or legally known RED?
3. Is it selected?
4. Is it healthy / damaged / critically damaged?
5. Is ammo critically low or empty?
6. What broad order is it executing?
7. Is it participating in capture / supply / withdraw?

### 5.2 Class identification

Use a stable class glyph family rather than relying on model silhouettes alone.

Current Battle01-relevant class language must cover:

- Recon
- Infantry
- IFV / Mechanized
- Armor
- Supply / Logistics

Any other role icon may be implemented only if that role is actually active in the current Battle01 runtime and already authorized upstream. The visual spec does not activate Artillery or any other unused Formation.

Suggested semantic glyph families are allowed but not pixel-locked:

- Recon: observation / recon-chevron glyph;
- Infantry: infantry-person / squad glyph;
- IFV: mechanized vehicle glyph distinct from Armor;
- Armor: tank / heavy-armor glyph;
- Supply: ammunition crate / logistics truck glyph.

### 5.3 Selection

Single selected Formation:

- BLUE selection frame/ring with high contrast;
- class marker strengthened;
- selection panel becomes active;
- world HP/ammo/order details may increase one information tier.

Multi-selection:

- every selected Formation gets the same BLUE selection family;
- no single selection ring may become so large that it reads as an objective area;
- the primary/hovered Formation may be slightly brighter than the rest;
- box-selection rectangle stays low-opacity and disappears immediately after selection.

### 5.4 HP readability

World HP bars are conditional:

- selected Formation — show;
- damaged friendly Formation — show at MID/NEAR;
- friendly Formation currently under fire — show temporarily;
- healthy unselected friendly Formation — may hide;
- CONFIRMED enemy Formation — may show only the HP information already legally exposed by current gameplay;
- CONTACT / LAST_KNOWN / UNSEEN enemy — never show HP.

The Selection panel always shows exact current/max friendly HP.

### 5.5 Ammo readability

Friendly ammo state:

- normal ammo — detailed exact value in Selection panel only;
- `LOW AMMO` visual warning when ammo is at or below 25% of max;
- `EMPTY` at 0 ammo;
- world warning icon appears for selected or critical friendly Formations, not permanently for every unit.

The 25% threshold is visual-only and creates no gameplay effect.

### 5.6 Current order feedback

Broad order state is shown with icon + concise text in Selection panel and a compact world glyph when useful:

- MOVE
- HOLD / idle
- WITHDRAW
- SUPPLYING / RECEIVING SUPPLY
- DESTROYED

Future formal commands use the visual language in Section 11 only when their gameplay implementation exists.

### 5.7 Movement destination

On accepted MOVE:

- show a green destination marker at the issued target;
- show a short-lived route/path cue from selected Formation(s);
- show direction, not a permanent neon ribbon;
- for multi-Formation movement, one group destination may branch into subtle per-Formation terminal offsets rather than painting multiple full-bright routes.

Recommended default visibility:

- initial path/destination acknowledgement: approximately `1.5s` then fade;
- selected Formation may retain a low-opacity terminal destination/order glyph while the order remains active;
- unselected Formation should not retain a bright full route.

### 5.8 Combat target

A combat target marker may appear only when the target is legally targetable/known through current gameplay.

Current runtime does not yet provide a complete explicit player ATTACK command; therefore the final ATTACK reticle visual is `IMPLEMENTATION_REQUIRED` alongside the command behavior and must not be presented as an enabled fake control.

If/when legally implemented:

- target reticle = RED;
- command acknowledgement is short-lived;
- no targeting line may continue to point to a hidden / LAST_KNOWN enemy as if live.

### 5.9 Capture participation

A capture-capable Formation inside an active objective capture may show a small capture glyph/order context near its marker. Do not wrap every participating Formation in a second objective-sized circle.

### 5.10 Destroyed state

Friendly destroyed Formation:

- lose selection immediately;
- class marker transitions to destroyed/disabled treatment;
- the world wreck/destruction result may remain if current combat presentation supports it;
- no working-order or ammo marker remains.

Enemy destroyed state must respect FOW. If destruction is not legitimately observed, UI must not reveal it through an omniscient death icon.

## 6. Camera Zoom / information LOD

Exact zoom thresholds are implementation freedom because they depend on the current `Camera2D` scale and viewport. The contract freezes three semantic tiers and their minimum retained information.

The implementation must use hysteresis or equivalent stable transition behavior so markers do not flicker rapidly when the camera sits near a boundary.

### 6.1 NEAR

Purpose: inspect the local fight.

Retain:

- unit model / battlefield representation;
- faction marker;
- class glyph;
- callsign for selected/hovered/critical Formation;
- selected state;
- selected/damaged HP;
- critical ammo state;
- current-order glyph;
- supply/capture contextual feedback;
- combat effects at highest appropriate detail.

Do not permanently show every exact stat above every Formation.

### 6.2 MID

Purpose: primary Battle01 command distance.

Retain:

- clear BLUE / legally known RED faction frame;
- class glyph;
- abbreviated Formation ID/callsign where readable;
- selected state;
- selected/damaged HP bar;
- LOW AMMO / EMPTY warning if critical;
- current order;
- objective and rally relationship;
- CONTACT / CONFIRMED / LAST_KNOWN state distinction.

Reduce:

- noncritical text;
- detailed numeric stats;
- small decorative model FX.

### 6.3 FAR

Purpose: tactical overview.

`TACTICAL MARKER FIRST`.

Retain minimum:

- faction/ownership color + shape;
- unit-class glyph;
- selected state;
- critical ammo / severe damage warning where useful;
- current broad command state for selected Formations;
- Central / Industrial state;
- active rally / reserve entry context when relevant;
- legally known RED intel state.

Hide:

- tiny unit names;
- exact HP text;
- exact ammo text;
- secondary status text;
- decorative route noise;
- most local combat particles.

Far zoom must remain playable even if the 2D/3D unit model itself becomes visually indistinguishable.

## 7. Intel / FOW visual language

### 7.1 UNSEEN

Player-visible result:

- no RED Formation model marker;
- no RED minimap marker;
- no RED HP/ammo/class information;
- no hidden-position alert;
- terrain remains visible according to the existing Battle01 world presentation.

UNSEEN is absence, not a gray live enemy icon.

### 7.2 CONTACT

Meaning: enemy presence detected, identity not fully confirmed.

World presentation:

- hollow / bracketed unknown-contact marker;
- warm amber-red family, not the same solid RED silhouette as CONFIRMED;
- `?` or unknown-contact glyph permitted;
- no class name unless Recon gameplay has actually confirmed it;
- no HP;
- no live target reticle.

Minimap:

- hollow CONTACT marker distinct from a confirmed RED Formation.

HUD:

- concise `CONTACT` event / intel row;
- no exact enemy strength.

### 7.3 CONFIRMED

Meaning: currently and legally observed enemy.

World presentation:

- solid RED Formation marker;
- class glyph / known identity;
- current legally observed position;
- HP only if current gameplay exposes it under CONFIRMED;
- target-under-fire/combat feedback may be shown while legally observed.

Minimap:

- solid RED marker with class-family shape if legible.

CONFIRMED must visually read as more certain than CONTACT, not merely a brighter version of the same ambiguous symbol.

### 7.4 LAST_KNOWN

Meaning: historical frozen position, not current truth.

World presentation:

- no live enemy model;
- static ghost marker at the frozen last-known position;
- desaturated amber-gray;
- dashed outline / broken ring;
- stale/clock/cross-hatch glyph;
- label `LAST KNOWN` or equivalent concise stale marker;
- optional age timer derived only from time since the state transition;
- no HP;
- no live target reticle;
- no line leading from marker toward the enemy's hidden actual position;
- no marker movement until legitimate reacquisition.

Minimap:

- same static ghost treatment, clearly distinct from CONTACT and CONFIRMED.

The current prototype X-ring is acceptable only as an interim debug representation. Final presentation must add explicit staleness semantics so a player cannot reasonably mistake it for a real-time enemy position.

### 7.5 Intel lost transition

`CONTACT / CONFIRMED -> LAST_KNOWN`:

- live marker drops out quickly;
- historical marker remains at the last legally known point;
- concise `CONTACT LOST` or stale transition may appear as INFO/TACTICAL feedback;
- no dramatic full-screen warning.

### 7.6 Reconfirmation

`LAST_KNOWN / UNSEEN -> CONTACT -> CONFIRMED` follows the existing Recon timing.

Visual language must respect the current `0.75s` continuous confirmation requirement except for legitimate firing reveal behavior already defined upstream. UI must not jump directly from stale information to full confirmed identity unless the existing Recon contract legitimately does so.

### 7.7 Per-Formation intel presentation implementation requirement

The current player `intel_tracker.gd` is a focused single-target presentation baseline. The final minimap/HUD must be able to present the same legal state language for every RED Formation that the existing Recon/FOW system exposes to the player.

Generalizing the presentation adapter is `IMPLEMENTATION_REQUIRED`, but it may not change detection, LOS, confirmation timing, firing reveal, AI knowledge, or hidden positions.

## 8. Objective visual language

### 8.1 Central Bridgehead identity

Central must read as:

`INTERMEDIATE / TACTICAL HINGE`

Recommended identity family:

- bridge / crossing glyph;
- label `CENTRAL BRIDGEHEAD`;
- slightly smaller strategic emphasis than Industrial at FAR zoom once Industrial is unlocked;
- still visually important because Victory requires retaining it.

Central state variants:

- AI CONTROL — RED ownership treatment;
- PLAYER CONTROL — BLUE ownership treatment;
- CAPTURING — ownership remains current owner while a 15s progress arc advances;
- CONTESTED — amber contest treatment; progress is visibly interrupted/reset according to current objective behavior;
- PLAYER CONTROL + UNCONTESTED — BLUE stable state; forward rally may become ACTIVE.

### 8.2 Industrial Objective identity

Industrial must read as:

`FINAL DECISIVE OBJECTIVE`

Recommended identity family:

- industrial / factory / decisive-target glyph;
- label `INDUSTRIAL OBJECTIVE`;
- after unlock, stronger strategic outline / final-objective badge than Central;
- never represented as a generic third A/B/C point.

Opening state:

- visible in world and minimap;
- AI-controlled ownership remains readable;
- player interaction state explicitly `LOCKED`;
- muted lock overlay and lock glyph;
- no player capture progress while locked.

After first complete PLAYER Central capture:

- lock clears;
- one concise, high-clarity `INDUSTRIAL UNLOCKED` feedback occurs;
- the objective becomes fully active as the final decisive target.

### 8.3 Objective world footprint

The current full `150`-radius objective circle is a gameplay/debug-friendly representation, not the required final visual weight.

Final world treatment:

- objective center icon is always readable;
- area boundary is subtle while stable;
- full capture footprint becomes more visible when selected/hovered, when a capture-capable friendly approaches, during CAPTURING, or during CONTESTED;
- stable objective circles must not visually overpower nearby Formations;
- capture progress uses a clean arc/ring near the objective identity rather than a huge bright disk.

### 8.4 15-second capture progress

During valid capture:

- explicit progress from 0–100%;
- world arc and HUD objective chip agree;
- owner does not visually change until complete transfer;
- active capturing faction color may drive the progress arc while the ownership frame still indicates current owner;
- no false resource-gain animation.

During CONTESTED:

- capture progress immediately ceases/resets as the current gameplay does;
- amber contest cross-hatch / interrupted-ring treatment;
- HUD alert `OBJECTIVE CONTESTED` at Tactical priority;
- no owner flip.

### 8.5 Central stage-change feedback

First PLAYER Central capture triggers three player-visible changes together but without a blocking cinematic:

1. Central ownership settles to BLUE.
2. Reserve panel changes LOCKED -> AVAILABLE and calls attention once.
3. Industrial lock clears and receives `FINAL OBJECTIVE UNLOCKED` emphasis.

The player should understand the new decision in less than a few seconds without losing camera control.

## 9. Supply visual contract

### 9.1 Supply Truck charges

Selected Supply Truck:

- show `AMMO SUPPLY` role;
- show charges as two discrete pips plus `x/2` text;
- show `0/2` clearly when empty;
- no HP-heal cross icon.

Unselected Supply Truck:

- Supply role glyph remains identifiable at MID/FAR;
- charge count appears in-world only when selected, critically empty, or Supply targeting is active.

### 9.2 Supply targeting mode

When player invokes Supply with the relevant selection/context:

- Supply Truck is highlighted in cyan secondary command color while retaining BLUE faction identity;
- legal target receives cyan contextual outline;
- invalid target receives red X / invalid cursor and a concise reason from the existing war-flow validation;
- the `140` range may be shown as a temporary, thin, low-opacity cyan radius around the truck only while Supply targeting is being resolved;
- do not permanently show a 140-range aura.

Relevant invalid reasons include, without changing gameplay:

- missing Supply Truck / target;
- target not friendly;
- Supply-to-Supply invalid;
- no charges remaining;
- target has no ammo capacity;
- ammo already full;
- target out of range;
- both Formations must be stationary;
- destroyed target/truck.

### 9.3 Active 4-second Supply

During active Supply:

- truck and target remain connected by a cyan transfer link;
- world or selection HUD shows a 0–4.0s progress indication;
- truck charge pips remain unchanged until successful completion;
- target ammo bar may show an anticipated/faint post-transfer segment but must not increment actual ammo before completion;
- the visual must clearly communicate that both Formations are committed to a stationary transfer.

### 9.4 Interruption

On interruption:

- cyan link breaks immediately;
- progress resets to zero;
- concise interruption reason appears at TACTICAL priority;
- charges remain unchanged;
- no partial-ammo animation remains.

### 9.5 Completion

On successful completion:

- target ammo visibly increases to the actual post-transfer value;
- one Supply charge pip is consumed;
- concise `AMMO +X` / `SUPPLY COMPLETE` feedback;
- cyan link fades quickly after completion;
- no HP-bar animation, wrench/repair animation, green healing numbers, or health-restoration language.

### 9.6 No charges remaining

At `0/2`:

- Supply action is visibly unavailable;
- truck remains a living movable logistics Formation if not destroyed;
- warning is `SUPPLY EMPTY / NO AMMO CHARGES`, not `vehicle disabled`;
- no recharge countdown is shown because none exists.

## 10. Reserve visual contract

### 10.1 Locked opening state

Reserve must be visible as a strategic commitment, not hidden as an unknown future feature.

Opening compact panel:

- `RESERVE` heading;
- Infantry card = `LOCKED`;
- Armor card = `LOCKED`;
- one commitment indicator = locked until Central first capture;
- concise dependency `SECURE CENTRAL BRIDGEHEAD`.

No price, resource icon, income value, population cost, build time, production building, tech prerequisite, or purchase button appears.

### 10.2 Available state

On first PLAYER Central capture:

- both cards switch to `AVAILABLE`;
- headline or badge: `1 COMMITMENT — CHOOSE ONE`;
- both cards use role identity and may show already-frozen summary stats/role descriptors if available from Formation definitions;
- the action wording is `COMMIT`, not `BUY` or `BUILD`.

Before confirmation, the two-card composition must make the irreversible tradeoff obvious.

### 10.3 Commitment

After player chooses one:

Chosen card:

- `COMMITTED`;
- BLUE active state;
- arrival/entry feedback linked to `WEST_REAR_ENTRY`.

Unchosen card:

- `UNAVAILABLE`;
- secondary text `COMMITMENT SPENT` or equivalent;
- no price/refund state.

The panel then collapses back to a compact battle-state indicator.

### 10.4 Entry feedback

When the chosen reserve appears:

- brief world marker at `WEST_REAR_ENTRY`;
- brief `RESERVE ARRIVED — WEST REAR` tactical alert;
- new Formation appears in Selection/Formation roster normally;
- no front-line teleport/deployment zone;
- no free-placement cursor.

## 11. Withdraw, command, and acknowledgement contract

### 11.1 MOVE

STATUS=`IMPLEMENTED`

Visual:

- green directional route;
- green destination marker;
- accepted acknowledgement;
- active selected Formation order glyph `MOVE`;
- invalid route attempt uses red invalid destination/route feedback if the runtime rejects the order.

### 11.2 FAST MOVE

STATUS=`IMPLEMENTATION_REQUIRED`

Final visual language when gameplay exists:

- same MOVE family but double-chevron / stronger motion-line pattern;
- do not use shield/buff/speed-stat text unless gameplay later defines it;
- currently must not appear as a working button.

### 11.3 ATTACK MOVE / ADVANCE

STATUS=`IMPLEMENTATION_REQUIRED`

Final visual language when gameplay exists:

- red-accented advance reticle combined with directional route;
- must respect Recon/FOW targeting legality;
- must never reveal or chase hidden LAST_KNOWN positions as real live targets;
- currently must not appear as a working player command.

### 11.4 HOLD

STATUS=`IMPLEMENTATION_REQUIRED_PLAYER_COMMAND`

The runtime has HOLD/stop state internally, but a full explicit player command is not currently wired as a final command action.

Final visual:

- blue shield/anchor glyph;
- compact local ring, not a large defensive-area promise;
- no defense buff indicator unless gameplay explicitly adds one (Battle01 currently does not).

### 11.5 HOLD FIRE

STATUS=`IMPLEMENTATION_REQUIRED`

Final visual:

- crossed muzzle / fire-disabled glyph;
- neutral/blue command state;
- must not imply stealth bonus, accuracy bonus, or detection immunity.

### 11.6 WITHDRAW / REVERSE

STATUS=`IMPLEMENTED`

Visual:

- yellow `#FFC857` rearward double-chevron;
- dashed withdrawal route;
- explicit destination label:
  - `WEST REAR`
  - or `BRIDGEHEAD RALLY` when forward rally is active and selected by existing input behavior;
- accepted acknowledgement and selected Formation order state `WITHDRAW`.

Do not show:

- speed boost trails;
- invulnerability shield;
- healing cross;
- damage-reduction badge;
- morale recovery.

### 11.7 STOP / CANCEL

STATUS=`IMPLEMENTATION_REQUIRED_PLAYER_COMMAND`

Final visual:

- neutral stop-square / cancel X;
- immediate acknowledgement;
- must simply terminate/cancel supported current intent according to eventual gameplay behavior;
- currently must not be exposed as a working button.

### 11.8 SUPPLY

STATUS=`IMPLEMENTED`

Visual uses cyan Supply contract from Section 9.

### 11.9 RESERVE COMMIT

STATUS=`IMPLEMENTED`

This is a strategic one-shot action and is presented in the Reserve panel, not mixed into ordinary movement/combat command buttons.

### 11.10 Multi-Formation command acknowledgement

When an order is accepted for multiple selected Formations:

- one primary world destination marker;
- subtle per-Formation terminal offsets where required by movement spacing;
- selection-panel confirmation such as `MOVE — 3 FORMATIONS`;
- avoid three equally bright full-length routes covering the map;
- if only a subset accepts the command, feedback must not falsely claim all Formations accepted it.

## 12. Minimap / tactical overview contract

A real Battle01 minimap is `IMPLEMENTATION_REQUIRED` and mandatory for final visual acceptance.

### 12.1 Terrain macro shape

Show the existing map at macro level:

- West rear;
- river / bridge relationship;
- North maneuver relation;
- Central route / bridgehead;
- South longer flank relationship;
- East industrial area;
- major blockers / traversable relationship only to the level needed for route comprehension.

Do not invent new map regions.

### 12.2 Friendly Formations

All living BLUE Formations are represented with BLUE markers.

Marker shape should preserve class readability at minimap scale where practical:

- infantry/recon = light/infantry marker family;
- IFV/Armor = vehicle/heavy marker family;
- Supply = logistics marker family.

Selected BLUE Formations receive a selection accent.

### 12.3 RED intel

The minimap must use legally known RED intel only:

- UNSEEN — absent;
- CONTACT — hollow unknown contact;
- CONFIRMED — solid RED class/Formation marker;
- LAST_KNOWN — static dashed/ghost historical marker.

No hidden RED live position may be sampled for the minimap.

### 12.4 Objectives

Always show:

- Central Bridgehead;
- Industrial Objective;
- ownership;
- contested state;
- Industrial locked state before unlock.

Industrial's final-objective identity must remain distinct from Central after unlock.

### 12.5 Camera viewport

Show a clear camera viewport rectangle/shape on the minimap. It must update smoothly with camera motion without becoming the brightest minimap element.

### 12.6 Rally and reserve geography

When tactically relevant:

- West Rear / `WEST_REAR_RALLY` may be shown as a subdued friendly rally marker;
- `WEST_REAR_ENTRY` becomes prominent around reserve commitment/arrival;
- `BRIDGEHEAD_FORWARD_RALLY` appears only while ACTIVE;
- inactive Forward Rally must not look usable.

### 12.7 What the minimap must not show

- UNSEEN RED real position;
- hidden AI state;
- hidden pursuit path;
- unsupported artillery range / air support zones;
- mining/resource nodes;
- tech/building production icons;
- fictional supply depots or repair zones;
- fake heatmaps generated from omniscient enemy data.

## 13. Combat readability contract

Battle01 combat visuals may be improved substantially, but visual effects may not create gameplay that does not exist.

### 13.1 Infantry fire

Minimum readable presentation:

- small-arms muzzle flash;
- short, restrained tracer/shot cue where appropriate;
- target impact dust/spark appropriate to the current target representation;
- firing Formation readable as source;
- no suppression aura or damage-over-time field.

### 13.2 IFV fire

Minimum readable presentation:

- visually distinct cadence/flash from Infantry;
- directional firing cue;
- impact stronger than small-arms but below heavy Armor fire;
- no invented missiles or splash-damage language unless current gameplay actually uses them.

### 13.3 Armor fire

Minimum readable presentation:

- strong main-gun muzzle flash / smoke impulse;
- clear firing direction;
- heavy impact response;
- brief camera-independent readability at MID zoom;
- no penetration/ricochet/armor-module rule implied unless already present upstream.

### 13.4 Impact and damage

Damage feedback:

- target-under-fire state may briefly emphasize HP bar / damage marker;
- impact FX scale follows weapon family visually;
- optional small hit flash/shake must not obscure unit identity;
- do not show fictional armor, morale, suppression, module damage, critical hit, hit chance, or penetration stats.

Floating damage numbers are not required and should be omitted by default for the final military presentation unless later usability testing proves they are needed.

### 13.5 Formation death / destruction

Death must be unambiguous:

- combat-capable marker disappears/transitions to destroyed state;
- vehicle destruction may use short explosion + smoke/wreck presentation;
- infantry Formation loss may use restrained disappearance/casualty-state treatment suitable to the current abstraction;
- selection is removed immediately;
- destroyed Formation no longer appears active in HUD roster;
- enemy death visibility follows legal player observation.

### 13.6 Target under fire

Friendly Formation under fire:

- temporary HP-bar reveal;
- directional/local impact cues;
- alert only when tactically useful, not every hit;
- repeated hits must coalesce rather than spam alerts.

### 13.7 Effect priority under high intensity

When many events overlap:

Priority order:

1. selected Formation identity and command feedback;
2. Central / Industrial objective state;
3. legal RED intel state;
4. critical friendly damage / low ammo;
5. major weapon fire / destruction;
6. ordinary impacts / ambient smoke;
7. decorative detail.

Effects at lower priority may reduce particle count, duration, brightness, or persistence before higher-priority markers are compromised.

### 13.8 Explicitly prohibited visual-gameplay implications

Do not add or visually promise:

- artillery support that is not active in Battle01;
- airstrike / CAS;
- missile system not already active;
- suppression mechanics;
- armor penetration / ricochet rules;
- morale;
- repair/healing;
- area damage rule;
- cover bonuses not frozen upstream;
- weather combat modifiers;
- commander abilities;
- damage-module states.

## 14. Battle Alert priority

Final alert stack has three semantic levels.

### 14.1 INFO

Use for state awareness that does not demand immediate action.

Examples:

- CONTACT LOST -> LAST_KNOWN;
- normal command accepted when a world acknowledgement alone is insufficient;
- Supply complete;
- noncritical objective state update.

Presentation:

- compact;
- low-to-medium opacity;
- short lifetime;
- no screen-center modal.

### 14.2 TACTICAL

Use for actionable battlefield changes.

Events include:

- CONTACT;
- CONFIRMED;
- Central contested;
- Central captured;
- Industrial unlocked;
- Reserve unlocked;
- enemy reinforcement event only when it is legitimately player-visible;
- Supply interrupted;
- Supply empty;
- Formation low ammo;
- Forward Rally activation/deactivation when relevant.

Presentation:

- stronger icon + concise text;
- amber/semantic accent;
- short attention pulse;
- does not pause input.

Enemy reinforcement rule: UI must not expose a hidden activation timer or unseen spawn position merely because the deterministic rule exists. If activation is a public battle event, show it at activation; otherwise alert on the first legally detected reinforcement CONTACT/CONFIRMED event.

### 14.3 CRITICAL

Use for decisive or immediate risk.

Events include:

- Formation destroyed when materially important to the player;
- Industrial contested;
- force-collapse / Defeat trigger;
- Victory;
- Defeat.

A severe Central-loss / dual-objective risk may also be Critical when it directly threatens the formal win condition.

Presentation:

- high-contrast red / decisive accent;
- persistent until the underlying condition clears for unresolved battlefield threats, or until terminal action for Victory/Defeat;
- still must not cover the entire battlefield except the terminal result overlay.

### 14.4 Alert anti-spam rules

- repeated low-ammo or under-fire events coalesce per Formation;
- contest alerts do not re-fire every frame;
- CONTACT/CONFIRMED transitions fire once per transition;
- Supply progress itself is not an alert stream;
- no raw runtime log lines in player mode.

## 15. Visual layer stack

Frozen conceptual layer order:

`L0 TERRAIN`  
Map, roads, river, bridge, industrial geometry, vegetation/buildings already present.

`L1 WORLD OBJECTIVES / RALLY`  
Central, Industrial, capture footprint/progress, active rally, reserve entry when relevant.

`L2 FORMATIONS`  
Friendly Formations and legally visible enemy Formations, class markers, conditional HP/ammo state.

`L3 INTEL / COMMAND WORLD FEEDBACK`  
CONTACT / LAST_KNOWN markers, selection, routes, destinations, target markers, Supply link.

`L4 COMBAT EFFECTS`  
Muzzle flash, tracer/projectile visual where appropriate, impacts, destruction, smoke.

`L5 HUD`  
Mission state, objective chips, selection, command controls, Reserve, Supply status, minimap, alerts.

`L6 CRITICAL OVERLAY`  
Critical terminal warnings and Victory / Defeat / Restart.

Layer rules:

- HUD must not permanently cover the central battle space;
- L4 effects may never obscure L2/L3 critical readability for prolonged periods;
- stable objective areas remain quieter than selected Formations;
- debug overlays live outside the normal player stack and are hidden by default.

## 16. Target Alignment Matrix

| Target | WHAT_TO_PRESERVE | WHAT_TO_ADAPT | WHAT_NOT_TO_COPY |
|---|---|---|---|
| `P0-01 Complete Combat HUD` | Full-battle information hierarchy; battlefield remains central; mission/objective, selection, formation status, command area, minimap, alerts, terminal result | Replace old resource/population/production emphasis with current Mission + two Objective + Reserve + Supply/Intel state; use exactly Central + Industrial; friendly BLUE / enemy RED | Resource income, population cap, A/B/C objective set, old production shop, unsupported skills/support, extra mission conditions |
| `P0-02 Build / Purchase / Deploy Flow` | Clear decision hierarchy; available/unavailable states; legal/invalid feedback; strong entry/arrival feedback | Convert entire purchase flow into `Reserve LOCKED -> AVAILABLE -> choose ONE -> COMMITTED -> WEST_REAR_ENTRY`; wording COMMIT, not BUY | Currency, income, prices, factories, production queues, population cost, free placement zones, tech requirements, long-term economy |
| `P0-03 Command System / Feedback` | Distinct command colors, short route/destination feedback, selection clarity, acknowledgement, alert readability | Show only working commands as enabled; MOVE green, WITHDRAW yellow, SUPPLY cyan; freeze future commands as `IMPLEMENTATION_REQUIRED` | Patrol, unload, abilities, artillery/air support, fake ATTACK/HOLD/HOLD FIRE buttons before runtime support |
| `P0-04 Terrain / Objective / Battlefield Function Layer` | Battlefield macro readability, bridge/road relationships, objective-state visibility, rally/entry geography, minimap functional layers | Reduce to exactly Central, Industrial, West Rear, West Rear Entry, conditional Bridgehead Forward Rally, current North/Central/South maneuver relationship | A/B/C point set, resource nodes, repair/fuel stations, extra capture points, destructible-bridge gameplay not frozen upstream, weather modifiers |
| `P0-05 High-Intensity Combat` | Dense but readable combat; clear source/impact/destruction; alert prioritization; selected units remain readable | Use only actual Infantry, IFV, Armor fire and existing impacts/destruction; lower FX density before losing marker clarity | Artillery/CAS, suppression, morale, damage modules, area-damage circles, fictional weapon systems, unsupported combat modifiers |
| `P1-06 Unit Visual Identification / Zoom` | Immediate faction and class recognition; NEAR/MID/FAR information reduction; tactical-marker-first far view | Map visual language to current Recon, Infantry, IFV, Armor, Supply Formations and legal intel states | Unit classes not active/authorized in Battle01; exact-stat walls above every unit; tiny-model-only far identification |
| `P1-07 Building / Objective Function State` | Functional state language and strong role differentiation for important battlefield locations | Treat current functional locations as Central, Industrial, West Rear/Entry, Forward Rally; Industrial Locked/Unlocked is the key state transition | Factory/production/supply-station/repair-building loops, build queues, tech buildings, extra strongpoints that are not current gameplay |
| `FINAL-01 Final Battle Presentation` | Cohesive dark modern-war command UI, Formation-level readability, layered battlefield, focused combat effects, clear objectives/alerts | Compose the final runtime around current QA-accepted war flow: Recon -> Central -> counterattack/logistics/reserve -> Industrial -> Victory/Defeat | Any old economy, A/B/C structure, unsupported commands, omniscient enemy information, extra systems added only for visual similarity |

Target images are references for composition, density, hierarchy, atmosphere, icon language, and interaction clarity. They are not permission to import old mechanics.

## 17. Current prototype cleanup contract

The current prototype is valuable for QA but is not acceptable as final-player presentation.

### 17.1 Remove / replace from normal player mode

The following current scene/HUD elements are `DEBUG / PROTOTYPE ONLY`:

- `FRONTLINE / BATTLE01` development title label;
- current long `MISSION: Take Central Bridgehead, survive counterattack...` sentence;
- `Selected Formations: ...` concatenated debug text;
- `Current Orders: ...` concatenated debug text;
- `Friendly Core: IFV ... | RECON ...` raw line;
- `Enemy Strength: ...` raw debug-style line;
- `Enemy Intel: LAST KNOWN @ x,y` raw coordinates;
- `OBJECTIVES — Central: ... | Industrial: ...` raw state-string line;
- raw controls tutorial string `LMB/Shift/Box ... F ... X ... 1 ... 2 ...` as permanent HUD;
- `WAR FLOW V1 — SUPPLY / RESERVE / DUAL OBJECTIVE` prototype notice;
- dynamically appended `BLUE FORCE:` giant text line;
- dynamically appended `SUPPLY ...` giant text line;
- dynamically appended `RESERVE ...` giant text line;
- dynamically appended `RALLY ...` giant text line;
- any permanent AI state, coordinates, QA marker, smoke-test status, or internal enum dump.

Replace them with the structured HUD zones defined in this document.

### 17.2 Prototype world graphics to replace / reduce

- current Formation colored circles are prototype identity; replace/augment with class/faction tactical markers and actual visual representation;
- current always-on HP bars should become conditional according to Section 5;
- current Supply text under the world marker should become contextual charge/status presentation;
- current full route polyline on every moving selected Formation should follow the short-lived command feedback hierarchy;
- current full-size objective radius circle should be visually quieter outside capture/contest interaction;
- current objective raw `[OWNER] LOCKED CONTESTED` string should become icon/state language;
- current LAST_KNOWN X-ring requires stronger stale/historical semantics.

### 17.3 DEBUG_MODE_ONLY retention

The existing information may remain accessible for development/QA through a dedicated debug overlay or debug mode.

Allowed DEBUG_MODE_ONLY data:

- raw Formation names/HP/ammo/order dumps;
- objective internal owner/state/progress enums;
- Supply validation state;
- Reserve flags;
- rally state;
- world coordinates;
- Enemy AI states;
- FOW/intel internals;
- performance counters;
- CI/runtime markers.

Requirements:

- debug overlay default = OFF in player mode;
- debug overlay must be visually distinct from product HUD;
- hiding debug UI must not remove runtime logs needed by automated QA;
- implementation must not delete QA hooks merely to make screenshots cleaner.

## 18. Implementation freedom

Codex / implementation is explicitly free to decide:

- Godot `Control` hierarchy;
- Containers;
- anchors and responsive layout;
- Theme resources;
- CanvasLayer organization;
- signal wiring;
- HUD update helpers;
- icon implementation technique;
- texture atlas / SVG / procedural icon choice;
- draw calls;
- shader/material details;
- world-marker node organization;
- marker pooling/caching;
- minimap rendering method;
- LOD thresholds and transition hysteresis;
- exact animation curves/durations within the intent of this contract;
- debug overlay implementation;
- internal component/node/file names;
- exact pixels and margins.

Implementation freedom is valid only while all player-visible semantics, information priority, FOW legality, objective meaning, Supply semantics, Reserve one-choice semantics, and Acceptance Contract are satisfied.

Visual implementation may create presentation-only adapters, view models, icons, themes, marker nodes, minimap render data, and alert aggregators. It may not modify gameplay rules to make UI easier.

## 19. Implementation priority

Recommended construction order for Codex:

### P0 — HUD shell and prototype cleanup

- structured Mission/Battle State;
- structured Selection Summary;
- current-order/HP/ammo state;
- Central / Industrial state chips;
- Reserve locked/available/committed panel;
- Supply charges/progress state;
- alert stack;
- terminal Victory/Defeat/Restart;
- current prototype text hidden in normal player mode.

### P0 — Formation / objective world readability

- BLUE/RED class markers;
- selection / multi-selection;
- conditional HP/ammo warnings;
- current order feedback;
- Central vs Industrial identity;
- locked/unlocked/capturing/contested visuals;
- MOVE / WITHDRAW / SUPPLY world feedback;
- LAST_KNOWN stale treatment.

### P0 — Minimap

- terrain macro shape;
- BLUE Formations;
- legal RED intel only;
- both objectives;
- camera viewport;
- rallies / entry when relevant;
- FOW correctness.

### P1 — Combat readability pass

- Infantry fire;
- IFV fire;
- Armor fire;
- impact / damage response;
- death/destruction;
- FX density management.

### P1 — Final polish

- icon consistency;
- animation timing;
- typography/spacing;
- zoom LOD stability;
- alert coalescing;
- final dark modern-war presentation.

This order does not change gameplay. It only sequences visual construction.

## 20. Acceptance Contract for Window 07

Visual acceptance cannot be closed by `HUD_SMOKE_PASS` alone. Window 07 must inspect actual player-visible runtime screenshots and/or short recordings at the tested game commit.

Each scenario below requires the stated result.

### A. Opening HUD

**SCENARIO**  
Launch Battle01 into normal player mode with no selection.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
No developer text wall. Central is clearly AI-controlled and active. Industrial is visible, AI-controlled, and explicitly LOCKED for player capture. Reserve Infantry and Armor are visible as LOCKED. The minimap shows terrain macro shape, BLUE active force, Central/Industrial, camera viewport, and no UNSEEN RED live markers. Mission instruction is concise.

### B. Single selection

**SCENARIO**  
Select one BLUE combat Formation.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
World selection state is obvious. Selection panel shows callsign, class, HP, ammo if applicable, current order, and valid actions. Healthy unrelated Formations stay visually quiet.

### C. Multi-selection

**SCENARIO**  
Box-select multiple BLUE Formations.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Every selected Formation is clearly marked; Selection Summary uses cards/compact rows rather than a long concatenated sentence; per-Formation HP/ammo/order/critical state remains distinguishable.

### D. Move order

**SCENARIO**  
Issue MOVE to one then multiple selected Formations.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Green destination acknowledgement and short route indication appear. Multi-Formation spacing is readable without route clutter. Selected Formation order state becomes MOVE. Feedback fades without leaving permanent bright paths.

### E. Contact

**SCENARIO**  
Legally detect a RED Formation long enough to enter CONTACT but not yet CONFIRMED.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
CONTACT appears as hollow/ambiguous unknown-contact visual. No exact class/HP is leaked. Minimap uses CONTACT marker, not confirmed RED marker.

### F. Confirmed

**SCENARIO**  
Maintain legitimate observation through confirmation or trigger a legitimate firing reveal.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Marker changes to solid RED confirmed identity/class. Current legally known position is shown. Only information legally exposed under CONFIRMED appears. Minimap updates to confirmed marker.

### G. Last Known

**SCENARIO**  
Lose legitimate observation after CONTACT/CONFIRMED while the RED Formation continues moving hidden.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Live RED Formation disappears. A static ghost/dashed LAST_KNOWN marker remains at the frozen historical position and does not follow hidden movement. No enemy HP/live-target line is shown. Minimap marker remains static and visually stale.

### H. Central capturing

**SCENARIO**  
Place a legal BLUE capture-capable Formation in Central with no RED capture-capable opponent present.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Central retains current ownership frame while a clearly readable 15s capture progress arc advances. HUD and world progress agree. No resource-income animation appears.

### I. Central contested

**SCENARIO**  
Create legitimate simultaneous BLUE and RED capture-capable presence at Central.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Central becomes amber CONTESTED. Capture progress visibly stops/resets according to runtime. Owner does not falsely change. Tactical alert appears once, not every frame.

### J. Central captured

**SCENARIO**  
Complete the first 15s PLAYER capture of Central.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Central becomes stable BLUE. A concise success/state-change feedback appears. The same moment visibly unlocks Reserve and Industrial without a blocking modal.

### K. Industrial unlocked

**SCENARIO**  
Observe Industrial immediately before and after first PLAYER Central capture.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Before: Industrial is visible but LOCKED. After: lock clears, final-decisive identity becomes active, and `INDUSTRIAL UNLOCKED` feedback is clear. AI ownership remains RED until actually captured.

### L. Supply valid

**SCENARIO**  
Select living BLUE Supply Truck + one legal depleted friendly target within 140 range while both are stationary.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Supply context is cyan; truck charges are visible; legal target is highlighted; UI clearly communicates AMMO supply only; no healing/repair language appears.

### M. Supply progress

**SCENARIO**  
Start a valid Supply transfer and leave it uninterrupted.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Truck and target are linked by cyan transfer feedback. Progress reads continuously from 0 toward 4.0s. Actual ammo does not increment prematurely. Charge count does not decrement until completion.

### N. Supply interruption

**SCENARIO**  
Interrupt Supply by movement, damage, firing, or range break.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Transfer link breaks immediately, progress resets to zero, concise reason appears, and no charge is consumed. There is no residual partial-transfer bar.

### O. Supply complete

**SCENARIO**  
Complete four uninterrupted seconds of valid Supply.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Actual ammo bar/value increases to the runtime result, one charge is consumed, brief AMMO/SUPPLY completion feedback appears, and HP is unchanged with no healing visual.

### P. Reserve unlocked

**SCENARIO**  
First complete PLAYER Central capture with Reserve unused.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Both Infantry and Armor switch LOCKED -> AVAILABLE. UI prominently but non-blockingly states `1 COMMITMENT — CHOOSE ONE`.

### Q. Reserve Infantry / Armor choice

**SCENARIO**  
Open/focus the available Reserve choice before committing.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Two clear role cards are shown side by side. No currency/price/population/production queue exists. The irreversible one-choice nature is understandable before input.

### R. Reserve committed

**SCENARIO**  
Commit either Infantry or Armor.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Chosen card becomes COMMITTED; unchosen card becomes UNAVAILABLE / COMMITMENT SPENT. The chosen Formation appears at WEST_REAR_ENTRY with brief arrival feedback and joins normal Formation control. No free front-line placement occurs.

### S. Withdraw

**SCENARIO**  
Issue WITHDRAW / REVERSE to one or multiple BLUE Formations.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Yellow rearward-chevron/dashed-route feedback clearly differs from normal green MOVE. Destination is labeled as the legal rally. No speed, armor, healing, immunity, or damage-reduction effect is implied.

### T. Forward Rally active

**SCENARIO**  
Hold Central as PLAYER uncontested, then contest or lose it.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
BRIDGEHEAD_FORWARD_RALLY is visibly ACTIVE only while Central is PLAYER/uncontested. It becomes INACTIVE/not-usable when Central is contested or lost. WEST_REAR_RALLY remains the rear fallback.

### U. High-intensity combat

**SCENARIO**  
Run the densest normal Battle01 fight with multiple Formations firing and taking damage around an objective.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Selected Formation, objective state, legal enemy intel, command feedback, HP/ammo critical warnings, and major fire/destruction remain readable. Effects create impact without introducing artillery/suppression/morale/penetration/repair mechanics or hiding the command layer.

### V. Industrial contested

**SCENARIO**  
After unlock, create legitimate simultaneous opposing capture presence at Industrial.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Industrial receives stronger final-objective CONTESTED emphasis than a normal low-priority event; capture progress stops/resets; ownership does not falsely change; Critical alert is visible without blocking commands.

### W. Dual-objective Victory

**SCENARIO**  
First capture Industrial while Central is not simultaneously PLAYER/uncontested, then achieve the formal dual-objective condition.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
No Victory appears for Central alone or for an invalid dual-objective state. Only when Central and Industrial are both PLAYER-owned and uncontested does the VICTORY overlay appear with Restart.

### X. Defeat

**SCENARIO**  
Reach the formal irrecoverable-force Defeat condition, including reserve legality as defined upstream.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
DEFEAT overlay appears only on the formal defeat state, with concise reason and Restart. IFV death alone does not trigger the visual Defeat result. No debug/QA strings are visible.

### Y. Far zoom battlefield readability

**SCENARIO**  
Zoom to the far tactical tier during a mixed BLUE / legally known RED engagement with both objectives visible.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
Player can identify faction, unit class, selected state, critical status, Central vs Industrial, and broad order without reading tiny models. CONTACT / CONFIRMED / LAST_KNOWN remain distinguishable. Noncritical detail is reduced rather than overlapping.

### Z. Minimap FOW correctness

**SCENARIO**  
Record the minimap across enemy transitions UNSEEN -> CONTACT -> CONFIRMED -> LAST_KNOWN while the hidden enemy moves after LOS is lost.

**EXPECTED_PLAYER_VISIBLE_RESULT**  
UNSEEN RED is absent; CONTACT is ambiguous/hollow; CONFIRMED is solid RED; LAST_KNOWN is a static stale ghost at the frozen point. The minimap never tracks the hidden real enemy position. Camera viewport and objective states remain correct.

## 21. Required visual evidence for QA

Window 07 acceptance requires real runtime evidence at the exact tested implementation commit.

Minimum sufficient visual evidence should include screenshots and/or short recordings covering:

- Opening HUD;
- single + multi-selection and MOVE;
- CONTACT -> CONFIRMED -> LAST_KNOWN transition;
- Central capturing / contested / captured and Industrial unlock;
- Supply valid / progress / interruption / completion;
- Reserve unlock / choice / commitment / West Rear entry;
- WITHDRAW + Forward Rally activation/deactivation;
- high-intensity combat;
- Industrial contested;
- Victory + Defeat;
- FAR zoom readability;
- minimap FOW correctness.

A single recording may cover multiple scenarios if every required player-visible result is clearly inspectable. Duplicate long videos are not required.

Automated markers and `HUD_SMOKE_PASS` remain useful construction evidence but are insufficient alone for final visual acceptance.

## 22. Visual performance constraints

Window 06 freezes only product-level performance expectations. Detailed profiling belongs to Window 07.

Requirements:

1. HUD remains stable during Battle01 with no visible flicker or layout thrashing.
2. Do not rebuild a large Control tree every frame.
3. Prefer event/state-driven updates; frequent numeric progress may update efficiently without reconstructing containers.
4. Formation/world-marker count must scale to the actual Battle01 Formation count without excessive node churn.
5. Minimap updates must not require omniscient gameplay queries or expensive full-world rebuilds each frame.
6. Combat FX must be capped/pooled/reduced as necessary before causing obvious frame hitching in normal Battle01 high-intensity combat.
7. NEAR/MID/FAR tier changes must remain visually stable during smooth zoom.
8. Alerts must coalesce repeated events rather than continuously allocate new UI rows.
9. Debug overlay, when disabled, must not carry the cost of continuously formatting large strings solely for display.
10. Visual optimization may reduce particles, animation density, or noncritical text; it may not remove critical command/objective/intel readability.

No arbitrary hardware-specific frame-rate gate is invented here. Window 07 profiles the actual tested runtime and determines whether the implementation introduces a material regression.

## 23. Non-goals / explicit exclusions

This visual implementation does not authorize:

- mining;
- economy ticks;
- currency;
- population cap;
- workers;
- production buildings;
- purchase prices;
- tech tree;
- build queue;
- base construction;
- repair/healing;
- HP-restoring Supply;
- fuel logistics;
- morale;
- suppression;
- penetration/armor simulation;
- new weapon families;
- artillery support not already active in Battle01;
- air support;
- weather gameplay;
- extra capture points;
- A/B/C objective conversion;
- strategic campaign map;
- multiplayer UI;
- replay system;
- achievements;
- new Enemy AI states;
- hidden enemy tracking;
- redesign of navigation/routes;
- redesign of Victory/Defeat.

## 24. Freeze summary

The final Battle01 visual target is a compact Formation-command battlefield interface built around the QA-accepted runtime:

`Recon / incomplete information`  
`-> Maneuver / legal command feedback`  
`-> Central Bridgehead`  
`-> Counterattack pressure`  
`-> AMMO Supply / Withdraw / one Reserve commitment`  
`-> Industrial Objective`  
`-> Dual-objective Victory or formal Defeat`.

The UI must make that loop understandable without debug strings and without importing the old target images' economy, purchase, three-point objective, extra facility, weather, artillery, suppression, or other out-of-scope examples.

WINDOW_08_TARGETS_ARE_REFERENCE=YES  
CURRENT_GAMEPLAY_IS_AUTHORITY=YES  
HUD_ARCHITECTURE_DEFINED=YES  
FORMATION_READABILITY_DEFINED=YES  
INTEL_VISUAL_LANGUAGE_DEFINED=YES  
OBJECTIVE_VISUAL_LANGUAGE_DEFINED=YES  
SUPPLY_VISUAL_DEFINED=YES  
RESERVE_VISUAL_DEFINED=YES  
WITHDRAW_FEEDBACK_DEFINED=YES  
COMMAND_FEEDBACK_DEFINED=YES  
MINIMAP_DEFINED=YES  
COMBAT_READABILITY_DEFINED=YES  
ALERT_PRIORITY_DEFINED=YES  
TARGET_ALIGNMENT_MATRIX_DEFINED=YES  
PROTOTYPE_CLEANUP_DEFINED=YES  
IMPLEMENTATION_FREEDOM_DEFINED=YES  
ACCEPTANCE_CONTRACT_DEFINED=YES  
READY_FOR_IMPLEMENTATION=YES  
BLOCKER=NONE
