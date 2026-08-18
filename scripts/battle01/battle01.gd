extends Node2D

const BUILD_ID: String = "BATTLE01_WALKING_SKELETON_INTERACTION_V1"

@onready var formation: BattleFormation = $BlueFormation
@onready var objective: BattleObjective = $CentralBridgehead
@onready var hud: BattleHUD = $HUD

var _victory: bool = false

func _ready() -> void:
	formation.selection_changed.connect(_on_formation_selection_changed)
	formation.order_changed.connect(_on_formation_order_changed)
	objective.state_changed.connect(_on_objective_state_changed)
	objective.captured.connect(_on_objective_captured)
	hud.restart_requested.connect(_on_restart_requested)
	objective.set_tracked_formation(formation)
	print("FRONTLINE_BOOT_OK build=%s" % BUILD_ID)
	print("FRONTLINE_WALKING_SKELETON_READY")

func _unhandled_input(event: InputEvent) -> void:
	if _victory:
		return
	if event is InputEventMouseButton and event.pressed:
		var world_point: Vector2 = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_LEFT:
			formation.set_selected(formation.contains_world_point(world_point))
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and formation.is_selected:
			formation.issue_move(world_point)
			get_viewport().set_input_as_handled()

func _on_formation_selection_changed(selected: bool) -> void:
	hud.set_selected(selected)

func _on_formation_order_changed(order_name: String) -> void:
	hud.set_order(order_name)

func _on_objective_state_changed(state: String, progress: float) -> void:
	hud.set_objective(state, progress)

func _on_objective_captured() -> void:
	_victory = true
	formation.stop()
	hud.show_victory()
	print("FRONTLINE_OBJECTIVE_CAPTURED objective=CentralBridgehead")
	print("FRONTLINE_VICTORY")

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
