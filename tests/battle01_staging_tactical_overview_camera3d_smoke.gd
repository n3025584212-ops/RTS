extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_STAGING_TACTICAL_OVERVIEW_CAMERA3D_SMOKE_BEGIN")
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	var staging: BattlePreBattleStagingController = battle.get_node_or_null("PreBattleStaging") as BattlePreBattleStagingController
	if staging == null:
		_failures.append("STAGING_CONTROLLER_MISSING")
		_finish(battle)
		return
	staging.force_keep_staging_for_test()
	for _frame: int in range(6):
		await process_frame

	var camera: BattleCamera3D = battle.get_node_or_null("World3D/BattleCamera3D") as BattleCamera3D
	var input3d: Battle3DInput = battle.get_node_or_null("Input3D") as Battle3DInput
	var selection: BattleSelectionController = battle.get_node_or_null("SelectionController") as BattleSelectionController
	var enemy_ai: Node = battle.get_node_or_null("EnemyAIController")
	var central: BattleObjective = battle.get_node_or_null("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node_or_null("IndustrialObjective") as BattleObjective
	var minimap: BattleMinimap = _find_minimap(battle)
	var presentation: Node3D = battle.get_node_or_null("World3D/Presentation3D") as Node3D
	var recon: BattleFormation = battle.get_node_or_null("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node_or_null("BlueInfantry") as BattleFormation
	var ifv: BattleFormation = battle.get_node_or_null("BlueFormation") as BattleFormation
	var supply: BattleFormation = battle.get_node_or_null("BlueSupply") as BattleFormation

	var bound_ok: bool = (
		staging.is_staging_active()
		and camera != null
		and minimap != null
		and minimap.is_camera3d_bound_for_test()
		and minimap.get_camera3d_for_test() == camera
		and minimap.mouse_filter == Control.MOUSE_FILTER_STOP
	)
	_require(bound_ok, "STAGING_TACTICAL_OVERVIEW_CAMERA3D_BOUND_PASS")
	_require(minimap != null and minimap.has_camera_indicator_for_test(), "TACTICAL_OVERVIEW_CAMERA_INDICATOR_PASS")

	if minimap == null or camera == null or selection == null or recon == null:
		_failures.append("FOCUSED_SMOKE_RUNTIME_BINDING_INCOMPLETE")
		_finish(battle)
		return
	if minimap.size.x <= 2.0 or minimap.size.y <= 2.0:
		_failures.append("MINIMAP_LAYOUT_SIZE_INVALID")
		_finish(battle)
		return

	var click_local := Vector2(minimap.size.x * 0.76, minimap.size.y * 0.38)
	var click_expected := Vector2(3200.0 * 0.76, 1800.0 * 0.38)
	var click_before: Vector2 = camera.focus_sim
	var click_consumed: bool = minimap.simulate_click_for_test(click_local)
	var click_after: Vector2 = camera.focus_sim
	var click_ok: bool = click_consumed and click_before.distance_to(click_after) > 100.0 and click_after.distance_to(click_expected) <= 2.0
	_require(click_ok, "STAGING_MINIMAP_CLICK_CAMERA3D_PASS")

	var drag_from := Vector2(minimap.size.x * 0.24, minimap.size.y * 0.72)
	var drag_to := Vector2(minimap.size.x * 0.66, minimap.size.y * 0.64)
	var drag_expected := Vector2(3200.0 * 0.66, 1800.0 * 0.64)
	var drag_before: Vector2 = camera.focus_sim
	var drag_consumed: bool = minimap.simulate_drag_for_test(drag_from, drag_to)
	var drag_after: Vector2 = camera.focus_sim
	var drag_ok: bool = drag_consumed and drag_before.distance_to(drag_after) > 100.0 and drag_after.distance_to(drag_expected) <= 2.0
	_require(drag_ok, "STAGING_MINIMAP_DRAG_CAMERA3D_PASS")

	var central_owner_before: String = central.get_control_owner() if central != null else ""
	var industrial_owner_before: String = industrial.get_control_owner() if industrial != null else ""
	for _frame: int in range(8):
		await process_frame
	var freeze_ok: bool = (
		staging.is_staging_active()
		and is_equal_approx(staging.get_battle_elapsed_for_test(), 0.0)
		and enemy_ai != null and not enemy_ai.is_processing()
		and central != null and not central.is_processing() and central.progress <= 0.001 and central.get_control_owner() == central_owner_before
		and industrial != null and not industrial.is_processing() and industrial.progress <= 0.001 and industrial.get_control_owner() == industrial_owner_before
	)
	_require(freeze_ok, "STAGING_MINIMAP_NAV_DOES_NOT_START_BATTLE_PASS")

	var red_formations: Array[BattleFormation] = []
	_collect_red_formations(battle, red_formations)
	var all_unseen: bool = not red_formations.is_empty()
	for red: BattleFormation in red_formations:
		if red.intel_state != BattleIntelTracker.UNSEEN:
			all_unseen = false
			break
	var east_local := Vector2(minimap.size.x * 0.78, minimap.size.y * 0.52)
	minimap.simulate_click_for_test(east_local)
	await process_frame
	var fow_ok: bool = all_unseen and minimap.get_drawable_red_count_for_test() == 0 and _visible_red_proxy_count(presentation) == 0
	_require(fow_ok, "STAGING_MINIMAP_CAMERA_FOW_NO_RED_LEAK_PASS")

	selection.select_only(recon)
	var queued: int = selection.issue_move(Vector2(1460.0, 460.0), 0.0)
	var selected_before: Array[BattleFormation] = selection.get_selected().duplicate()
	var intent_before: String = staging.get_initial_intent_for(recon)
	var positions_before: Dictionary = _blue_positions([recon, infantry, ifv, supply])
	var isolation_consumed: bool = minimap.simulate_drag_for_test(Vector2(minimap.size.x * 0.32, minimap.size.y * 0.30), Vector2(minimap.size.x * 0.58, minimap.size.y * 0.44))
	var selected_after: Array[BattleFormation] = selection.get_selected()
	var isolation_ok: bool = (
		queued == 1
		and isolation_consumed
		and minimap.did_consume_last_gui_event_for_test()
		and selected_after == selected_before
		and staging.get_initial_intent_for(recon) == intent_before
		and _blue_positions_equal(positions_before, _blue_positions([recon, infantry, ifv, supply]))
	)
	_require(isolation_ok, "STAGING_MINIMAP_INPUT_ISOLATION_PASS")

	var zoom_before: float = camera.height_world
	camera.adjust_zoom(1)
	_require(camera.height_world < zoom_before and input3d != null, "STAGING_CAMERA3D_WHEEL_ZOOM_API_PASS")

	var started: bool = staging.start_battle_for_test()
	await process_frame
	var live_before: Vector2 = camera.focus_sim
	var live_local := Vector2(minimap.size.x * 0.42, minimap.size.y * 0.77)
	var live_expected := Vector2(3200.0 * 0.42, 1800.0 * 0.77)
	var live_consumed: bool = minimap.simulate_click_for_test(live_local)
	var live_after: Vector2 = camera.focus_sim
	var live_ok: bool = started and not staging.is_staging_active() and live_consumed and live_before.distance_to(live_after) > 100.0 and live_after.distance_to(live_expected) <= 2.0
	_require(live_ok, "LIVE_MINIMAP_CAMERA3D_NAVIGATION_PASS")

	if _failures.is_empty():
		print("FRONTLINE_STAGING_TACTICAL_OVERVIEW_CAMERA3D_SMOKE_PASS")
		_finish(battle, 0)
	else:
		_finish(battle, 1)

func _find_minimap(node: Node) -> BattleMinimap:
	if node is BattleMinimap:
		return node as BattleMinimap
	for child: Node in node.get_children():
		var found: BattleMinimap = _find_minimap(child)
		if found != null:
			return found
	return null

func _collect_red_formations(node: Node, result: Array[BattleFormation]) -> void:
	if node is BattleFormation:
		var formation := node as BattleFormation
		if formation.faction == "RED":
			result.append(formation)
	for child: Node in node.get_children():
		_collect_red_formations(child, result)

func _visible_red_proxy_count(presentation: Node3D) -> int:
	if presentation == null:
		return 0
	var count: int = 0
	for child: Node in presentation.get_children():
		if child is Node3D and child.name.begins_with("Proxy_RED_") and (child as Node3D).visible:
			count += 1
	return count

func _blue_positions(formations: Array[BattleFormation]) -> Dictionary:
	var snapshot: Dictionary = {}
	for formation: BattleFormation in formations:
		if formation != null:
			snapshot[formation] = formation.global_position
	return snapshot

func _blue_positions_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a.keys():
		if not b.has(key):
			return false
		if not Vector2(a[key]).is_equal_approx(Vector2(b[key])):
			return false
	return true

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("STAGING_TACTICAL_OVERVIEW_CAMERA3D_SMOKE_FAILURE %s" % marker)

func _finish(battle: Node, code: int = 1) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	for failure: String in _failures:
		push_error("STAGING_TACTICAL_OVERVIEW_CAMERA3D_SMOKE_FAILURE %s" % failure)
	quit(code)
