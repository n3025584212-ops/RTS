# BATTLE01_VISUAL_TARGET_TO_RUNTIME_PLAN_V1

TASK_ID=REWORK_BATTLE01_VISUAL_TARGET_ALIGNMENT_V1
OWNER_WINDOW=WINDOW_06_UI_VISUAL
SOURCE_OF_TRUTH=GITHUB_MAIN
BASE_COMMIT=058e6b225c42c8d7e7011b07f4a202a418fea009
GAMEPLAY_CHANGE_ALLOWED=NO
SCOPE_EXPANSION_ALLOWED=NO

This document is the visual translation plan required by
`docs/BATTLE01_VISUAL_TARGET_ALIGNMENT_REWORK_V1.md` section 8.
It is a translation plan, not a new design exercise.

Every target image was opened as a real PNG binary and reviewed before this
plan was written.

---

## Pair 1 — P0-01_FULL_COMBAT_HUD

- TARGET_FILE=docs/visual_targets/battle01/P0-01_FULL_COMBAT_HUD.png
- PRESERVE=HUD zone composition: top mission/objective strip, left mission+tactical column, dominant central battlefield, right intel/alerts column, bottom formation bar + command icons + minimap; dark tactical panels with high-contrast semantic color coding; icon-first communication; typography hierarchy.
- ADAPT_TO_CURRENT_GAMEPLAY=Top strip shows mission/objective state instead of currency/population; right column shows Recon/FOW intel instead of production; bottom bar shows current commands (MOVE/SUPPLY/WITHDRAW) instead of purchase/queue; no A/B/C three-objective structure — exactly two formal objectives (Central Bridgehead, Industrial).
- DO_NOT_COPY=gold/oil/steel/manpower counters; production/queue panel; population cap; tech tree; purchase costs; A/B/C triple objective structure.
- CURRENT_RUNTIME_GAP=Programmatic `Panel + Label + ProgressBar` stacks, raw debug-style text lines, no icon system, fallback-font world text, no designed typography scale.
- IMPLEMENTATION_ACTION=Rework hud.gd to the target composition with SVG icon set (command/objective/intel/alert/reserve icons), designed panel hierarchy, section captions, chips and progress bars; keep every public HUD API signature identical.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_OPENING_HUD

## Pair 2 — P0-02_RESERVE_DEPLOYMENT_REFERENCE

- TARGET_FILE=docs/visual_targets/battle01/P0-02_RESERVE_DEPLOYMENT_REFERENCE.png
- PRESERVE=Decision-layer composition only: clear locked → unlocked → single choice → committed status language; legal/illegal feedback; arrival feedback at the entry point; HUD visual language consistency.
- ADAPT_TO_CURRENT_GAMEPLAY=The entire economy/production/deployment loop is obsolete. Adapted into the frozen one-choice Reserve Commitment: locked until first PLAYER Central capture, then exactly one of INFANTRY/ARMOR, entry from WEST_REAR_ENTRY, arrival alert.
- DO_NOT_COPY=currency, build time, queue, factory buildings, population, purchase buttons, reinforcement smoke mechanics not present in runtime.
- CURRENT_RUNTIME_GAP=Reserve panel is two text buttons with no role identity; no iconography; arrival is text-only alert.
- IMPLEMENTATION_ACTION=Reserve panel with role icons (INFANTRY/ARMOR), status badge color language, dependency line, arrival alert with reserve icon; entry-point marker on the battlefield (world presentation).
- RUNTIME_EVIDENCE_SCENE=RUNTIME_RESERVE_DECISION

## Pair 3 — P0-03_COMMAND_FEEDBACK

- TARGET_FILE=docs/visual_targets/battle01/P0-03_COMMAND_FEEDBACK.png
- PRESERVE=Command color language (MOVE #6CCB6C, HOLD #4D8CFF, WITHDRAW #FFC857, SUPPLY #4DD0E1, INVALID #FF5544, ENEMY #FF4D4D); icon per command; execution status feedback (moving/attacking/holding/withdrawing/supplying/completed/cancelled); path legality colors; minimap command-status language; alert panel.
- ADAPT_TO_CURRENT_GAMEPLAY=Only commands actually present in the frozen runtime are rendered as active command chips: MOVE (RMB), SUPPLY (F), WITHDRAW (X). ATTACK/HOLD-FIRE/STOP etc. stay `IMPLEMENTATION_REQUIRED` and are not fabricated as working buttons.
- DO_NOT_COPY=Tunnel/guard/mail/special keys; attack button as a working command; production shortcuts.
- CURRENT_RUNTIME_GAP=Command chips are text-only labels; order glyphs are fallback-font text (MOV/WD/HLD); path rendering is present but plain; no command icons.
- IMPLEMENTATION_ACTION=SVG command icons on chips; order glyphs as drawn chevron/shield icons; path legality colors already match — refine with destination marker + route treatment; command feedback line with icon prefix.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_SELECTION_COMMAND

## Pair 4 — P0-04_TERRAIN_OBJECTIVE_LAYER

- TARGET_FILE=docs/visual_targets/battle01/P0-04_TERRAIN_OBJECTIVE_LAYER.png
- PRESERVE=Terrain material language (bridge/river/village/industrial/forest/open ground), capture-point status presentation (neutral/capturing/contested/captured), route legality colors, minimap layer language, terrain color conventions.
- ADAPT_TO_CURRENT_GAMEPLAY=Terrain stays a presentation layer; navigation/los logic unchanged; no new terrain mechanics.
- DO_NOT_COPY=New terrain types that would imply new gameplay (destroyable bridges, cover modifiers, high-ground bonuses) are not added as mechanics — visual only, and only where the frozen map already has the feature (bridge, river, village, industry, forest, open ground, west rear).
- CURRENT_RUNTIME_GAP=Flat rectangles + fallback-font landmark labels; no material language; objectives are circles with text tags.
- IMPLEMENTATION_ACTION=Rework battlefield.gd drawing: layered terrain with road casing, river banks + bridge trusses, village compounds with pitched roofs, industrial zone with cranes/stack geometry, forest canopy clusters, landmark label chips with icon marks; objective world markers with bridge/factory glyphs.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_OBJECTIVE_TERRAIN

## Pair 5 — P0-05_HIGH_INTENSITY_COMBAT

- TARGET_FILE=docs/visual_targets/battle01/P0-05_HIGH_INTENSITY_COMBAT.png
- PRESERVE=Dense-but-legible combat presentation: unit damage feedback, threat/under-fire indicators, contested objective state, event alert stream, combat effect density (muzzle flash, tracers, impacts, destruction), selected-unit damage panel.
- ADAPT_TO_CURRENT_GAMEPLAY=No artillery/air-strike/mortar/support-request systems exist; only direct-fire combat, supply, capture and intel events are real and therefore presented. Combat info panel shows real Formation HP/ammo/order only.
- DO_NOT_COPY=artillery strike zones, air-strike timers, support request buttons, loss heatmap of nonexistent formations, post-combat scoring.
- CURRENT_RUNTIME_GAP=Combat FX are single lines/circles; no muzzle flash or impact burst; damage feedback is text; alert stream is plain text.
- IMPLEMENTATION_ACTION=Muzzle flash + tracer + impact burst + smoke/destruction FX in formation.gd; under-fire direction indicator; alert entries with icon prefixes; contested objective ring treatment; high-intensity evidence scene forces multi-unit engagement at Industrial.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_HIGH_INTENSITY

## Pair 6 — P1-06_UNIT_READABILITY_ZOOM

- TARGET_FILE=docs/visual_targets/battle01/P1-06_UNIT_READABILITY_ZOOM.png
- PRESERVE=NEAR/MID/FAR readability: head marker + callsign + selection bar; status bar color language (blue healthy / amber warning / red critical); role silhouette/volume language; zoom threshold behavior (far = tactical symbol mode).
- ADAPT_TO_CURRENT_GAMEPLAY=Marker/callsign conventions map to existing Formation roles (RECON/INFANTRY/IFV/ARMOR/LOGISTICS). No new units.
- DO_NOT_COPY=Exact px font sizes from the guide; individual-soldier micro presentation.
- CURRENT_RUNTIME_GAP=Role glyphs are circles/rects; callsign drawn in fallback font only at close zoom; no selection bar; status is text-only.
- IMPLEMENTATION_ACTION=Role glyph refinement per role silhouette; callsign head marker with background chip at LOD 0/selected; selection bar under selected formations; status pips (HP/ammo) as icon language; order icon glyphs; keep LOD thresholds behavior-identical.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_NEAR_MID_FAR (near + far captures)

## Pair 7 — P1-07_BUILDING_OBJECTIVE_STATE

- TARGET_FILE=docs/visual_targets/battle01/P1-07_BUILDING_OBJECTIVE_STATE.png
- PRESERVE=Objective functional-state language: neutral/our control/enemy control/contested/destroyed/locked states; world marker composition (icon + state ring + progress); unavailability reason presentation; minimap marker rules.
- ADAPT_TO_CURRENT_GAMEPLAY=Only the states the frozen runtime actually has: NEUTRAL (not used on live map), AI control, PLAYER control, CONTESTED, CAPTURING, LOCKED_FOR_PLAYER_CAPTURE. "Destroyed" exists only for destroyed Formations, not buildings — not presented on objectives.
- DO_NOT_COPY=Building production/queue states; repair states; building HP; "captured" flag states beyond the two formal objectives.
- CURRENT_RUNTIME_GAP=Objective markers are plain circles/squares with fallback-font titles; locked state is a padlock arc + text; no icon identity for bridgehead vs industrial.
- IMPLEMENTATION_ACTION=Objective world marker system: ownership ring + state ring + progress arc + bridge/factory glyph + locked overlay icon; contested cross-hatch; title chip with state color; minimap objective glyphs with the same state language.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_OBJECTIVE_FUNCTION_STATE

## Pair 8 — FINAL-01_FINAL_BATTLE_PRESENTATION

- TARGET_FILE=docs/visual_targets/battle01/FINAL-01_FINAL_BATTLE_PRESENTATION.png
- PRESERVE=Overall product look: battlefield dominant, mission objectives + tactical tips top-left, enemy intel, capture status strip, unit info panel, command icons, minimap, legend/control hints, finished modern tactical RTS feel.
- ADAPT_TO_CURRENT_GAMEPLAY=All panels present only real gameplay state per V2 spec section 1; controls hint matches actual bindings (LMB box select / RMB move / F supply / X withdraw / 1-2 reserve).
- DO_NOT_COPY=Resource tabs, production queue, obsolete objective structure, fabricated attack/menu controls.
- CURRENT_RUNTIME_GAP=Overall composition exists but reads as diagnostic tool: raw debug text, no icons, no panel identity, no legend.
- IMPLEMENTATION_ACTION=Compose the full HUD per pairs 1/3/7 plus a compact control-hint legend; unified typography scale; final evidence capture at the normal battle zoom showing the whole presentation.
- RUNTIME_EVIDENCE_SCENE=RUNTIME_FINAL_BATTLE_PRESENTATION

---

## Implementation asset list (presentation assets only, no new systems)

- assets/ui/icon_command_move.svg / hold / withdraw / supply / attack / stop
- assets/ui/icon_role_recon / infantry / ifv / armor / logistics
- assets/ui/icon_objective_bridge / industrial / rally_west / rally_forward
- assets/ui/icon_status_low_ammo / damaged / destroyed / supply_charges / reserve_infantry / reserve_armor / intel / mission / victory / defeat / alert_critical / alert_tactical / alert_info
- assets/ui/battle01_ui_style.gd — shared color/typography/style constants (single source for the reworked presentation layer)

## Frozen acceptance gates (from REWORK_V1 section 10)

- GAMEPLAY_REGRESSION=PASS
- FOW_LEGALITY=PASS
- VISUAL_READABILITY=PASS
- TARGET_ALIGNMENT=PASS
- FINAL_PRESENTATION=PASS
- DEBUG_PROTOTYPE_FEEL=NO
- ACTUAL_RUNTIME_COMPARISON_EVIDENCE=PASS