# BATTLE01_FORMATION_RULES_V1

STATUS=FROZEN_FOR_IMPLEMENTATION
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=resources/formations/*.tres

This document freezes the first playable Battle01 Formation role set and implementation constants. Later balance changes require an explicit revision; code must not hard-code alternate values.

| Role | HP | Damage | Range | Fire interval | Ammo | Move speed | Detection | Capture | Special |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| Recon | 70 | 8 | 220 | 0.75s | 40 | 170 | 520 | YES | highest detection |
| Line Infantry | 100 | 14 | 220 | 0.90s | 36 | 115 | 320 | YES | baseline line unit |
| Mechanized IFV | 180 | 24 | 280 | 0.80s | 48 | 125 | 340 | YES | mobile protected fire support |
| Main Battle Tank | 280 | 45 | 300 | 1.50s | 24 | 85 | 300 | YES | local breakthrough / heavy direct fire |
| Indirect Fire Battery | 90 | 40 | 650 | 3.00s | 12 | 75 | 180 | NO | indirect_fire=YES |
| Logistics Column | 120 | 0 | 0 | n/a | 0 | 100 | 220 | NO | can_attack=NO; supply_capacity=2 |

## Structural rules

- FormationDefinition is the single source of truth for role constants.
- BattleFormation reads its combat/mobility/capture capabilities from FormationDefinition at runtime.
- Attacking formations consume exactly 1 ammo per attack event.
- A formation with current_ammo=0 cannot fire.
- Logistics cannot attack or capture objectives.
- Artillery cannot capture objectives.
- Capture eligibility is checked by the objective system, not by HUD code.
- Battle01 currently uses BLUE IFV-01 versus RED INF-01 only as the minimal combat integration path; the six definitions are all load-validated by CI.
- This V1 does not yet implement FOW, target-class restrictions, suppression, armor penetration, transport, artillery fire-mission UI, or resupply transfer behavior. Those are separate tasks.
