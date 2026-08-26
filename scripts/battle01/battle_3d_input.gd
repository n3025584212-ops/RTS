class_name Battle3DInput
extends Node

@export var click_radius_px: float = 38.0
@export var drag_threshold_px: float = 12.0

var _battle: Node
var _camera: BattleCamera3D
var _selection: BattleSelectionController
var _presentation: Battle3DPresentation
var _war_flow: BattlePlayerWarFlow
var _staging: BattlePreBattleStagingController
var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_current: Vector2 = Vector2.ZERO
var _placement_candidate: BattleFormation
var _placement_dragging: bool = false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	_battle = get_parent()
	_camera = _battle.get_node("World3D/BattleCamera3D") as BattleCamera3D
	_selection = _battle.get_node("SelectionController") as BattleSelectionController
	_presentation = _battle.get_node("World3D/Presentation3D") as Battle3DPresentation
	_war_flow = _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	_staging = _battle.get_node_or_null("PreBattleStaging") as BattlePreBattleStagingController
	print("FRONTLINE_3D_INPUT_READY")

func _input(event: InputEvent) -> void:
	if _camera == null or _selection == null or _presentation == null or _war_flow == null:
		return
	if _war_flow.is_match_finished():
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if _staging != null and _staging.is_ui_point(mouse_event.position):
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera.adjust_zoom(1)
			get_viewport().set_input_as_handled()
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.adjust_zoom(-1)
			get_viewport().set_input_as_handled()
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_mouse(mouse_event)
			get_viewport().set_input_as_handled()
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			var sim_hit: Variant = screen_to_sim(mouse_event.position)
			if sim_hit != null:
				var target := Battle3DAdapter.clamp_sim(sim_hit as Vector2)
				var advance: bool = mouse_event.shift_pressed
				var issued: int = _selection.issue_advance(target) if advance else _selection.issue_move(target)
				if issued > 0:
					_presentation.show_command_marker(target)
					var staged: bool = _staging != null and _staging.is_staging_active()
					print("FRONTLINE_3D_%s_%s issued=%d target=%s" % ["INITIAL" if staged else "LIVE", "ADVANCE" if advance else "MOVE", issued, target])
			get_viewport().set_input_as_handled()
			return
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _placement_candidate != null:
			_drag_current = motion.position
			if not _placement_dragging and _drag_start.distance_to(_drag_current) >= drag_threshold_px:
				_placement_dragging = _staging != null and _staging.begin_placement_drag(_placement_candidate)
			if _placement_dragging:
				var sim_hit: Variant = screen_to_sim(motion.position)
				if sim_hit != null:
					_staging.update_placement_drag(Battle3DAdapter.clamp_sim(sim_hit as Vector2))
				get_viewport().set_input_as_handled()
			return
		if _dragging:
			_drag_current = motion.position

func _handle_left_mouse(mouse_event: InputEventMouseButton) -> void:
	if mouse_event.pressed:
		_drag_start = mouse_event.position
		_drag_current = mouse_event.position
		if _staging != null and _staging.is_staging_active():
			_placement_candidate = _pick_formation_at_screen(mouse_event.position)
			if _placement_candidate != null:
				if mouse_event.shift_pressed:
					_selection.add_to_selection(_placement_candidate)
				else:
					_selection.select_only(_placement_candidate)
				print("FRONTLINE_3D_STAGING_SELECTION unit=%s" % _placement_candidate.display_name)
				return
		_dragging = true
		return

	if _placement_candidate != null:
		if _placement_dragging:
			var sim_hit: Variant = screen_to_sim(mouse_event.position)
			if sim_hit != null:
				_staging.end_placement_drag(Battle3DAdapter.clamp_sim(sim_hit as Vector2))
			else:
				_staging.cancel_placement_drag()
		_placement_candidate = null
		_placement_dragging = false
		_dragging = false
		return

	if _dragging:
		_drag_current = mouse_event.position
		var additive := Input.is_key_pressed(KEY_SHIFT)
		if _drag_start.distance_to(_drag_current) >= drag_threshold_px:
			_select_box(_drag_start, _drag_current, additive)
		else:
			_select_click(mouse_event.position, additive)
	_dragging = false

func screen_to_sim(screen_position: Vector2) -> Variant:
	if _camera == null:
		return null
	var ray_origin := _camera.project_ray_origin(screen_position)
	var ray_direction := _camera.project_ray_normal(screen_position)
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(ray_origin, ray_direction)
	if hit == null:
		return null
	return Battle3DAdapter.world_to_sim(hit as Vector3)

func _pick_formation_at_screen(screen_position: Vector2) -> BattleFormation:
	var picked: BattleFormation = null
	var best_distance := click_radius_px
	for formation: BattleFormation in _presentation.get_player_selectable_formations():
		var world_position := _presentation.get_world_position_for(formation)
		if _camera.is_position_behind(world_position):
			continue
		var projected := _camera.unproject_position(world_position)
		var distance := projected.distance_to(screen_position)
		if distance <= best_distance:
			best_distance = distance
			picked = formation
	return picked

func _select_click(screen_position: Vector2, additive: bool) -> void:
	var picked: BattleFormation = _pick_formation_at_screen(screen_position)
	if picked == null:
		if not additive:
			_selection.clear_selection()
		return
	if additive:
		_selection.add_to_selection(picked)
	else:
		_selection.select_only(picked)
	print("FRONTLINE_3D_SELECTION unit=%s additive=%s" % [picked.display_name, additive])

func _select_box(a: Vector2, b: Vector2, additive: bool) -> void:
	var minimum := Vector2(minf(a.x, b.x), minf(a.y, b.y))
	var maximum := Vector2(maxf(a.x, b.x), maxf(a.y, b.y))
	var rect := Rect2(minimum, maximum - minimum)
	if not additive:
		_selection.clear_selection()
	var selected_count := 0
	for formation: BattleFormation in _presentation.get_player_selectable_formations():
		var world_position := _presentation.get_world_position_for(formation)
		if _camera.is_position_behind(world_position):
			continue
		if rect.has_point(_camera.unproject_position(world_position)):
			_selection.add_to_selection(formation)
			selected_count += 1
	print("FRONTLINE_3D_BOX_SELECTION count=%d" % selected_count)

func issue_move_for_test(formation: BattleFormation, target_sim: Vector2) -> bool:
	if formation == null or _selection == null:
		return false
	_selection.select_only(formation)
	return _selection.issue_move(target_sim) == 1

func issue_advance_for_test(formation: BattleFormation, target_sim: Vector2) -> bool:
	if formation == null or _selection == null:
		return false
	_selection.select_only(formation)
	return _selection.issue_advance(target_sim) == 1
