# BATTLE01_REVISED_ROLE_CAPTURE_IMPLEMENTATION_AUDIT_V1

TASK_ID=IMPLEMENT_BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_V1
OWNER_DOMAIN=WINDOW_03_COMBAT_FORMATIONS
CONTROL_OWNER=WINDOW_00_CONTROL
PRODUCT_AUTHORITY=docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md
FORMATION_AUTHORITY=docs/BATTLE01_FORMATION_RULES_V2.md
ENGINE=Godot 4.7.1
RESULT=IMPLEMENTED_RUNTIME_VERIFICATION_BLOCKED
QA_GATE_RESULT=BLOCKED_RUNTIME_EXECUTION_UNAVAILABLE
FULL_PRODUCT_PASS=NO

## Plain-language implementation result

The first revised-gameplay implementation slice is now present in the real Battle01 source. It is not a detached demo.

Implemented behavior:
- Recon / Infantry / IFV / Armor now resolve deterministic damage differently by target class;
- revised Battle01 ammunition capacities are bound to the Formation resources;
- objective capture and objective contest are separate capabilities;
- Infantry and IFV can establish ownership;
- Armor can contest/deny but cannot establish ownership;
- Recon and Logistics cannot capture or contest;
- match defeat logic now prevents an unwinnable softlock when only non-capturing Blue units survive and no Infantry reserve option remains.

This source implementation is not yet accepted as a runtime PASS because the current GitHub Actions runs terminate before executing any job steps. No Godot 4.7.1 parse/runtime result exists for this revision yet.

## Source changes audited

Current implementation touches only the intended domains:
- FormationDefinition and Formation resources;
- BattleFormation combat resolution;
- BattleObjective capture/contest evaluation;
- formal combat roster validation;
- PlayerWarFlow defeat viability;
- focused regression tests;
- Godot verification workflow;
- current/superseded rule documentation.

The closeout compare against `a7ed25c6dadc725e2fa750d3e9b3070f8958b00a` did not modify `Battle01.tscn`, the Node3D world foundation, Camera3D, HUD implementation, or the Enemy AI controller implementation.

## Revised runtime bindings

Ammo:
- Recon 18
- Infantry 24
- IFV 28
- Armor 16

Capture / contest:
- Recon NO / NO
- Infantry YES / YES
- IFV YES / YES
- Armor NO / YES
- Logistics NO / NO

Representative deterministic damage resolutions:
- Recon -> Heavy Armor: round(8 x 0.20) = 2
- Infantry -> Heavy Armor: round(14 x 0.35) = 5
- IFV -> Soft: round(24 x 1.25) = 30
- IFV -> Heavy Armor: round(24 x 0.55) = 13
- Armor -> Light Armor: round(45 x 1.35) = 61

## Focused regression coverage added

`tests/battle01_role_capture_v2_smoke.gd` covers:
- revised ammunition values;
- role capture/contest flags;
- representative damage-matrix results;
- a real BattleFormation combat event using resolved target-specific damage;
- Recon cannot steal an objective;
- Infantry can establish ownership;
- Armor cannot establish ownership;
- Armor can deny an opposing capture;
- unlocked unused Infantry reserve opportunity prevents premature defeat;
- committing the one reserve to Armor after all Blue capture-capable formations are lost produces Defeat instead of an unwinnable softlock.

Existing formal-roster smoke was updated for revised semantics.
The verification workflow now also includes the focused role/capture smoke, formal roster regression, logistics/match-flow regression, and final-objective AI regression.

## Runtime verification blocker

Observed workflow run:
- workflow: Godot 4.7.1 Runtime Verify
- run id: 32822582978
- source commit: `9dd9350401b3eefffafc45e3b474560370a29b02`
- conclusion: failure
- job: `Headless parse and runtime smoke`
- job steps returned: none
- decoded job log: unavailable / no executed Godot step evidence

Therefore this run is non-diagnostic for game code. It cannot be counted as a code failure, but it also cannot be counted as a runtime PASS.

## Cleanup audit

- an accidental temporary marker created during branch preparation was immediately removed and is absent from the active tree;
- superseded Formation V1 gameplay values were removed from active authority and replaced by a compact V1 redirect plus current V2 rules;
- superseded Logistics/Objectives V1 forward-authority text was removed from the active tree and replaced by a redirect to the revised product contract; full historical text remains in Git history;
- stale presentation comments pointing at deleted rejected-visual documents were removed while editing the affected runtime scripts;
- no project ZIP, duplicate backup, screenshot evidence bundle, generated build, or redundant runtime artifact was retained.

ACTIVE_PROJECT_STATE_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Known remaining work

This slice intentionally does not yet implement:
- Formation-level RESUPPLY rendezvous intent;
- real RED ammunition resupply;
- seeded RED pre-match defense postures;
- North foot-access / Central / South route-identity geometry changes;
- ADVANCE / HOLD FIRE / revised commander-intent closure;
- pre-battle staging;
- final-art / VFX production.

Those remain downstream work and must not be confused with this first combat/ground-control implementation slice.

## Required next gate

Before this slice can receive QA PASS, run Godot 4.7.1 against current main and prove the focused role/capture test plus the directly affected roster, logistics/match-flow and final-objective AI regressions.

NEXT_ACTION=RUNTIME_VERIFY_REVISED_ROLE_CAPTURE_V1
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_OR_AVAILABLE_GODOT_RUNNER
