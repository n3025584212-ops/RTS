class_name BattlePreBattleStagingRuntimeController
extends BattlePreBattleStagingController

var _live_reserve_panel: Control

func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--battle01-ci-"):
			_staging_active = false
			_battle_elapsed = 0.0
			print("FRONTLINE_PRE_BATTLE_STAGING_LEGACY_CI_BYPASS arg=%s" % argument)
			return
	super._ready()

func is_staging_position_valid(formation: BattleFormation, point: Vector2) -> bool:
	if not super.is_staging_position_valid(formation, point):
		return false
	var mobility: String = _navigation.mobility_for_formation(formation)
	var origin: Vector2 = get_staged_position_for(formation)
	if origin.distance_to(point) <= 0.001:
		return true
	return not _navigation.find_path_for_mobility(origin, point, mobility).is_empty()

func _freeze_node(node: Node) -> void:
	if node == null or node == self:
		return
	if not _saved_process_state.has(node):
		_saved_process_state[node] = {
			"process": node.is_processing(),
			"physics": node.is_physics_processing(),
			"input": node.is_processing_input(),
			"unhandled_input": node.is_processing_unhandled_input(),
			"unhandled_key": node.is_processing_unhandled_key_input(),
			"shortcut_input": node.is_processing_shortcut_input(),
		}
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process_unhandled_key_input(false)
	node.set_process_shortcut_input(false)

func _restore_simulation_processes() -> void:
	for key: Variant in _saved_process_state.keys():
		var node: Node = key as Node
		if node == null or not is_instance_valid(node):
			continue
		var state: Dictionary = _saved_process_state[key]
		node.set_process(bool(state.get("process", true)))
		node.set_physics_process(bool(state.get("physics", false)))
		node.set_process_input(bool(state.get("input", false)))
		node.set_process_unhandled_input(bool(state.get("unhandled_input", false)))
		node.set_process_unhandled_key_input(bool(state.get("unhandled_key", false)))
		node.set_process_shortcut_input(bool(state.get("shortcut_input", false)))
	_saved_process_state.clear()

func _build_staging_ui() -> void:
	super._build_staging_ui()
	_live_reserve_panel = _battle.get_node_or_null("HUD/Root/Reserve") as Control
	if _live_reserve_panel != null:
		_live_reserve_panel.visible = false
	_refresh_staging_ui()

func _refresh_staging_ui() -> void:
	if _roster_label == null:
		return
	var lines: PackedStringArray = []
	for formation: BattleFormation in _active_blue:
		var intent: String = get_initial_intent_for(formation)
		var target_text: String = ""
		if intent != INTENT_HOLD:
			var target: Vector2 = get_initial_target_for(formation)
			target_text = " -> (%d,%d)" % [int(target.x), int(target.y)]
		var fire_text: String = "HOLD FIRE=N/A"
		if formation.can_attack:
			fire_text = "HOLD FIRE=%s" % ("ON" if formation.is_hold_fire_enabled() else "OFF")
		lines.append("%s · ROLE=%s · (%d,%d) · %s%s · %s" % [
			formation.display_name,
			formation.get_role(),
			int(formation.global_position.x),
			int(formation.global_position.y),
			intent,
			target_text,
			fire_text,
		])
	_roster_label.text = "\n".join(lines)
	if _start_button != null:
		_start_button.disabled = not all_staged_positions_valid()

func _start_battle_internal(legacy_auto_start: bool) -> bool:
	var started: bool = super._start_battle_internal(legacy_auto_start)
	if started and _live_reserve_panel != null:
		_live_reserve_panel.visible = true
	return started
