# Learning Sprint 01 — Evidence Register

STATUS=INITIAL
WORK_ID=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
DATE=2026-09-12

## Status vocabulary

- `OBSERVED`: directly visible in inspected source/artifact/runtime.
- `REPRODUCED`: independently recreated and verified by us.
- `INFERRED`: supported by multiple observed facts but not directly proven.
- `HYPOTHESIS`: plausible claim requiring test.
- `UNKNOWN`: evidence currently insufficient.
- `REJECTED`: contradicted by inspected evidence or reproduction.

No item may be silently upgraded from INFERRED/HYPOTHESIS to fact.

---

## E000 — FRONTLINE technical presence did not prove production quality

CLAIM=FRONTLINE can import assets, run Godot 4.7.1 and capture a 1920x1080 scene, while still failing user visual acceptance.
STATUS=OBSERVED
SOURCE=FRONTLINE repo historical Golden Scene evidence; former Issue #33 / PR #34 / CURRENT_STATE history.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The technical import/runtime/capture pipeline worked while the user rejected the visual result.
WHAT_IT_DOES_NOT_PROVE=Why the visual result failed technically, or which production method will fix it.

---

## E001 — 0 A.D. Release 28 exposes both build source and game data

CLAIM=The current official 0 A.D. Release 28 source distribution separates/provides both build source and game-data archives needed to build the game from source.
STATUS=OBSERVED
SOURCE=https://play0ad.com/download/source/
WHAT_THE_SOURCE_ACTUALLY_PROVES=Official current source page instructs users to download both `unix-build` and `unix-data` tarballs for Release 28.
WHAT_IT_DOES_NOT_PROVE=How every game subsystem works internally or that the GitHub mirror exactly matches Release 28.

---

## E002 — 0 A.D. engine/game/content responsibilities are split across code and data

CLAIM=0 A.D. uses a C++ engine (Pyrogenesis), JavaScript gameplay scripting, and data files for modifiable game logic/art/data.
STATUS=OBSERVED
SOURCE=https://play0ad.com/community/participate/
WHAT_THE_SOURCE_ACTUALLY_PROVES=Wildfire Games explicitly describes the engine language, scripting language and data-driven modification model.
WHAT_IT_DOES_NOT_PROVE=The detailed call path for a player command or the best architecture for FRONTLINE.

---

## E003 — 0 A.D. public game-data tree exposes integrated production surfaces

CLAIM=The inspectable 0 A.D. public game data contains separate art, audio, GUI, maps, shaders and simulation trees.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public
WHAT_THE_SOURCE_ACTUALLY_PROVES=The repository tree visibly contains these production/content areas in one game-data ecosystem.
WHAT_IT_DOES_NOT_PROVE=That each directory maps one-to-one to a runtime subsystem or that this mirror is the current Release 28 source of truth.

---

## E004 — 0 A.D. simulation tree contains AI, components, data, helpers and templates

CLAIM=The inspectable 0 A.D. simulation tree separates AI, simulation components, data, helpers and templates.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/simulation
WHAT_THE_SOURCE_ACTUALLY_PROVES=The source tree structure contains these directories.
WHAT_IT_DOES_NOT_PROVE=Their runtime interaction; that must be traced through actual files/code.

---

## E005 — 0 A.D. map content includes several authored/generated map families

CLAIM=The inspectable 0 A.D. map tree contains random maps, scenarios, scripts, skirmishes and tutorials.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/maps
WHAT_THE_SOURCE_ACTUALLY_PROVES=The project supports multiple map/content authoring forms visible in the repository structure.
WHAT_IT_DOES_NOT_PROVE=How terrain, settlements and tactical spaces are authored/generated internally; map files/scripts must be inspected.

---

## E006 — 0 A.D. Release 28 is a currently shipped project, not merely a tutorial sample

CLAIM=0 A.D. Release 28 “Boiorix” was released on 2026-02-18 and was announced as the project's first release without the Alpha label.
STATUS=OBSERVED
SOURCE=https://play0ad.com/
WHAT_THE_SOURCE_ACTUALLY_PROVES=The project is actively released and the official announcement describes Release 28 as the first without the Alpha label.
WHAT_IT_DOES_NOT_PROVE=That its visual quality or gameplay design should be copied by FRONTLINE.

---

## E007 — Recoil is intentionally an RTS-scale engine with Lua game APIs

CLAIM=Recoil presents itself as a battle-tested open-source RTS engine with a Lua API and support for thousands of complex units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/
WHAT_THE_SOURCE_ACTUALLY_PROVES=This is the engine project's explicit stated scope/capability goal and API model.
WHAT_IT_DOES_NOT_PROVE=That Recoil is the right engine for FRONTLINE, or that a stated capability automatically matches our production requirements.

---

## E008 — Recoil exposes unit definitions and unit command APIs at game layer

CLAIM=Recoil's documented game layer uses Lua unit definitions and exposes APIs for issuing orders to units/arrays/maps of units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/docs/guides/getting-started/unit-types-basics/ ; https://recoilengine.org/docs/lua-api/
WHAT_THE_SOURCE_ACTUALLY_PROVES=Documented examples/API exist for unit defs and command issuing.
WHAT_IT_DOES_NOT_PROVE=BAR's exact high-level production chain or FRONTLINE's required command abstraction.

---

## E009 — Beyond All Reason is a real game running on Recoil

CLAIM=Beyond All Reason runs on the Recoil engine, sharing that engine ecosystem with Zero-K.
STATUS=OBSERVED
SOURCE=https://www.beyondallreason.info/faq/what-are-the-differences-between-bar-and-zerok ; https://recoilengine.org/
WHAT_THE_SOURCE_ACTUALLY_PROVES=BAR and Recoil officially identify the engine relationship.
WHAT_IT_DOES_NOT_PROVE=How every BAR gameplay/render/content feature is implemented; source files must be inspected.

---

## E010 — Warzone 2100 is a full open-source 3D RTS with inspectable scripting/content interfaces

CLAIM=Warzone 2100 is a full free/open-source 3D RTS whose AI, maps and campaigns can be scripted in JavaScript, with repository docs for scripting, model format and animation.
STATUS=OBSERVED
SOURCE=https://github.com/Warzone2100/warzone2100
WHAT_THE_SOURCE_ACTUALLY_PROVES=The project README explicitly describes the game, buildability and those scripting/content documentation surfaces.
WHAT_IT_DOES_NOT_PROVE=That its older asset/render pipeline is appropriate for FRONTLINE's target visual quality.

---

## E011 — Primary-reference choice

CLAIM=0 A.D. Release 28 is the best first reference for tracing one integrated RTS production chain among the currently inspected candidates.
STATUS=INFERRED
SOURCE=E001–E010.
WHAT_THE_SOURCE_ACTUALLY_PROVES=0 A.D. offers current official source+data and an inspectable integrated game-data structure covering maps, simulation, AI, GUI, art and shaders; BAR/Recoil and Warzone provide strong cross-checks.
WHAT_IT_DOES_NOT_PROVE=That 0 A.D.'s architecture is universally superior or should be copied into FRONTLINE.
TEST=Trace one actual playable action end-to-end through current Release 28 source/data. If the chain is too fragmented or evidence is insufficient, downgrade and reconsider primary reference.

---

## E012 — Generated/design images are insufficient evidence of manufacturability

CLAIM=A visually coherent target image does not by itself establish an asset, level, material, lighting, VFX or runtime production path.
STATUS=OBSERVED
SOURCE=FRONTLINE historical sequence: approved visual targets / Golden Frame versus rejected actual Godot results.
WHAT_THE_SOURCE_ACTUALLY_PROVES=In this project, visual target generation and real-engine manufacturing capability diverged materially.
WHAT_IT_DOES_NOT_PROVE=That generated images are useless; they remain valid outcome proposals when clearly labelled and backed by later manufacturability work.

---

## Open unknowns before reproduction

### U001
CLAIM=Which exact 0 A.D. Release 28 map/slice is the best minimal end-to-end trace target?
STATUS=UNKNOWN
NEXT=Inspect Release 28 data/maps and choose a slice with map/world data, selectable units, movement, combat and visible UI feedback.

### U002
CLAIM=Which 0 A.D. world-authoring rules are authored versus procedural versus engine-imposed?
STATUS=UNKNOWN
NEXT=Inspect actual scenario/skirmish/random map data/scripts and Atlas/editor documentation/source.

### U003
CLAIM=Which production patterns learned from 0 A.D. remain useful under a Godot 4.7.1 implementation?
STATUS=UNKNOWN
NEXT=Do not answer until the chain is traced and independently reproduced.

### U004
CLAIM=Whether FRONTLINE should retain Godot after end-to-end learning.
STATUS=UNKNOWN
NEXT=Engine choice remains open; do not reopen it from theory alone. Evaluate only after reproduction exposes actual requirements and friction.
