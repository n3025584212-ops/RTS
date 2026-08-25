# BATTLE01_FORMATION_RULES_V2

STATUS=CURRENT_FOR_REVISED_IMPLEMENTATION
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=resources/formations/*.tres
PRODUCT_AUTHORITY=docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md
SUPERSEDES=docs/BATTLE01_FORMATION_RULES_V1.md

This document is the compact current Formation/runtime binding for the revised Battle01 implementation. The `.tres` resources remain the executable source of truth.

| Role | Target class | HP | Base damage | Range | Fire interval | Ammo | Move | Detection | Capture | Contest | Special |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|
| Recon | SOFT | 70 | 8 | 220 | 0.75s | 18 | 170 | 520 | NO | NO | longest detection |
| Infantry | SOFT | 100 | 14 | 220 | 0.90s | 24 | 115 | 320 | YES | YES | ground control |
| IFV | LIGHT_ARMOR | 180 | 24 | 280 | 0.80s | 28 | 125 | 340 | YES | YES | mobile anti-soft/fire support |
| Armor | HEAVY_ARMOR | 280 | 45 | 300 | 1.50s | 16 | 85 | 300 | NO | YES | heavy direct fire / denial |
| Artillery definition | SOFT | 90 | 40 | 650 | 3.00s | 12 | 75 | 180 | NO | NO | not active Battle01 roster |
| Logistics | LOGISTICS | 120 | 0 | 0 | n/a | 0 | 100 | 220 | NO | NO | supply capacity 2 |

## Deterministic role effectiveness

| Attacker | SOFT | LIGHT_ARMOR | HEAVY_ARMOR | LOGISTICS |
|---|---:|---:|---:|---:|
| Recon | 1.00 | 0.40 | 0.20 | 0.75 |
| Infantry | 1.00 | 0.70 | 0.35 | 1.00 |
| IFV | 1.25 | 1.00 | 0.55 | 1.00 |
| Armor | 0.90 | 1.35 | 1.00 | 1.00 |

Resolved damage is `base_damage × fixed_role_multiplier`, deterministically rounded. Every attack still consumes exactly one ammunition unit.

No hit chance, critical hit, random penetration, suppression, morale, armor-facing or component-damage simulation is introduced by V2.

## Objective responsibility

- Capture means a Formation may advance objective ownership during the 15-second continuous uncontested transfer.
- Contest means a Formation may deny/reset an opposing capture while physically present.
- Infantry and IFV can capture and contest.
- Armor can contest but cannot establish ownership.
- Recon and Logistics neither capture nor contest.

## Current implementation binding

The revised runtime implementation is expected to expose these semantics through `FormationDefinition`, `BattleFormation`, `BattleObjective`, the formal roster, and match-flow logic. Any older document or test that states the superseded V1 ammo/capture semantics is historical rather than current product authority.
