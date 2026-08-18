# BATTLE01_MULTI_FORMATION_COMMAND_RULES_V1

STATUS=IMPLEMENTED_FOR_VERTICAL_SLICE
ENGINE=Godot 4.7.1

## Player command scope

Battle01 now exposes both BLUE IFV-01 and BLUE RECON-01 as player-commandable formations.

- Left click selects one friendly formation.
- Shift + left click adds/removes a friendly formation from the current selection.
- Dragging a left-mouse selection box selects all friendly selectable formations inside the rectangle.
- Right click issues MOVE to the current selection.
- Multi-formation MOVE uses a small lateral spacing around the target point instead of stacking every formation onto one coordinate.
- Selection rings remain owned by each BattleFormation.
- Selection state and move order distribution are owned by BattleSelectionController.
- Battle01 orchestrates input routing and match flow; it does not own the individual formation movement implementation.
- HUD reports all currently selected formations and their current orders.

## Objective integration

BattleObjective can track multiple friendly formations. Any tracked formation whose FormationDefinition allows capture can contribute by entering the capture radius. Existing contested/capture timing remains unchanged.

## Recon decision loop

The intended minimal player sequence is now executable through the same command system used by normal play:

`select Recon -> move Recon to obtain LOS/contact -> select IFV -> advance IFV -> box-select both -> group move -> destroy enemy -> secure objective`

This turns Recon/LOS from an automated system test into a player-commandable tactical choice.

## Deferred

This V1 does not yet add control groups, queued orders, attack-move, formation facing, pathfinding around blockers, command cards, or formal command preview UI.

## CI acceptance marker

Required runtime marker: `FRONTLINE_MULTI_FORMATION_COMMAND_SMOKE_PASS`.
