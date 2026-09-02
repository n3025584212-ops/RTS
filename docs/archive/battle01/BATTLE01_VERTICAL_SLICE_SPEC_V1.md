# BATTLE01_VERTICAL_SLICE_SPEC_V1

## Product question

Formation级现代战争指挥、侦察、联合兵种、目标争夺、增援/后勤和完整HUD组合起来，是否已经形成值得扩展的游戏？

## Player flow

Start/Briefing → Purchase/Deployment → Opening Recon/Maneuver → First Contact → Plan Adjustment → Combined-Arms Shaping → Capture Bridgehead/Intermediate Objective → Enemy Counterattack → Resupply/Withdraw/Reinforce Decision → Final Push to Industrial Objective → Win/Loss → Restart。

## Candidate battlefield topology

- West: Friendly Base / rear area
- North: Village / complex terrain
- Center: River + bridgehead / main breakthrough axis
- South: Longer maneuver / flank / logistics-threat route
- East: Industrial decisive objective

路线必须能横向互动，不做互相隔离的三线地图。

## Minimum formation roles

- Recon
- Line Infantry
- Mechanized / IFV
- Tank
- Indirect Fire / Artillery
- Logistics

Dedicated ATGM可作为子角色或未来第7类。AA/Air/Helicopter/Engineer默认后置。

## Minimum information model

- Terrain always visible
- Enemy FOW
- UNSEEN / CONTACT / CONFIRMED
- Last Known Position
- LOS separated from Detection
- Recon has stronger Detection
- Buildings/forest/smoke affect LOS
- Firing increases exposure
- Hold Fire supports ambush
- Fire support quality depends on intel quality

## Minimum command set

- MOVE
- FAST MOVE
- ATTACK MOVE / ADVANCE
- HOLD
- HOLD FIRE
- REVERSE / WITHDRAW
- STOP / CANCEL

Contextual commands: UNLOAD, SMOKE, SUPPLY / RETURN, FIRE MISSION.

Support queued orders and control groups.

## Minimum war economy

Limited initial deployment/reserve → combat losses and ammo expenditure → reinforce/resupply/withdraw choices → ground reinforcement arrives from rear space → at least one objective changes maneuver/supply/assembly conditions → damaged formations can preserve combat power.

Traditional mining/tech-tree economy is not a Battle01 gate.

## Enemy AI minimum arc

Recon/Screen → Main Effort → Combined Arms pressure → Objective attack/defense → Preserve Reserve → Evaluate Counterattack → Withdraw/Regroup/Resupply → Final Contest.

AI uses its own knowledge model rather than world truth.

## HUD minimum complete set

- Camera pan / drag / zoom / limits
- Click / box / multi-select
- Control Groups
- Formation Labels
- Objective / Reserve HUD
- Minimap + camera navigation
- Selection Summary
- Selected Formation Status
- Command Panel
- World command feedback
- Purchase / Deployment
- Contact / Confirmed intel markers
- Critical alerts
- Victory / Defeat / Restart

## Combat readability families

Small Arms / HMG-Autocannon / Tank Gun / ATGM / Artillery / Vehicle Destruction / Smoke.

Readability always precedes spectacle.

## Final gate

A Battle01 Vertical Slice PASS requires:

1. PLAYABLE
2. MEANINGFUL_DECISIONS
3. VISUAL_READABILITY
4. TARGET_ALIGNMENT
5. TECHNICAL_HEALTH

Actual play evidence must include at least one Victory, one Defeat, and at least two materially different openings/routes. Automated tests are regression evidence, not a substitute for player-facing validation.
