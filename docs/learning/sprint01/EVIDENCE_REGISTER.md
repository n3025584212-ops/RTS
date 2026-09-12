# Learning Sprint 01 — Evidence Register

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-13
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Status vocabulary

- `OBSERVED`: directly visible in inspected source/artifact/runtime.
- `REPRODUCED`: independently recreated and verified by us.
- `INFERRED`: supported by multiple observed facts but not directly proven.
- `HYPOTHESIS`: plausible claim requiring test.
- `UNKNOWN`: evidence currently insufficient.
- `REJECTED`: contradicted by inspected evidence or reproduction.

No item may be silently upgraded from INFERRED/HYPOTHESIS to fact.

## Window 03 required audit fields for new core claims

Every new core claim should add, where applicable:

PROJECT=
AUTHORITATIVE_SOURCE=
SOURCE_LOCATION=
SOURCE_TYPE=SOURCE_CODE|OFFICIAL_DOC|RUNTIME|SECONDARY
BRANCH_TAG_RELEASE=
COMMIT=
SOURCE_DATE=
RUNTIME_SEMANTICS=
HIDDEN_ASSUMPTIONS=
ALTERNATIVE_EXPLANATION=
COUNTEREXAMPLE_SEARCH=
COUNTEREXAMPLE_RESULT=
GENERALIZATION_LEVEL=SOURCE_FACT|PROJECT_SPECIFIC_INFERENCE|CROSS_PROJECT_PATTERN|DESIGN_RECOMMENDATION|UNSUPPORTED_GENERALIZATION
WINDOW_03_VERDICT=PENDING|PASS|DOWNGRADE|FIX|REJECT|UNKNOWN
ALLOWED_FINAL_WORDING=

The six mandatory Window 03 checks are:
1. PRIMARY_SOURCE_INTEGRITY
2. VERSION_IDENTITY
3. RUNTIME_SEMANTICS
4. GENERALIZATION_BOUNDARY
5. ALTERNATIVE_EXPLANATIONS
6. COUNTEREXAMPLE_SEARCH

## Active version warning

`0ad/0ad` on GitHub is archived and identifies itself as a deprecated Git mirror migrated to Wildfire Games Gitea on 2024-08-20.

Therefore:
- GitHub `master` evidence is historical unless exact version matching is proven;
- it must not be cited as current 2026 / Release-28 source by default;
- Release-28 source-code claims require version-matched authoritative source evidence;
- Window 03 must downgrade/fix/reject claims that blur historical mirror evidence with current implementation.

---

## E000 — FRONTLINE technical presence did not prove production quality

CLAIM=FRONTLINE can import assets, run Godot 4.7.1 and capture a 1920x1080 scene, while still failing user visual acceptance.
STATUS=OBSERVED
SOURCE=FRONTLINE repo historical Golden Scene evidence; former Issue #33 / PR #34 / CURRENT_STATE history.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The technical import/runtime/capture pipeline worked while the user rejected the visual result.
WHAT_IT_DOES_NOT_PROVE=Why the visual result failed technically, or which production method will fix it.

---

## E001 — 0 A.D. Release 28 exposes both build source and game data

CLAIM=The official 0 A.D. Release 28 source distribution provides both build-source and game-data archives needed to build the release from source.
STATUS=OBSERVED
SOURCE=https://play0ad.com/download/source/
SOURCE_TYPE=OFFICIAL_DOC
BRANCH_TAG_RELEASE=Release_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=Official source page instructs users to download both `unix-build` and `unix-data` tarballs for Release 28.
WHAT_IT_DOES_NOT_PROVE=How every game subsystem works internally or that the archived GitHub mirror exactly matches Release 28.
WINDOW_03_VERDICT=PENDING

---

## E002 — 0 A.D. engine/game/content responsibilities are split across code and data

CLAIM=0 A.D. officially describes a C++ engine (Pyrogenesis), JavaScript gameplay scripting, and data files for modifiable game logic/art/data.
STATUS=OBSERVED
SOURCE=https://play0ad.com/community/participate/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=Wildfire Games explicitly describes the engine language, scripting language and data-driven modification model.
WHAT_IT_DOES_NOT_PROVE=The detailed call path for a player command, the exact Release-28 runtime boundary, or the best architecture for FRONTLINE.
WINDOW_03_VERDICT=PENDING

---

## E003 — archived 0 A.D. GitHub mirror exposes integrated game-data surfaces

CLAIM=The archived `0ad/0ad` GitHub mirror contains art, audio, GUI, maps, shaders and simulation trees under its public game-data tree.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror tree visibly contains these production/content areas.
WHAT_IT_DOES_NOT_PROVE=That this exact tree is Release 28 or current 2026 source; that each directory maps one-to-one to a runtime subsystem; or the runtime interaction among them.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical archived 0 A.D. GitHub mirror contains these directories; do not call this current Release-28 source without version matching.

---

## E004 — archived 0 A.D. GitHub simulation tree contains AI/components/data/helpers/templates

CLAIM=The archived `0ad/0ad` GitHub mirror simulation tree contains AI, components, data, helpers and templates directories.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/simulation
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror tree contains these directories.
WHAT_IT_DOES_NOT_PROVE=Their runtime interaction; that this exact structure is unchanged in Release 28; or that any one directory defines the complete gameplay boundary.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical mirror evidence only until Release-28-matched source is traced.

---

## E005 — archived 0 A.D. GitHub map tree contains multiple map families

CLAIM=The archived `0ad/0ad` GitHub mirror map tree contains random maps, scenarios, scripts, skirmishes and tutorials.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/maps
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror supports multiple visible map/content authoring families.
WHAT_IT_DOES_NOT_PROVE=That the exact Release-28 layout is identical or how terrain, settlements and tactical spaces are authored/generated internally.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical mirror map-family evidence only until Release-28-matched source/data is inspected.

---

## E006 — 0 A.D. Release 28 is a shipped release, not merely a tutorial sample

CLAIM=0 A.D. Release 28 “Boiorix” was released on 2026-02-18 and was announced as the project's first release without the Alpha label.
STATUS=OBSERVED
SOURCE=https://play0ad.com/
SOURCE_TYPE=OFFICIAL_DOC
BRANCH_TAG_RELEASE=Release_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The official project announcement describes the release and its status.
WHAT_IT_DOES_NOT_PROVE=That its visual quality, architecture or gameplay design should be copied by FRONTLINE.
WINDOW_03_VERDICT=PENDING

---

## E007 — Recoil is intentionally an RTS-scale engine with Lua game APIs

CLAIM=Recoil presents itself as a battle-tested open-source RTS engine with a Lua API and support for thousands of complex units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=This is the engine project's explicit stated scope/capability goal and API model.
WHAT_IT_DOES_NOT_PROVE=That Recoil is the right engine for FRONTLINE, or that a stated capability automatically matches our production requirements.
WINDOW_03_VERDICT=PENDING

---

## E008 — Recoil exposes unit definitions and unit command APIs at game layer

CLAIM=Recoil's documented game layer uses Lua unit definitions and exposes APIs for issuing orders to units/arrays/maps of units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/docs/guides/getting-started/unit-types-basics/ ; https://recoilengine.org/docs/lua-api/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=Documented examples/API exist for unit defs and command issuing.
WHAT_IT_DOES_NOT_PROVE=BAR's exact high-level production chain or FRONTLINE's required command abstraction.
WINDOW_03_VERDICT=PENDING

---

## E009 — Beyond All Reason is a real game running on Recoil with separate game/engine/lobby boundaries

CLAIM=Beyond All Reason is game code running on the Recoil RTS Engine, while its development documentation also identifies a separate lobby/client component.
STATUS=OBSERVED
SOURCE=https://github.com/beyond-all-reason/Beyond-All-Reason ; https://github.com/beyond-all-reason/RecoilEngine
SOURCE_TYPE=SOURCE_CODE
WHAT_THE_SOURCE_ACTUALLY_PROVES=BAR explicitly identifies itself as game code on Recoil and documents a separate lobby component; Recoil identifies itself as the RTS engine.
WHAT_IT_DOES_NOT_PROVE=How every BAR gameplay/render/content feature is implemented, or that BAR's boundary is preferable for FRONTLINE.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING

---

## E010 — Warzone 2100 is a full open-source 3D RTS with a different script/native boundary

CLAIM=Warzone 2100 is a full open-source 3D RTS whose official scripting documentation uses JavaScript for AIs, campaigns and some game rules on top of its broader native/core implementation.
STATUS=OBSERVED
SOURCE=https://github.com/Warzone2100/warzone2100 ; https://github.com/Warzone2100/warzone2100/blob/master/doc/Scripting.md
SOURCE_TYPE=SOURCE_CODE
WHAT_THE_SOURCE_ACTUALLY_PROVES=The project and its scripting docs explicitly expose a different engine/game scripting boundary suitable as a counterexample pool.
WHAT_IT_DOES_NOT_PROVE=That its asset/render pipeline or architecture is appropriate for FRONTLINE.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING

---

## E011 — Primary-reference choice

CLAIM=0 A.D. Release 28 is a useful first reference for tracing one integrated RTS production chain among the currently inspected candidates.
STATUS=INFERRED
SOURCE=E001–E010.
WHAT_THE_SOURCE_ACTUALLY_PROVES=0 A.D. provides official Release-28 source/data distribution and official Release-28 component documentation, while BAR/Recoil and Warzone provide materially different cross-check architectures.
WHAT_IT_DOES_NOT_PROVE=That 0 A.D.'s architecture is universally superior, that the archived GitHub mirror is Release-28 source, or that its methods should be copied into FRONTLINE.
ALTERNATIVE_EXPLANATION=Another project may prove easier to trace end-to-end once authoritative Release-28 source availability is tested.
COUNTEREXAMPLE_SEARCH=BAR/Recoil and Warzone 2100.
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
WINDOW_03_VERDICT=FIX
ALLOWED_FINAL_WORDING=0 A.D. Release 28 remains the first candidate reference, conditional on obtaining authoritative version-matched source/data for the chain being traced.
TEST=Trace one actual playable action end-to-end through authoritative Release-28 source/data. If version-matched tracing is impractical or fragmented, reconsider the primary reference.

---

## E012 — Generated/design images are insufficient evidence of manufacturability

CLAIM=A visually coherent target image does not by itself establish an asset, level, material, lighting, VFX or runtime production path.
STATUS=OBSERVED
SOURCE=FRONTLINE historical sequence: approved visual targets / Golden Frame versus rejected actual Godot results.
WHAT_THE_SOURCE_ACTUALLY_PROVES=In this project, visual target generation and real-engine manufacturing capability diverged materially.
WHAT_IT_DOES_NOT_PROVE=That generated images are useless; they remain valid outcome proposals when clearly labelled and backed by later manufacturability work.
WINDOW_03_VERDICT=PENDING

---

## Open unknowns before reproduction

### U001
CLAIM=Which exact authoritative 0 A.D. Release 28 map/slice is the best minimal end-to-end trace target?
STATUS=UNKNOWN
NEXT=Inspect Release 28 source/data distribution and choose a slice with map/world data, selectable units, movement, combat and visible UI feedback.

### U002
CLAIM=Which 0 A.D. world-authoring rules are authored versus procedural versus engine-imposed in Release 28?
STATUS=UNKNOWN
NEXT=Inspect version-matched Release 28 scenario/skirmish/random map data/scripts and relevant official editor/source material.

### U003
CLAIM=Which production patterns learned from 0 A.D. remain useful under a Godot 4.7.1 implementation?
STATUS=UNKNOWN
NEXT=Do not answer until the chain is traced, cross-checked and independently reproduced.

### U004
CLAIM=Whether FRONTLINE should retain Godot after end-to-end learning.
STATUS=UNKNOWN
NEXT=Engine choice remains open; do not reopen it from theory alone. Evaluate only after reproduction exposes actual requirements and friction.
