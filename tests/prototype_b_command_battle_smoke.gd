extends SceneTree

const PROTOTYPE_SCENE := preload("res://scenes/discovery/PrototypeB_CommandBattle.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var prototype := PROTOTYPE_SCENE.instantiate()
	root.add_child(prototype)
	await process_frame

	var initial: Dictionary = prototype.debug_snapshot()
	assert(initial["formation_count"] == 5)
	assert(initial["sector_count"] == 3)
	assert(initial["reserve_committed"] == false)

	prototype.debug_select_formation(4)
	prototype.debug_assign_task(0)
	await process_frame
	var committed: Dictionary = prototype.debug_snapshot()
	assert(committed["reserve_committed"] == true)
	assert(committed["reserve_task"] == 0)

	prototype.debug_select_formation(2)
	prototype.debug_assign_task(1)
	await process_frame
	var retasked: Dictionary = prototype.debug_snapshot()
	assert(retasked["charlie_task"] == 1)
	assert(int(retasked["decision_count"]) >= 2)
	assert(retasked["battle_state"] == "RUNNING")

	print("PROTOTYPE_B_COMMAND_BATTLE_SMOKE=PASS")
	quit(0)
