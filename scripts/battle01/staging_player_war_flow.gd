class_name BattleStagingPlayerWarFlow
extends BattlePlayerWarFlow

func try_supply_selected() -> bool:
	if _is_pre_battle_staging_active():
		_staging_feedback("RESUPPLY UNAVAILABLE DURING STAGING")
		return false
	return super.try_supply_selected()

func withdraw_selected(prefer_forward: bool = true) -> int:
	if _is_pre_battle_staging_active():
		_staging_feedback("WITHDRAW UNAVAILABLE DURING STAGING")
		return 0
	return super.withdraw_selected(prefer_forward)

func deploy_reserve(kind: String) -> BattleFormation:
	if _is_pre_battle_staging_active():
		_staging_feedback("RESERVE LOCKED / NOT AVAILABLE DURING STAGING")
		return null
	return super.deploy_reserve(kind)

func _is_pre_battle_staging_active() -> bool:
	var staging: Node = get_parent().get_node_or_null("PreBattleStaging")
	return staging != null and staging.has_method("is_staging_active") and bool(staging.call("is_staging_active"))

func _staging_feedback(message: String) -> void:
	if _hud != null:
		_hud.show_command_feedback(message, "INFO")
	print("FRONTLINE_STAGING_COMMAND_BLOCKED %s" % message)
