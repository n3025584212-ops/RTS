class_name TaskCommandService
extends Node

signal task_issued(formations: Array, task: FormationTask, accepted_count: int)
signal task_rejected(formation: Node, task: FormationTask)

var _last_tasks: Dictionary = {}
var _command_revision: int = 0

func assign_task(formations: Array, task: FormationTask) -> int:
	if task == null or not task.is_valid():
		return 0
	var accepted_count: int = 0
	for value: Variant in formations:
		var formation: Node = value as Node
		if formation == null or not is_instance_valid(formation) or not formation.has_method("set_formation_task"):
			continue
		var task_copy: FormationTask = task.duplicate_task()
		var accepted: bool = bool(formation.call("set_formation_task", task_copy))
		if accepted:
			accepted_count += 1
			_last_tasks[formation.get_instance_id()] = task_copy
		else:
			task_rejected.emit(formation, task_copy)
	_command_revision += 1
	task_issued.emit(formations, task, accepted_count)
	return accepted_count

func hold(formations: Array, priority: int = 0) -> int:
	return assign_task(formations, FormationTask.hold(priority))

func move(formations: Array, target: Vector2, priority: int = 0) -> int:
	return assign_task(formations, FormationTask.move_to(target, priority))

func assign_area(formations: Array, target: Vector2, target_id: StringName = &"", priority: int = 0) -> int:
	return assign_task(formations, FormationTask.assign_to(target, target_id, priority))

func get_last_task(formation: Node) -> FormationTask:
	if formation == null:
		return null
	var task: FormationTask = _last_tasks.get(formation.get_instance_id()) as FormationTask
	return task.duplicate_task() if task != null else null

func get_command_revision() -> int:
	return _command_revision
