extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _battle: Node2D
var _output_dir: String

func _initialize() -> void:
	_output_dir = ProjectSettings.globalize_path("res://docs/audits/evidence/battle01_visual_v2")
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			_output_dir = argument.trim_prefix("--output-dir=")
	DirAccess.make_dir_recursive_absolute(_output_dir)
	call_deferred("_run")

func _run() -> void:
	_battle = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(_battle)
	await _settle(12)
	await _capture("01_opening_hud.png")

	var selection := _battle.get_node("SelectionController") as BattleSelectionController
	var recon := _battle.get_node("BlueRecon") as BattleFormation
	var ifv := _battle.get_node("BlueFormation") as BattleFormation
	selection.select_only(recon)
	selection.add_to_selection(ifv)
	selection.issue_move(Vector2(1120.0, 900.0))
	await _settle(8)
	await _capture("02_multi_selection_move.png")

	var camera := _battle.get_node("BattleCamera") as Camera2D
	var intel := _battle.get_node("IntelTracker") as BattleIntelTracker
	var red := _battle.get_node("RedFormation") as BattleFormation
	camera.position = Vector2(1600.0, 900.0)
	camera.zoom = Vector2(0.55, 0.55)
	intel.note_target_fired(red)
	await _settle(8)
	await _capture("03_far_zoom_confirmed_minimap.png")
	var enemy_ai := _battle.get_node("EnemyAIController") as BattleEnemyAIController
	enemy_ai.process_mode = Node.PROCESS_MODE_DISABLED
	for child: Node in _battle.get_children():
		if child is BattleFormation and (child as BattleFormation).faction == "RED":
			(child as BattleFormation).clear_combat_target()

	var central := _battle.get_node("CentralBridgehead") as BattleObjective
	var war_flow := _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var blue_infantry := _battle.get_node("BlueInfantry") as BattleFormation
	camera.position = central.global_position
	camera.zoom = Vector2(1.15, 1.15)
	blue_infantry.global_position = central.global_position + Vector2(-30.0, 0.0)
	red.global_position = central.global_position + Vector2(30.0, 0.0)
	await _settle(8)
	await _capture("04_central_contested.png")
	red.global_position = Vector2(2050.0, 900.0)
	await _settle(50)
	await _capture("05_central_capture_progress.png")

	central.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	war_flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	for child: Node in _battle.get_children():
		if child is BattleFormation and (child as BattleFormation).faction == "RED":
			(child as BattleFormation).clear_combat_target()
	camera.position = Vector2(1050.0, 900.0)
	camera.zoom = Vector2.ONE
	await _settle(8)
	await _capture("06_central_reserve_industrial_unlocked.png")
	var reserve: BattleFormation = war_flow.deploy_reserve("INFANTRY")
	selection.select_only(reserve)
	selection.add_to_selection(blue_infantry)
	war_flow.withdraw_selected(true)
	await _settle(8)
	await _capture("07_reserve_committed_withdraw.png")

	var truck := _battle.get_node("BlueSupply") as BattleFormation
	var target := blue_infantry
	truck.global_position = Vector2(580.0, 1060.0)
	target.global_position = Vector2(660.0, 1060.0)
	truck.stop()
	target.stop()
	target.current_ammo = 0
	target.ammo_changed.emit(target.current_ammo, target.ammo_capacity)
	selection.select_only(truck)
	selection.add_to_selection(target)
	war_flow.start_supply(truck, target)
	await _settle(90)
	await _capture("08_ammo_supply_progress.png")
	target.issue_move(Vector2(820.0, 1060.0))
	await _settle(8)
	await _capture("09_ammo_supply_interrupted.png")
	target.global_position = Vector2(660.0, 1060.0)
	target.stop()
	target.current_ammo = 0
	target.ammo_changed.emit(target.current_ammo, target.ammo_capacity)
	war_flow.start_supply(truck, target)
	await _settle(180)
	await _settle(80)
	await _capture("10_ammo_supply_complete.png")

	var industrial := _battle.get_node("IndustrialObjective") as BattleObjective
	var red_two := _battle.get_node("RedInfantry2") as BattleFormation
	blue_infantry.global_position = industrial.global_position + Vector2(-35.0, 0.0)
	ifv.global_position = industrial.global_position + Vector2(-95.0, 55.0)
	red.global_position = industrial.global_position + Vector2(35.0, 0.0)
	red_two.global_position = industrial.global_position + Vector2(95.0, -55.0)
	blue_infantry.set_combat_target(red)
	ifv.set_combat_target(red_two)
	red.set_combat_target(blue_infantry)
	red_two.set_combat_target(ifv)
	intel.note_target_fired(red)
	intel.note_target_fired(red_two)
	selection.select_only(blue_infantry)
	selection.add_to_selection(ifv)
	camera.position = industrial.global_position
	camera.zoom = Vector2(1.08, 1.08)
	await _settle(2)
	await _capture("11_industrial_contested_high_intensity.png")

	industrial.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	war_flow.force_evaluate_match_state()
	await _settle(8)
	await _capture("12_victory_overlay.png")

	_battle.queue_free()
	await _settle(4)
	_battle = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(_battle)
	await _settle(10)
	war_flow = _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	for formation: BattleFormation in war_flow.get_friendlies():
		if not formation.is_supply_truck():
			formation.take_damage(formation.max_hp)
	war_flow.force_evaluate_match_state()
	await _settle(8)
	await _capture("13_defeat_overlay.png")

	print("FRONTLINE_VISUAL_EVIDENCE_PASS dir=%s screenshots=13" % _output_dir)
	quit(0)

func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame

func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Visual evidence capture returned an empty image: %s" % filename)
		quit(2)
		return
	var path: String = _output_dir.path_join(filename)
	var error: Error = image.save_png(path)
	if error != OK:
		push_error("Visual evidence save failed path=%s error=%s" % [path, error_string(error)])
		quit(3)
		return
	print("FRONTLINE_VISUAL_SCREENSHOT path=%s size=%dx%d" % [path, image.get_width(), image.get_height()])
