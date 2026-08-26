class_name BattlePreBattleStagingController
extends Node

signal staging_started
signal staging_ended
signal staging_feedback(message: String)

const INTENT_HOLD: String = "HOLD"
const INTENT_MOVE: String = "MOVE"
const INTENT_ADVANCE: String = "ADVANCE"
const MIN_SEPARATION: float = 160.0
const STAGING_POLYGON := PackedVector2Array([
	Vector2(280.0, 480.0),
	Vector2(680.0, 480.0),
	Vector2(800.0, 600.0),
	Vector2(840.0, 760.0),
	Vector2(900.0, 900.0),
	Vector2(840.0, 1040.0),
	Vector2(800.0, 1200.0),
	Vector2(680.0, 1320.0),
	Vector2(280.0, 1320.0),
])

var _battle: Node2D
var _navigation: BattleNavigation
var _selection: BattleSelectionController
var _hud: BattleHUD
var _roster: BattleFormalCombatRoster
var _central: BattleObjective
var _industrial: BattleObjective
var _world3d: Node3D

var _active_blue: Array[BattleFormation] = []
var _staged_positions: Dictionary = {}
var _initial_intents: Dictionary = {}
var _saved_process_state: Dictionary = {}
var _staging_active: bool = true
var _keep_staging_for_test: bool = false
var _battle_elapsed: float = 0.0
var _t0_activation_count: int = 0

var _drag_formation: BattleFormation
var _drag_origin: Vector2 = Vector2.ZERO
var _drag_preview_valid: bool = false

var _ui_layer: CanvasLayer
var _ui_panel: PanelContainer
var _banner_label: Label
var _roster_label: Label
var _status_label: Label
var _start_button: Button
var _clear_button: Button
var _hold_fire_button: Button

var _boundary_root: Node3D
var _preview_marker: MeshInstance3D
var _valid_material: StandardMaterial3D
var _invalid_material: StandardMaterial3D
var _ui_refresh_accumulator: float = 0.0

func _ready() -> void:
	_battle = get_parent() as Node2D
	if _battle == null:
		push_error("PreBattleStaging requires the Battle01 root as parent.")
		return
	_navigation = _battle.get_node_or_null("Navigation") as BattleNavigation
	_selection = _battle.get_node_or_null("SelectionController") as BattleSelectionController
	_hud = _battle.get_node_or_null("HUD") as BattleHUD
	_roster = _battle.get_node_or_null("FormalCombatRoster") as BattleFormalCombatRoster
	_central = _battle.get_node_or_null("CentralBridgehead") as BattleObjective
	_industrial = _battle.get_node_or_null("IndustrialObjective") as BattleObjective
	_world3d = _battle.get_node_or_null("World3D") as Node3D
	_freeze_named_simulation_nodes()
	_freeze_existing_formations()
	call_deferred("_finish_initialization")

func _process(delta: float) -> void:
	if _staging_active:
		_freeze_existing_formations()
		_force_red_fow_hidden()
		_ui_refresh_accumulator += delta
		if _ui_refresh_accumulator >= 0.15:
			_ui_refresh_accumulator = 0.0
			_refresh_staging_ui()
		return
	_battle_elapsed += delta

func _finish_initialization() -> void:
	if _battle == null:
		return
	_collect_active_blue()
	_freeze_named_simulation_nodes()
	_freeze_existing_formations()
	_force_red_fow_hidden()
	_initialize_staging_state()
	_build_staging_ui()
	_build_staging_boundary_visual()
	staging_started.emit()
	print("FRONTLINE_PRE_BATTLE_STAGING_READY active_blue=%d separation=%.0f" % [_active_blue.size(), MIN_SEPARATION])
	if _should_auto_start_legacy_runtime() and not _keep_staging_for_test:
		_start_battle_internal(true)

func force_keep_staging_for_test() -> void:
	_keep_staging_for_test = true

func is_staging_active() -> bool:
	return _staging_active

func get_battle_elapsed_for_test() -> float:
	return _battle_elapsed

func get_t0_activation_count_for_test() -> int:
	return _t0_activation_count

func get_initial_intent_for(formation: BattleFormation) -> String:
	if formation == null or not _initial_intents.has(formation):
		return INTENT_HOLD
	return str((_initial_intents[formation] as Dictionary).get("kind", INTENT_HOLD))

func get_initial_target_for(formation: BattleFormation) -> Vector2:
	if formation == null or not _initial_intents.has(formation):
		return Vector2.ZERO
	return Vector2((_initial_intents[formation] as Dictionary).get("target", Vector2.ZERO))

func get_staged_position_for(formation: BattleFormation) -> Vector2:
	if formation == null:
		return Vector2.ZERO
	return Vector2(_staged_positions.get(formation, formation.global_position))

func queue_initial_for_selected(kind: String, world_target: Vector2, spacing: float = -1.0) -> int:
	if not _staging_active or _selection == null:
		return 0
	var selected: Array[BattleFormation] = _selection.get_selected()
	if selected.is_empty():
		_feedback("SELECT A BLUE FORMATION FIRST")
		return 0
	var eligible: Array[BattleFormation] = []
	var logistics_rejected: int = 0
	for formation: BattleFormation in selected:
		if formation == null or formation not in _active_blue:
			continue
		if kind == INTENT_ADVANCE and formation.is_supply_truck():
			logistics_rejected += 1
			continue
		eligible.append(formation)
	if eligible.is_empty():
		if logistics_rejected > 0:
			_feedback("LOGISTICS CANNOT ADVANCE")
		return 0
	var actual_spacing: float = _selection.group_spacing if spacing < 0.0 else spacing
	var queued: int = 0
	for index: int in range(eligible.size()):
		var formation: BattleFormation = eligible[index]
		var lateral: float = (float(index) - float(eligible.size() - 1) * 0.5) * actual_spacing
		var target: Vector2 = world_target + Vector2(0.0, lateral)
		if _queue_initial_intent(formation, kind, target):
			queued += 1
	if logistics_rejected > 0:
		_feedback("%s QUEUED · %d · LOGISTICS CANNOT ADVANCE" % [kind, queued])
	elif queued > 0:
		_feedback("INITIAL %s QUEUED · %d FORMATION%s" % [kind, queued, "S" if queued != 1 else ""])
	_refresh_staging_ui()
	return queued

func clear_initial_selected() -> int:
	if not _staging_active or _selection == null:
		return 0
	var cleared: int = 0
	for formation: BattleFormation in _selection.get_selected():
		if formation != null and formation in _active_blue:
			_initial_intents[formation] = {"kind": INTENT_HOLD, "target": Vector2.ZERO}
			cleared += 1
	if cleared > 0:
		_feedback("INITIAL HOLD · %d FORMATION%s" % [cleared, "S" if cleared != 1 else ""])
	_refresh_staging_ui()
	return cleared

func queue_initial_move_for_test(formation: BattleFormation, target: Vector2) -> bool:
	return _queue_initial_intent(formation, INTENT_MOVE, target)

func queue_initial_advance_for_test(formation: BattleFormation, target: Vector2) -> bool:
	return _queue_initial_intent(formation, INTENT_ADVANCE, target)

func place_formation_for_test(formation: BattleFormation, target: Vector2) -> bool:
	if not _staging_active or not is_staging_position_valid(formation, target):
		return false
	formation.global_position = target
	_staged_positions[formation] = target
	_validate_queued_intent_after_reposition(formation)
	_refresh_staging_ui()
	return true

func begin_placement_drag(formation: BattleFormation) -> bool:
	if not _staging_active or formation == null or formation not in _active_blue:
		return false
	_drag_formation = formation
	_drag_origin = get_staged_position_for(formation)
	_drag_preview_valid = true
	if _preview_marker != null:
		_preview_marker.visible = true
		_update_preview_marker(_drag_origin, true)
	_feedback("PLACEMENT DRAG · %s" % formation.display_name)
	return true

func update_placement_drag(target: Vector2) -> bool:
	if not _staging_active or _drag_formation == null:
		return false
	_drag_preview_valid = is_staging_position_valid(_drag_formation, target)
	_drag_formation.global_position = target
	_update_preview_marker(target, _drag_preview_valid)
	_status_label_text("PLACEMENT VALID" if _drag_preview_valid else "PLACEMENT INVALID · RELEASE TO REVERT")
	return _drag_preview_valid

func end_placement_drag(target: Vector2) -> bool:
	if not _staging_active or _drag_formation == null:
		return false
	var formation: BattleFormation = _drag_formation
	var valid: bool = is_staging_position_valid(formation, target)
	if valid:
		formation.global_position = target
		_staged_positions[formation] = target
		_validate_queued_intent_after_reposition(formation)
		_feedback("PLACEMENT COMMITTED · %s" % formation.display_name)
	else:
		formation.global_position = _drag_origin
		_staged_positions[formation] = _drag_origin
		_feedback("PLACEMENT REJECTED · RETURNED TO LAST VALID POSITION")
	_drag_formation = null
	_drag_preview_valid = false
	if _preview_marker != null:
		_preview_marker.visible = false
	_refresh_staging_ui()
	return valid

func cancel_placement_drag() -> void:
	if _drag_formation != null:
		_drag_formation.global_position = _drag_origin
	_drag_formation = null
	_drag_preview_valid = false
	if _preview_marker != null:
		_preview_marker.visible = false

func is_staging_position_valid(formation: BattleFormation, point: Vector2) -> bool:
	if formation == null or formation not in _active_blue:
		return false
	if not Geometry2D.is_point_in_polygon(point, STAGING_POLYGON):
		return false
	if BattleRouteTerrain.RIVER_RECT.has_point(point):
		return false
	for blocker: Rect2 in _navigation.get_hard_blockers():
		if blocker.has_point(point):
			return false
	if _central != null and point.distance_to(_central.global_position) <= _central.capture_radius:
		return false
	if _industrial != null and point.distance_to(_industrial.global_position) <= _industrial.capture_radius:
		return false
	var mobility: String = _navigation.mobility_for_formation(formation)
	if not _navigation.is_world_walkable_for_mobility(point, mobility):
		return false
	for other: BattleFormation in _active_blue:
		if other == formation:
			continue
		var other_position: Vector2 = other.global_position
		if point.distance_to(other_position) < MIN_SEPARATION:
			return false
	return true

func all_staged_positions_valid() -> bool:
	if _active_blue.size() != 4:
		return false
	for formation: BattleFormation in _active_blue:
		if not is_staging_position_valid(formation, formation.global_position):
			return false
	return true

func start_battle_for_test() -> bool:
	return _start_battle_internal(false)

func is_ui_point(screen_point: Vector2) -> bool:
	return _staging_active and _ui_panel != null and _ui_panel.visible and _ui_panel.get_global_rect().has_point(screen_point)

func has_staging_boundary_visual_for_test() -> bool:
	return _boundary_root != null and is_instance_valid(_boundary_root) and _boundary_root.visible

func _initialize_staging_state() -> void:
	_collect_active_blue()
	_staged_positions.clear()
	_initial_intents.clear()
	for formation: BattleFormation in _active_blue:
		_staged_positions[formation] = formation.global_position
		_initial_intents[formation] = {"kind": INTENT_HOLD, "target": Vector2.ZERO}
		formation.stop()
		if formation.is_supply_truck():
			formation.set_hold_fire_enabled(false)
	if not all_staged_positions_valid():
		push_error("Battle01 default BLUE staging positions violate the frozen staging contract.")

func _queue_initial_intent(formation: BattleFormation, kind: String, target: Vector2) -> bool:
	if not _staging_active or formation == null or formation not in _active_blue:
		return false
	if kind != INTENT_MOVE and kind != INTENT_ADVANCE:
		return false
	if kind == INTENT_ADVANCE and formation.is_supply_truck():
		_feedback("LOGISTICS CANNOT ADVANCE")
		return false
	if not _is_queue_target_valid(formation, target):
		_feedback("INITIAL %s REJECTED · INVALID/UNREACHABLE TARGET · %s" % [kind, formation.display_name])
		return false
	_initial_intents[formation] = {"kind": kind, "target": target}
	return true

func _is_queue_target_valid(formation: BattleFormation, target: Vector2) -> bool:
	if target.x < 0.0 or target.y < 0.0 or target.x > Battle3DAdapter.MAP_SIM_SIZE.x or target.y > Battle3DAdapter.MAP_SIM_SIZE.y:
		return false
	var mobility: String = _navigation.mobility_for_formation(formation)
	if not _navigation.is_world_walkable_for_mobility(target, mobility):
		return false
	return not _navigation.find_path_for_formation(formation, target).is_empty()

func _validate_queued_intent_after_reposition(formation: BattleFormation) -> void:
	if formation == null or not _initial_intents.has(formation):
		return
	var record: Dictionary = _initial_intents[formation]
	var kind: String = str(record.get("kind", INTENT_HOLD))
	if kind == INTENT_HOLD:
		return
	var target: Vector2 = Vector2(record.get("target", Vector2.ZERO))
	if _is_queue_target_valid(formation, target):
		return
	_initial_intents[formation] = {"kind": INTENT_HOLD, "target": Vector2.ZERO}
	_feedback("INITIAL INTENT CLEARED AFTER REPOSITION · %s" % formation.display_name)

func _start_battle_internal(legacy_auto_start: bool) -> bool:
	if not _staging_active:
		return false
	_collect_active_blue()
	if not all_staged_positions_valid():
		_feedback("START BLOCKED · INVALID STAGING PLACEMENT")
		return false
	cancel_placement_drag()
	for formation: BattleFormation in _active_blue:
		_validate_queued_intent_after_reposition(formation)
	var previous_selection: Array[BattleFormation] = _selection.get_selected().duplicate()
	_staging_active = false
	_battle_elapsed = 0.0
	_t0_activation_count = 0
	_restore_simulation_processes()
	for formation: BattleFormation in _active_blue:
		formation.stop()
	for formation: BattleFormation in _active_blue:
		var record: Dictionary = _initial_intents.get(formation, {"kind": INTENT_HOLD, "target": Vector2.ZERO})
		var kind: String = str(record.get("kind", INTENT_HOLD))
		var target: Vector2 = Vector2(record.get("target", Vector2.ZERO))
		if kind == INTENT_MOVE:
			_selection.select_only(formation)
			if _selection.issue_move(target, 0.0) != 1:
				push_error("Initial MOVE failed at T=0 for %s." % formation.display_name)
				formation.stop()
		elif kind == INTENT_ADVANCE:
			_selection.select_only(formation)
			if _selection.issue_advance(target, 0.0) != 1:
				push_error("Initial ADVANCE failed at T=0 for %s." % formation.display_name)
				formation.stop()
		else:
			formation.stop()
		_t0_activation_count += 1
	_selection.clear_selection()
	for formation: BattleFormation in previous_selection:
		if formation != null and is_instance_valid(formation):
			_selection.add_to_selection(formation)
	if _ui_layer != null:
		_ui_layer.visible = false
	if _boundary_root != null:
		_boundary_root.visible = false
	if _preview_marker != null:
		_preview_marker.visible = false
	staging_ended.emit()
	print("FRONTLINE_BATTLE_T0_START intents=%d legacy_auto=%s" % [_t0_activation_count, legacy_auto_start])
	print("FRONTLINE_PRE_BATTLE_STAGING_COMPLETE")
	return true

func _collect_active_blue() -> void:
	_active_blue.clear()
	for node_name: String in ["BlueRecon", "BlueInfantry", "BlueFormation", "BlueSupply"]:
		var formation: BattleFormation = _battle.get_node_or_null(node_name) as BattleFormation
		if formation != null:
			_active_blue.append(formation)

func _freeze_named_simulation_nodes() -> void:
	for path: String in [
		"EnemyAIController",
		"IntelTracker",
		"CentralBridgehead",
		"IndustrialObjective",
		"PlayerWarFlow",
		"ResupplyController",
		"VisibilityField",
	]:
		var node: Node = _battle.get_node_or_null(path)
		if node != null:
			_freeze_node(node)

func _freeze_existing_formations() -> void:
	_collect_and_freeze_formations(_battle)

func _collect_and_freeze_formations(node: Node) -> void:
	if node is BattleFormation:
		var formation: BattleFormation = node as BattleFormation
		_freeze_node(formation)
		if formation.faction == "RED":
			formation.set_intel_state(BattleIntelTracker.UNSEEN)
	for child: Node in node.get_children():
		_collect_and_freeze_formations(child)

func _force_red_fow_hidden() -> void:
	_force_red_hidden_recursive(_battle)

func _force_red_hidden_recursive(node: Node) -> void:
	if node is BattleFormation:
		var formation: BattleFormation = node as BattleFormation
		if formation.faction == "RED":
			formation.set_intel_state(BattleIntelTracker.UNSEEN)
	for child: Node in node.get_children():
		_force_red_hidden_recursive(child)

func _freeze_node(node: Node) -> void:
	if node == null or node == self:
		return
	if not _saved_process_state.has(node):
		_saved_process_state[node] = {
			"process": node.is_processing(),
			"physics": node.is_physics_processing(),
		}
	node.set_process(false)
	node.set_physics_process(false)

func _restore_simulation_processes() -> void:
	for key: Variant in _saved_process_state.keys():
		var node: Node = key as Node
		if node == null or not is_instance_valid(node):
			continue
		var state: Dictionary = _saved_process_state[key]
		node.set_process(bool(state.get("process", true)))
		node.set_physics_process(bool(state.get("physics", false)))
	_saved_process_state.clear()

func _should_auto_start_legacy_runtime() -> bool:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	for argument: String in user_args:
		if argument.begins_with("--battle01-ci-"):
			return true
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	return tree.current_scene != _battle

func _build_staging_ui() -> void:
	if _ui_layer != null:
		return
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "PreBattleStagingHUD"
	_ui_layer.layer = 40
	_battle.add_child(_ui_layer)
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(root)

	_ui_panel = PanelContainer.new()
	_ui_panel.name = "StagingPanel"
	_ui_panel.anchor_left = 0.5
	_ui_panel.anchor_right = 0.5
	_ui_panel.offset_left = -330.0
	_ui_panel.offset_right = 330.0
	_ui_panel.offset_top = 18.0
	_ui_panel.offset_bottom = 285.0
	_ui_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_ui_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_ui_panel.add_child(vbox)
	_banner_label = Label.new()
	_banner_label.text = "PRE-BATTLE STAGING · SIMULATION PAUSED AT T=0"
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_banner_label)
	var help := Label.new()
	help.text = "Drag BLUE marker: place · RMB: queue MOVE · Shift+RMB: queue ADVANCE · H: HOLD FIRE"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(help)
	_roster_label = Label.new()
	_roster_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_roster_label)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 10)
	vbox.add_child(buttons)
	_clear_button = Button.new()
	_clear_button.text = "HOLD / CLEAR INITIAL"
	_clear_button.pressed.connect(clear_initial_selected)
	buttons.add_child(_clear_button)
	_hold_fire_button = Button.new()
	_hold_fire_button.text = "TOGGLE HOLD FIRE"
	_hold_fire_button.pressed.connect(_on_hold_fire_pressed)
	buttons.add_child(_hold_fire_button)
	_start_button = Button.new()
	_start_button.text = "START BATTLE"
	_start_button.pressed.connect(_on_start_pressed)
	buttons.add_child(_start_button)
	_status_label = Label.new()
	_status_label.text = "WEST_STAGING_AREA · Reserve LOCKED / NOT AVAILABLE"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_status_label)
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
		var fire_text: String = " · HOLD FIRE" if formation.can_attack and formation.is_hold_fire_enabled() else ""
		lines.append("%s · (%d,%d) · %s%s%s" % [formation.display_name, int(formation.global_position.x), int(formation.global_position.y), intent, target_text, fire_text])
	_roster_label.text = "\n".join(lines)
	if _start_button != null:
		_start_button.disabled = not all_staged_positions_valid()

func _on_start_pressed() -> void:
	_start_battle_internal(false)

func _on_hold_fire_pressed() -> void:
	if _selection == null:
		return
	_selection.toggle_hold_fire_selected()
	_refresh_staging_ui()

func _feedback(message: String) -> void:
	_status_label_text(message)
	if _hud != null:
		_hud.show_command_feedback(message, "INFO")
	staging_feedback.emit(message)
	print("FRONTLINE_STAGING_FEEDBACK %s" % message)

func _status_label_text(message: String) -> void:
	if _status_label != null:
		_status_label.text = message

func _build_staging_boundary_visual() -> void:
	if _world3d == null or _boundary_root != null:
		return
	_boundary_root = Node3D.new()
	_boundary_root.name = "PreBattleStagingBoundary3D"
	_world3d.add_child(_boundary_root)
	var boundary_material := StandardMaterial3D.new()
	boundary_material.albedo_color = Color(0.20, 0.72, 1.0, 0.92)
	_valid_material = StandardMaterial3D.new()
	_valid_material.albedo_color = Color(0.20, 0.92, 0.46, 0.92)
	_invalid_material = StandardMaterial3D.new()
	_invalid_material.albedo_color = Color(1.0, 0.24, 0.18, 0.92)
	for index: int in range(STAGING_POLYGON.size()):
		var a: Vector3 = Battle3DAdapter.sim_to_world(STAGING_POLYGON[index], 0.055)
		var b: Vector3 = Battle3DAdapter.sim_to_world(STAGING_POLYGON[(index + 1) % STAGING_POLYGON.size()], 0.055)
		var delta: Vector3 = b - a
		var mesh := BoxMesh.new()
		mesh.size = Vector3(delta.length(), 0.035, 0.045)
		var segment := MeshInstance3D.new()
		segment.mesh = mesh
		segment.material_override = boundary_material
		segment.position = (a + b) * 0.5
		segment.rotation.y = atan2(-delta.z, delta.x)
		_boundary_root.add_child(segment)
	_preview_marker = MeshInstance3D.new()
	_preview_marker.name = "PlacementValidityPreview"
	var preview_mesh := BoxMesh.new()
	preview_mesh.size = Vector3(0.72, 0.04, 0.72)
	_preview_marker.mesh = preview_mesh
	_preview_marker.material_override = _valid_material
	_preview_marker.visible = false
	_boundary_root.add_child(_preview_marker)

func _update_preview_marker(point: Vector2, valid: bool) -> void:
	if _preview_marker == null:
		return
	_preview_marker.position = Battle3DAdapter.sim_to_world(point, 0.06)
	_preview_marker.material_override = _valid_material if valid else _invalid_material
