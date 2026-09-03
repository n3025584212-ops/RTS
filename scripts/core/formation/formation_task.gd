class_name FormationTask
extends RefCounted

const HOLD: StringName = &"HOLD"
const MOVE: StringName = &"MOVE"
const ASSIGN: StringName = &"ASSIGN"
const RETASK: StringName = &"RETASK"

var task_type: StringName = HOLD
var target_position: Vector2 = Vector2.ZERO
var has_target_position: bool = false
var target_id: StringName = &""
var priority: int = 0
var posture: StringName = &"DEFAULT"
var persistent: bool = true
var metadata: Dictionary = {}

static func hold(priority_value: int = 0) -> FormationTask:
	var task := FormationTask.new()
	task.task_type = HOLD
	task.priority = priority_value
	task.persistent = true
	return task

static func move_to(target: Vector2, priority_value: int = 0) -> FormationTask:
	var task := FormationTask.new()
	task.task_type = MOVE
	task.target_position = target
	task.has_target_position = true
	task.priority = priority_value
	task.persistent = false
	return task

static func assign_to(target: Vector2, target_id_value: StringName = &"", priority_value: int = 0) -> FormationTask:
	var task := FormationTask.new()
	task.task_type = ASSIGN
	task.target_position = target
	task.has_target_position = true
	task.target_id = target_id_value
	task.priority = priority_value
	task.persistent = true
	return task

func duplicate_task() -> FormationTask:
	var copy := FormationTask.new()
	copy.task_type = task_type
	copy.target_position = target_position
	copy.has_target_position = has_target_position
	copy.target_id = target_id
	copy.priority = priority
	copy.posture = posture
	copy.persistent = persistent
	copy.metadata = metadata.duplicate(true)
	return copy

func is_valid() -> bool:
	if task_type == HOLD:
		return true
	return has_target_position
