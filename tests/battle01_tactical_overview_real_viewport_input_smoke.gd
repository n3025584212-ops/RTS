extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")
const BLUE_NAMES := ["BlueRecon", "BlueInfantry", "BlueFormation", "BlueSupply"]

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_TACTICAL_OVERVIEW_REAL_VIEWPORT_INPUT_SMOKE_BEGIN")
	var battle: Node = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	var staging := battle.get_node_or_null("PreBattleStaging") as BattlePreBattleStagingController
	if staging == null:
		_failures.append("STAGING_CONTROLLER_MISSING")
		_finish(battle)
		return
	staging.force_keep_staging_for_test()
	for _frame: int in range(6):
		await process_frame

	var camera := battle.get_node_or_null("World3D/BattleCamera3D") as BattleCamera3D
	var presentation := battle.get_node_or_null("World3D/Presentation3D") as Battle3DPresentation
	var input3d := battle.get_node_or_null("Input3D") as Battle3DInput
	var selection := battle.get_node_or_null("SelectionController") as BattleSelectionController
	var enemy_ai: Node = battle.get_node_or_null("EnemyAIController")
	var central := battle.get_node_or_null("CentralBridgehead") as BattleObjective
	var industrial := battle.get_node_or_null("IndustrialObjective") as BattleObjective
	var minimap: BattleMinimap = _find_minimap(battle)
	var recon := battle.get_node_or_null("BlueRecon") as BattleFormation
	var infantry := battle.get_node_or_null("BlueInfantry") as BattleFormation
	var ifv := battle.get_node_or_null("BlueFormation") as BattleFormation
	var supply := battle.get_node_or_null("BlueSupply") as BattleFormation
	var formations: Array = [recon, infantry, ifv, supply]

	var ready: bool = (
		camera != null
		and presentation != null
		and input3d != null
		and selection != null
		and minimap != null
		and recon != null
		and infantry != null
		and ifv != null
		and supply != null
	)
	_require(ready and staging.is_staging_active(), "REAL_VIEWPORT_INPUT_RUNTIME_READY_PASS")
	if not ready:
		_finish(battle)
		return

	# Real Viewport -> Control GUI click/drag. Snapshot every world-side state that
	# the minimap must not mutate.
	selection.select_only(recon)
	var selected_before: PackedStringArray = _selected_names(selection)
	var staged_before: Dictionary = _staged_snapshot(staging, formations)
	var intents_before: Dictionary = _intent_snapshot(staging, formations)
	var world_serial_before: int = input3d.get_world_input_serial_for_test()
	var map_rect: Rect2 = minimap.get_global_rect()

	var click_local := Vector2(minimap.size.x * 0.26, minimap.size.y * 0.34)
	var expected_click: Vector2 = _minimap_local_to_sim(minimap, click_local)
	var focus_before_click: Vector2 = camera.focus_sim
	await _mouse_click(map_rect.position + click_local, MOUSE_BUTTON_LEFT, false)
	_require(
		camera.focus_sim.distance_to(expected_click) <= 3.0
		and camera.focus_sim.distance_to(focus_before_click) > 20.0,
		"REAL_VIEWPORT_MINIMAP_CLICK_CAMERA3D_PASS"
	)

	var drag_from_local := Vector2(minimap.size.x * 0.36, minimap.size.y * 0.46)
	var drag_to_local := Vector2(minimap.size.x * 0.76, minimap.size.y * 0.68)
	var expected_drag: Vector2 = _minimap_local_to_sim(minimap, drag_to_local)
	var focus_before_drag: Vector2 = camera.focus_sim
	await _mouse_drag(map_rect.position + drag_from_local, map_rect.position + drag_to_local)
	_require(
		camera.focus_sim.distance_to(expected_drag) <= 3.0
		and camera.focus_sim.distance_to(focus_before_drag) > 20.0,
		"REAL_VIEWPORT_MINIMAP_DRAG_CAMERA3D_PASS"
	)

	var isolation_ok: bool = (
		input3d.get_world_input_serial_for_test() == world_serial_before
		and not input3d.is_world_pointer_interaction_active_for_test()
		and _selected_names(selection) == selected_before
		and _snapshot_vectors_equal(_staged_snapshot(staging, formations), staged_before)
		and _intent_snapshots_equal(_intent_snapshot(staging, formations), intents_before)
	)
	_require(isolation_ok, "REAL_VIEWPORT_MINIMAP_WORLD_INPUT_ISOLATION_PASS")

	_require(
		staging.is_staging_active()
		and is_equal_approx(staging.get_battle_elapsed_for_test(), 0.0)
		and enemy_ai != null and not enemy_ai.is_processing()
		and central != null and not central.is_processing()
		and industrial != null and not industrial.is_processing(),
		"REAL_VIEWPORT_MINIMAP_NAV_DOES_NOT_START_BATTLE_PASS"
	)

	# Camera navigation into hidden RED territory must not reveal RED truth.
	var east_local := Vector2(minimap.size.x * 0.87, minimap.size.y * 0.56)
	await _mouse_click(map_rect.position + east_local, MOUSE_BUTTON_LEFT, false)
	for _frame: int in range(3):
		await process_frame
	var fow_ok: bool = minimap.get_drawable_red_count_for_test() == 0 and _visible_red_proxy_count(presentation) == 0
	for red: BattleFormation in _all_red_formations(battle):
		if red.intel_state != BattleIntelTracker.UNSEEN:
			fow_ok = false
			break
	_require(fow_ok, "REAL_VIEWPORT_MINIMAP_FOW_NO_RED_LEAK_PASS")

	# Camera keyboard pan is independent from pointer routing.
	camera.focus_on_sim(Vector2(1050.0, 900.0))
	var wasd_before: Vector2 = camera.focus_sim
	await _key_hold(KEY_W, 3)
	_require(camera.focus_sim.y < wasd_before.y - 1.0, "CAMERA_WASD_PAN_REGRESSION_PASS")

	# Wheel still reaches the world camera in an uncovered world-space area.
	camera.focus_on_sim(Vector2(900.0, 900.0))
	var wheel_before: float = camera.height_world
	await _mouse_wheel(Vector2(800.0, 500.0), MOUSE_BUTTON_WHEEL_UP)
	_require(camera.height_world < wheel_before, "WORLD_WHEEL_ZOOM_REGRESSION_PASS")

	# Real formation placement drag remains functional after moving world mouse
	# handling to _unhandled_input().
	camera.focus_on_sim(Vector2(620.0, 900.0))
	await process_frame
	var ifv_screen: Vector2 = camera.unproject_position(presentation.get_world_position_for(ifv))
	var placement_target := Vector2(720.0, 900.0)
	var placement_screen: Vector2 = camera.unproject_position(Battle3DAdapter.sim_to_world(placement_target, 0.0))
	await _mouse_drag(ifv_screen, placement_screen)
	_require(
		staging.get_staged_position_for(ifv).distance_to(placement_target) <= 4.0
		and ifv.global_position.distance_to(placement_target) <= 4.0,
		"REAL_VIEWPORT_FORMATION_PLACEMENT_DRAG_PASS"
	)

	# Formation click selection remains real world input.
	selection.clear_selection()
	camera.focus_on_sim(ifv.global_position)
	await process_frame
	ifv_screen = camera.unproject_position(presentation.get_world_position_for(ifv))
	await _mouse_click(ifv_screen, MOUSE_BUTTON_LEFT, false)
	_require(ifv in selection.get_selected(), "REAL_VIEWPORT_FORMATION_CLICK_SELECT_PASS")

	# Empty-ground drag still enters box selection rather than placement.
	selection.clear_selection()
	var box_from := ifv_screen + Vector2(-78.0, -68.0)
	var box_to := ifv_screen + Vector2(78.0, 68.0)
	await _mouse_drag(box_from, box_to)
	_require(
		ifv in selection.get_selected()
		and not input3d.is_world_pointer_interaction_active_for_test(),
		"REAL_VIEWPORT_EMPTY_GROUND_BOX_SELECT_PASS"
	)

	# Staging RMB / Shift+RMB remain queued intents, with no pre-START movement.
	camera.focus_on_sim(Vector2(900.0, 900.0))
	await process_frame
	selection.select_only(recon)
	var recon_before: Vector2 = recon.global_position
	var move_target := Vector2(1040.0, 900.0)
	var move_screen: Vector2 = camera.unproject_position(Battle3DAdapter.sim_to_world(move_target, 0.0))
	await _mouse_click(move_screen, MOUSE_BUTTON_RIGHT, false)
	_require(
		staging.get_initial_intent_for(recon) == BattlePreBattleStagingController.INTENT_MOVE
		and recon.global_position.is_equal_approx(recon_before)
		and recon.get_order() == "HOLD",
		"REAL_VIEWPORT_STAGING_RMB_INITIAL_MOVE_PASS"
	)

	selection.select_only(ifv)
	var ifv_before: Vector2 = ifv.global_position
	var advance_target := Vector2(1360.0, 900.0)
	var advance_screen: Vector2 = camera.unproject_position(Battle3DAdapter.sim_to_world(advance_target, 0.0))
	await _mouse_click(advance_screen, MOUSE_BUTTON_RIGHT, true)
	_require(
		staging.get_initial_intent_for(ifv) == BattlePreBattleStagingController.INTENT_ADVANCE
		and ifv.global_position.is_equal_approx(ifv_before)
		and ifv.get_order() == "HOLD",
		"REAL_VIEWPORT_STAGING_SHIFT_RMB_INITIAL_ADVANCE_PASS"
	)

	# A real staging Button owns its event and never enters world input.
	var clear_button: Button = _find_button_by_text(battle, "HOLD / CLEAR INITIAL")
	var hud_serial_before: int = input3d.get_world_input_serial_for_test()
	var selected_before_hud: PackedStringArray = _selected_names(selection)
	var hud_ok: bool = clear_button != null
	if clear_button != null:
		await _mouse_click(clear_button.get_global_rect().get_center(), MOUSE_BUTTON_LEFT, false)
		hud_ok = (
			staging.get_initial_intent_for(ifv) == BattlePreBattleStagingController.INTENT_HOLD
			and input3d.get_world_input_serial_for_test() == hud_serial_before
			and _selected_names(selection) == selected_before_hud
			and not input3d.is_world_pointer_interaction_active_for_test()
		)
	_require(hud_ok, "REAL_VIEWPORT_STAGING_HUD_BUTTON_INPUT_ISOLATION_PASS")

	# START is also real Viewport/Button input. The same minimap and same Camera3D
	# must continue working after the single T=0 transition.
	var start_button: Button = _find_button_by_text(battle, "START BATTLE")
	var start_ok: bool = start_button != null
	if start_button != null:
		await _mouse_click(start_button.get_global_rect().get_center(), MOUSE_BUTTON_LEFT, false)
		for _frame: int in range(3):
			await process_frame
		start_ok = not staging.is_staging_active() and staging.get_t0_activation_count_for_test() == 4
	_require(start_ok, "REAL_VIEWPORT_START_BATTLE_BUTTON_PASS")

	var live_before: Vector2 = camera.focus_sim
	map_rect = minimap.get_global_rect()
	var live_local := Vector2(minimap.size.x * 0.48, minimap.size.y * 0.24)
	var live_expected: Vector2 = _minimap_local_to_sim(minimap, live_local)
	await _mouse_click(map_rect.position + live_local, MOUSE_BUTTON_LEFT, false)
	_require(
		not staging.is_staging_active()
		and camera.focus_sim.distance_to(live_expected) <= 3.0
		and camera.focus_sim.distance_to(live_before) > 20.0,
		"REAL_VIEWPORT_LIVE_MINIMAP_CAMERA3D_PASS"
	)

	if _failures.is_empty():
		print("FRONTLINE_TACTICAL_OVERVIEW_REAL_VIEWPORT_INPUT_SMOKE_PASS")
	else:
		for failure: String in _failures:
			push_error("REAL_VIEWPORT_INPUT_SMOKE_FAILURE %s" % failure)
	_finish(battle)

func _mouse_click(screen_position: Vector2, button_index: int, shift_pressed: bool) -> void:
	var input_position: Vector2 = _to_window_input_position(screen_position)
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = input_position
	press.global_position = input_position
	press.shift_pressed = shift_pressed
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = input_position
	release.global_position = input_position
	release.shift_pressed = shift_pressed
	Input.parse_input_event(release)
	await process_frame

func _mouse_drag(from_screen: Vector2, to_screen: Vector2) -> void:
	var from_input: Vector2 = _to_window_input_position(from_screen)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = from_input
	press.global_position = from_input
	Input.parse_input_event(press)
	await process_frame
	var previous_input: Vector2 = from_input
	for point: Vector2 in [from_screen.lerp(to_screen, 0.5), to_screen]:
		var input_point: Vector2 = _to_window_input_position(point)
		var motion := InputEventMouseMotion.new()
		motion.position = input_point
		motion.global_position = input_point
		motion.relative = input_point - previous_input
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(motion)
		previous_input = input_point
		await process_frame
	var to_input: Vector2 = _to_window_input_position(to_screen)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = to_input
	release.global_position = to_input
	Input.parse_input_event(release)
	await process_frame

func _mouse_wheel(screen_position: Vector2, wheel_button: int) -> void:
	var input_position: Vector2 = _to_window_input_position(screen_position)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = wheel_button
	wheel.pressed = true
	wheel.position = input_position
	wheel.global_position = input_position
	Input.parse_input_event(wheel)
	await process_frame

func _to_window_input_position(viewport_position: Vector2) -> Vector2:
	return root.get_screen_transform() * viewport_position

func _key_hold(keycode: int, frames: int) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	for _frame: int in range(frames):
		await process_frame
	var release := InputEventKey.new()
	release.keycode = keycode
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame

func _find_minimap(node: Node) -> BattleMinimap:
	if node is BattleMinimap:
		return node as BattleMinimap
	for child: Node in node.get_children():
		var found: BattleMinimap = _find_minimap(child)
		if found != null:
			return found
	return null

func _find_button_by_text(node: Node, text_value: String) -> Button:
	if node is Button and (node as Button).text == text_value:
		return node as Button
	for child: Node in node.get_children():
		var found: Button = _find_button_by_text(child, text_value)
		if found != null:
			return found
	return null

func _minimap_local_to_sim(minimap: BattleMinimap, local_position: Vector2) -> Vector2:
	return Battle3DAdapter.clamp_sim(Vector2(
		local_position.x / maxf(1.0, minimap.size.x) * 3200.0,
		local_position.y / maxf(1.0, minimap.size.y) * 1800.0
	))

func _selected_names(selection: BattleSelectionController) -> PackedStringArray:
	var names := PackedStringArray()
	for formation: BattleFormation in selection.get_selected():
		names.append(formation.display_name)
	names.sort()
	return names

func _staged_snapshot(staging: BattlePreBattleStagingController, formations: Array) -> Dictionary:
	var result: Dictionary = {}
	for item: Variant in formations:
		var formation := item as BattleFormation
		result[formation.display_name] = staging.get_staged_position_for(formation)
	return result

func _intent_snapshot(staging: BattlePreBattleStagingController, formations: Array) -> Dictionary:
	var result: Dictionary = {}
	for item: Variant in formations:
		var formation := item as BattleFormation
		result[formation.display_name] = {
			"kind": staging.get_initial_intent_for(formation),
			"target": staging.get_initial_target_for(formation),
		}
	return result

func _snapshot_vectors_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a.keys():
		if not b.has(key):
			return false
		var left: Vector2 = a[key]
		var right: Vector2 = b[key]
		if not left.is_equal_approx(right):
			return false
	return true

func _intent_snapshots_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a.keys():
		if not b.has(key):
			return false
		var left: Dictionary = a[key]
		var right: Dictionary = b[key]
		if str(left.get("kind", "")) != str(right.get("kind", "")):
			return false
		var left_target: Vector2 = left.get("target", Vector2.ZERO)
		var right_target: Vector2 = right.get("target", Vector2.ZERO)
		if not left_target.is_equal_approx(right_target):
			return false
	return true

func _all_red_formations(node: Node) -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	_collect_red(node, result)
	return result

func _collect_red(node: Node, result: Array[BattleFormation]) -> void:
	if node is BattleFormation:
		var formation := node as BattleFormation
		if formation.faction == "RED":
			result.append(formation)
	for child: Node in node.get_children():
		_collect_red(child, result)

func _visible_red_proxy_count(presentation: Battle3DPresentation) -> int:
	var count: int = 0
	for child: Node in presentation.get_children():
		if child is Node3D and str(child.name).begins_with("Proxy_RED") and (child as Node3D).visible:
			count += 1
	return count

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)

func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	quit(0 if _failures.is_empty() else 1)
