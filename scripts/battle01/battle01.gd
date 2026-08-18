extends Node2D

const BUILD_ID: String = "BATTLE01_FORMATION_DEFINITIONS_V1"
const FORMATION_DEFINITION_PATHS := [
	"res://resources/formations/recon.tres",
	"res://resources/formations/infantry.tres",
	"res://resources/formations/ifv.tres",
	"res://resources/formations/tank.tres",
	"res://resources/formations/artillery.tres",
	"res://resources/formations/logistics.tres",
]

@onready var blue: BattleFormation = $BlueFormation
@onready var red: BattleFormation = $RedFormation
@onready var objective: BattleObjective = $CentralBridgehead
@onready var hud: BattleHUD = $HUD

var _match_finished: bool = false
var _combat_started: bool = false
var _ci_combat_smoke: bool = false

func _ready() -> void:
	if _validate_formation_definitions():
		print("FRONTLINE_FORMATION_DEFINITIONS_READY count=%d" % FORMATION_DEFINITION_PATHS.size())

	blue.selection_changed.connect(_on_blue_selection_changed)
	blue.order_changed.connect(_on_blue_order_changed)
	blue.health_changed.connect(_on_blue_health_changed)
	blue.attack_fired.connect(_on_attack_fired)
	blue.died.connect(_on_blue_died)

	red.health_changed.connect(_on_red_health_changed)
	red.attack_fired.connect(_on_attack_fired)
	red.died.connect(_on_red_died)

	objective.state_changed.connect(_on_objective_state_changed)
	objective.captured.connect(_on_objective_captured)
	hud.restart_requested.connect(_on_restart_requested)

	blue.set_combat_target(red)
	red.set_combat_target(blue)
	objective.set_tracked_formation(blue)
	objective.set_capture_blocked(true)

	hud.set_blue_health(blue.current_hp, blue.max_hp)
	hud.set_enemy_health(red.current_hp, red.max_hp, red.is_alive)

	_ci_combat_smoke = OS.get_cmdline_user_args().has("--battle01-ci-combat-smoke")
	if _ci_combat_smoke:
		blue.move_speed = 700.0
		blue.set_selected(true)
		blue.issue_move(objective.global_position)
		print("FRONTLINE_CI_COMBAT_SMOKE_STARTED")

	print("FRONTLINE_BOOT_OK build=%s" % BUILD_ID)
	print("FRONTLINE_WALKING_SKELETON_READY")
	print("FRONTLINE_COMBAT_SKELETON_READY")

func _validate_formation_definitions() -> bool:
	var valid := true
	for path: String in FORMATION_DEFINITION_PATHS:
		var loaded: Resource = load(path)
		if loaded == null or not loaded is FormationDefinition:
			push_error("Formation definition failed to load: %s" % path)
			valid = false
			continue
		var formation_definition := loaded as FormationDefinition
		var errors: PackedStringArray = formation_definition.validate()
		if not errors.is_empty():
			push_error("Formation definition invalid %s: %s" % [path, ", ".join(errors)])
			valid = false
	return valid

func _unhandled_input(event: InputEvent) -> void:
	if _match_finished:
		return
	if event is InputEventMouseButton and event.pressed:
		var world_point: Vector2 = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_LEFT:
			blue.set_selected(blue.contains_world_point(world_point))
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and blue.is_selected:
			blue.issue_move(world_point)
			get_viewport().set_input_as_handled()

func _on_blue_selection_changed(selected: bool) -> void:
	hud.set_selected(selected)

func _on_blue_order_changed(order_name: String) -> void:
	hud.set_order(order_name)

func _on_blue_health_changed(current_hp: int, max_hp_value: int) -> void:
	hud.set_blue_health(current_hp, max_hp_value)

func _on_red_health_changed(current_hp: int, max_hp_value: int) -> void:
	hud.set_enemy_health(current_hp, max_hp_value, current_hp > 0)

func _on_attack_fired(_attacker: BattleFormation, _target: BattleFormation, _damage: int) -> void:
	if not _combat_started:
		_combat_started = true
		print("FRONTLINE_COMBAT_STARTED")

func _on_red_died(_formation: BattleFormation) -> void:
	objective.set_capture_blocked(false)
	hud.set_enemy_health(0, red.max_hp, false)
	print("FRONTLINE_RED_DESTROYED")

func _on_blue_died(_formation: BattleFormation) -> void:
	if _match_finished:
		return
	_match_finished = true
	red.stop()
	hud.show_defeat()
	print("FRONTLINE_DEFEAT")

func _on_objective_state_changed(state: String, progress: float) -> void:
	hud.set_objective(state, progress)

func _on_objective_captured() -> void:
	if _match_finished:
		return
	_match_finished = true
	blue.stop()
	red.stop()
	hud.show_victory()
	print("FRONTLINE_OBJECTIVE_CAPTURED objective=CentralBridgehead")
	print("FRONTLINE_VICTORY")
	if _ci_combat_smoke and not red.is_alive and blue.is_alive and _combat_started:
		print("FRONTLINE_COMBAT_SMOKE_PASS")

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
