extends SceneTree

const PROTOTYPE_SCENE := preload("res://scenes/discovery/PrototypeB_TaskReserve.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var prototype := PROTOTYPE_SCENE.instantiate()
	root.add_child(prototype)
	await process_frame

	prototype.debug_select_formation(2)
	prototype.debug_assign_task(0)
	await process_frame

	var state: Dictionary = prototype.debug_snapshot()
	assert(state["reserve_committed"] == true)
	assert(state["reserve_task"] == 0)
	assert(int(state["decision_count"]) >= 1)
	assert(state["alpha_task"] == 0)
	assert(state["bravo_task"] == 1)

	print("PROTOTYPE_B_TASK_RESERVE_SMOKE=PASS")
	quit(0)
