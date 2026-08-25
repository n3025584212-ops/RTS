extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_3D_FOUNDATION_SMOKE_BEGIN")
	var battle := BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame

	var world := battle.get_node_or_null("World3D") as Node3D
	var camera := battle.get_node_or_null("World3D/BattleCamera3D") as Camera3D
	var presentation := battle.get_node_or_null("World3D/Presentation3D") as Battle3DPresentation
	var input3d := battle.get_node_or_null("Input3D") as Battle3DInput
	var blue := battle.get_node_or_null("BlueFormation") as BattleFormation
	var hud := battle.get_node_or_null("HUD") as CanvasLayer

	_require(RenderingServer.get_current_rendering_method() == "forward_plus", "FORWARD_PLUS_RENDERER_PASS")
	_require(world != null, "WORLD_3D_READY_PASS")
	_require(camera != null and camera.current, "CAMERA_3D_READY_PASS")
	_require(hud != null, "HUD_2D_PRESERVED_PASS")

	var sample := Vector2(1600.0, 900.0)
	var roundtrip := Battle3DAdapter.world_to_sim(Battle3DAdapter.sim_to_world(sample))
	_require(roundtrip.distance_to(sample) <= 0.01, "SIM_TO_3D_ADAPTER_PASS")
	_require(presentation != null and blue != null and presentation.has_proxy(blue) and presentation.get_bound_count() >= 10, "FORMATION_3D_BINDING_PASS")

	var moved := false
	if input3d != null and blue != null:
		var before := blue.global_position
		var issued := input3d.issue_move_for_test(blue, before + Vector2(260.0, 0.0))
		blue._update_movement(0.5)
		moved = issued and blue.global_position.distance_to(before) > 1.0
	_require(moved, "SELECTION_COMMAND_3D_MOVE_PASS")

	var gameplay_reachable := (
		battle.get_node_or_null("VisibilityField") != null
		and battle.get_node_or_null("IntelTracker") != null
		and battle.get_node_or_null("EnemyAIController") != null
		and battle.get_node_or_null("CentralBridgehead") != null
		and battle.get_node_or_null("IndustrialObjective") != null
		and battle.get_node_or_null("PlayerWarFlow") != null
		and battle.get_node_or_null("FormalCombatRoster") != null
	)
	_require(gameplay_reachable, "GAMEPLAY_SYSTEMS_REACHABLE_PASS")
	_require(battle.get_node_or_null("Battlefield") == null and battle.get_node_or_null("BattleCamera") == null, "LEGACY_2D_WORLD_REPLACED_PASS")
	_require(blue != null and blue.modulate.a <= 0.001, "LEGACY_2D_FORMATION_PRESENTATION_HIDDEN_PASS")

	if _failures.is_empty():
		print("FRONTLINE_3D_FOUNDATION_SMOKE_PASS")
		battle.queue_free()
		quit(0)
	else:
		for failure: String in _failures:
			push_error("BATTLE01_3D_FOUNDATION_FAILURE %s" % failure)
		battle.queue_free()
		quit(1)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
