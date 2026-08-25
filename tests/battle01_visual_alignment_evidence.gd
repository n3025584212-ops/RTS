extends SceneTree

## Battle01 visual target alignment evidence generator.
## Captures 14 screenshots covering the 8 approved visual target groups:
##   P0-01 -> 01_opening_hud
##   P0-02 -> 02a_reserve_locked / 02b_reserve_unlocked
##   P0-03 -> 03_selection_command
##   P0-04 -> 04a_river_bridge_village / 04b_industrial_zone
##   P0-05 -> 05_high_intensity
##   P1-06 -> 06a_near_lod / 06b_mid_lod / 06c_far_lod
##   P1-07 -> 07a_industrial_locked / 07b_central_contested / 07c_central_capturing
##   FINAL-01 -> 08_final_battle_presentation
## Gameplay rules are NOT modified; only presentation states are staged.

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _battle: Node2D
var _output_dir: String

func _initialize() -> void:
	_output_dir = ProjectSettings.globalize_path("res://docs/audits/evidence/battle01_visual_alignment_v1")
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
	var war_flow := _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var camera := _battle.get_node("BattleCamera") as Camera2D
	var intel := _battle.get_node("IntelTracker") as BattleIntelTracker
	var central := _battle.get_node("CentralBridgehead") as BattleObjective
	var industrial := _battle.get_node("IndustrialObjective") as BattleObjective
	var blue_infantry := _battle.get_node("BlueInfantry") as BattleFormation
	var recon := _battle.get_node("BlueRecon") as BattleFormation
	var ifv := _battle.get_node("BlueFormation") as BattleFormation
	var red := _battle.get_node("RedFormation") as BattleFormation
	var enemy_ai := _battle.get_node("EnemyAIController") as BattleEnemyAIController
	enemy_ai.process_mode = Node.PROCESS_MODE_DISABLED

	# ---- P0-02: Reserve deployment reference -------------------------------
	camera.position = Vector2(1050.0, 900.0)
	camera.zoom = Vector2.ONE
	await _settle(8)
	await _capture("02a_reserve_locked.png")

	central.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	war_flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	await _settle(8)
	await _capture("02b_reserve_unlocked.png")

	# ---- P0-03: Command feedback -------------------------------------------
	selection.select_only(recon)
	selection.add_to_selection(ifv)
	selection.issue_move(Vector2(1120.0, 900.0))
	await _settle(8)
	await _capture("03_selection_command.png")

	# ---- P0-04: Terrain + objective layer ----------------------------------
	camera.position = Vector2(1400.0, 900.0)
	camera.zoom = Vector2(0.55, 0.55)
	await _settle(8)
	await _capture("04a_river_bridge_village.png")

	camera.position = Vector2(2720.0, 900.0)
	await _settle(8)
	await _capture("04b_industrial_zone.png")

	# ---- P0-05: High intensity combat at Industrial -------------------------
	var red_two := _battle.get_node("RedInfantry2") as BattleFormation
	blue_infantry.global_position = industrial.global_position + Vector2(-35.0, 0.0)
	ifv.global_position = industrial.global_position + Vector2(-95.0, 55.0)
	red.global_position = industrial.global_position + Vector2(35.0, 0.0)
	red_two.global_position = industrial.global_position + Vector2(95.0, -55.0)
	blue_infantry.stop()
	ifv.stop()
	red.stop()
	red_two.stop()
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
	await _settle(30)
	await _capture("05_high_intensity.png")

	# ---- P1-06: Unit readability across zoom / LOD --------------------------
	camera.position = Vector2(1050.0, 900.0)
	camera.zoom = Vector2(1.35, 1.35)
	await _settle(8)
	await _capture("06a_near_lod.png")
	camera.zoom = Vector2.ONE
	await _settle(8)
	await _capture("06b_mid_lod.png")
	camera.zoom = Vector2(0.55, 0.55)
	await _settle(8)
	await _capture("06c_far_lod.png")

	# ---- P1-07: Objective state machine (Industrial) ------------------------
	# AI re-takes Central -> Industrial shows LOCKED.
	central.force_owner_for_test(BattleObjective.OWNER_AI)
	industrial.player_capture_locked = true
	industrial.queue_redraw()
	camera.position = industrial.global_position
	camera.zoom = Vector2(1.1, 1.1)
	await _settle(8)
	await _capture("07a_industrial_locked.png")

	# Unlock -> Blue pushes in with Red present -> CONTESTED.
	industrial.unlock_player_capture()
	blue_infantry.global_position = industrial.global_position + Vector2(-30.0, 0.0)
	ifv.global_position = industrial.global_position + Vector2(-90.0, 40.0)
	red.global_position = industrial.global_position + Vector2(30.0, 0.0)
	red_two.global_position = industrial.global_position + Vector2(95.0, -55.0)
	blue_infantry.stop()
	ifv.stop()
	red.stop()
	red_two.stop()
	red.clear_combat_target()
	red_two.clear_combat_target()
	blue_infantry.clear_combat_target()
	await _settle(8)
	await _capture("07b_central_contested.png")

	# Red leaves -> capturing progress climbs.
	red.global_position = Vector2(2050.0, 900.0)
	red_two.global_position = Vector2(2200.0, 1100.0)
	await _settle(60)
	await _capture("07c_central_capturing.png")

	# ---- FINAL-01: Final battle presentation --------------------------------
	central.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	war_flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	industrial.unlock_player_capture()
	var reserve: BattleFormation = war_flow.deploy_reserve("ARMOR")
	selection.select_only(reserve)
	selection.add_to_selection(blue_infantry)
	selection.issue_move(Vector2(1120.0, 900.0))
	camera.position = Vector2(1050.0, 900.0)
	camera.zoom = Vector2.ONE
	await _settle(8)
	await _capture("08_final_battle_presentation.png")

	_battle.queue_free()
	await _settle(4)

	print("FRONTLINE_VISUAL_ALIGNMENT_EVIDENCE_PASS dir=%s screenshots=14" % _output_dir)
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
