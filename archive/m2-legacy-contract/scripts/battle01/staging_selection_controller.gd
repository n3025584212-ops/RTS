class_name BattleStagingSelectionController
extends BattleSelectionController

func issue_move(world_target: Vector2, spacing: float = -1.0) -> int:
	var staging: Node = get_parent().get_node_or_null("PreBattleStaging")
	if staging != null and staging.has_method("is_staging_active") and bool(staging.call("is_staging_active")):
		return int(staging.call("queue_initial_for_selected", "MOVE", world_target, spacing))
	return super.issue_move(world_target, spacing)

func issue_advance(world_target: Vector2, spacing: float = -1.0) -> int:
	var staging: Node = get_parent().get_node_or_null("PreBattleStaging")
	if staging != null and staging.has_method("is_staging_active") and bool(staging.call("is_staging_active")):
		return int(staging.call("queue_initial_for_selected", "ADVANCE", world_target, spacing))
	return super.issue_advance(world_target, spacing)
