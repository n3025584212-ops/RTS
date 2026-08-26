class_name BattlePreBattleStagingRuntimeController
extends BattlePreBattleStagingController

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
