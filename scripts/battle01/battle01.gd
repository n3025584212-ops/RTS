extends Node2D

const BUILD_ID: String = "BATTLE01_MULTI_FORMATION_COMMAND_V1"
const FORMATION_DEFINITION_PATHS := [
	"res://resources/formations/recon.tres",
	"res://resources/formations/infantry.tres",
	"res://resources/formations/ifv.tres",
	"res://resources/formations/tank.tres",
	"res://resources/formations/artillery.tres",
	"res://resources/formations/logistics.tres",
]

@onready var blue: BattleFormation = $BlueFormation
@onready var recon: BattleFormation = $BlueRecon
@onready var red: BattleFormation = $RedFormation
@onready var selection: BattleSelectionController = $SelectionController
@onready var visibility: BattleVisibilityField = $VisibilityField
@onready var intel: BattleIntelTracker = $IntelTracker
@onready var objective: BattleObjective = $CentralBridgehead
@onready var hud: BattleHUD = $HUD

var _friendlies: Array[BattleFormation] = []
var _match_finished: bool = false
var _combat_started: bool = false
var _ci_los_smoke: bool = false
var _ci_los_phase: int = 0
var _ci_multi_command_smoke: bool = false
var _ci_multi_phase: int = 0

func _ready() -> void:
	if _validate_formation_definitions():
		print("FRONTLINE_FORMATION_DEFINITIONS_READY count=%d" % FORMATION_DEFINITION_PATHS.size())

	_friendlies = [blue, recon]
	selection.configure(_friendlies)
	selection.selection_changed.connect(_on_selection_changed)
	selection.move_order_issued.connect(_on_move_order_issued)

	blue.order_changed.connect(_on_friendly_order_changed)
	blue.health_changed.connect(_on_blue_health_changed)
	blue.attack_fired.connect(_on_attack_fired)
	blue.died.connect(_on_blue_died)

	recon.order_changed.connect(_on_friendly_order_changed)
	recon.health_changed.connect(_on_recon_health_changed)
	recon.attack_fired.connect(_on_attack_fired)
	recon.died.connect(_on_recon_died)

	red.health_changed.connect(_on_red_health_changed)
	red.attack_fired.connect(_on_attack_fired)
	red.died.connect(_on_red_died)

	intel.intel_state_changed.connect(_on_intel_state_changed)
	objective.state_changed.connect(_on_objective_state_changed)
	objective.captured.connect(_on_objective_captured)
	hud.restart_requested.connect(_on_restart_requested)

	blue.set_visibility_field(visibility)
	recon.set_visibility_field(visibility)
	red.set_visibility_field(visibility)

	intel.configure(_friendlies, red, visibility)
	red.set_combat_target(blue)
	objective.set_tracked_formations(_friendlies)
	objective.set_capture_blocked(true)

	_refresh_friendly_health()
	hud.set_enemy_health(red.current_hp, red.max_hp, red.is_alive)
	hud.set_intel_state(BattleIntelTracker.UNSEEN, Vector2.ZERO)
	hud.set_selection_summary(selection.get_selected())
	hud.set_order_summary(selection.get_selected())

	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	_ci_los_smoke = user_args.has("--battle01-ci-los-smoke") or user_args.has("--battle01-ci-intel-combat-smoke")
	_ci_multi_command_smoke = user_args.has("--battle01-ci-multi-command-smoke")

	if _ci_los_smoke:
		blue.move_speed = 700.0
		recon.global_position = Vector2(1050.0, 600.0)
		print("FRONTLINE_CI_LOS_SMOKE_STARTED")
	elif _ci_multi_command_smoke:
		blue.move_speed = 700.0
		recon.move_speed = 700.0
		selection.select_only(recon)
		print("FRONTLINE_SELECTION_RECON_ONLY")
		selection.issue_move(Vector2(1050.0, 600.0))
		print("FRONTLINE_COMMAND_RECON_MOVE")

	print("FRONTLINE_BOOT_OK build=%s" % BUILD_ID)
	print("FRONTLINE_WALKING_SKELETON_READY")
	print("FRONTLINE_COMBAT_SKELETON_READY")
	print("FRONTLINE_RECON_CONTACT_READY")
	print("FRONTLINE_TERRAIN_LOS_SMOKE_READY")
	print("FRONTLINE_MULTI_FORMATION_COMMAND_READY")

func _process(_delta: float) -> void:
	if not _ci_multi_command_smoke or _match_finished:
		return
	if _ci_multi_phase == 1 and blue.global_position.distance_to(Vector2(1000.0, 900.0)) <= 8.0:
		_ci_multi_phase = 2
		selection.select_in_rect(Rect2(Vector2(940.0, 540.0), Vector2(180.0, 420.0)))
		var selected_count: int = selection.get_selected().size()
		print("FRONTLINE_BOX_MULTI_SELECTED count=%d" % selected_count)
		if selected_count == 2:
			var issued_count: int = selection.issue_move(objective.global_position, 70.0)
			print("FRONTLINE_GROUP_MOVE_ISSUED count=%d" % issued_count)
			_ci_multi_phase = 3

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
	var world_point: Vector2 = get_global_mouse_position()
	if selection.handle_input(event, world_point):
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if selection.issue_move(world_point) > 0:
			get_viewport().set_input_as_handled()

func _on_selection_changed(formations: Array[BattleFormation]) -> void:
	hud.set_selection_summary(formations)
	hud.set_order_summary(formations)

func _on_move_order_issued(formations: Array[BattleFormation], _target: Vector2) -> void:
	hud.set_order_summary(formations)

func _on_friendly_order_changed(_order_name: String) -> void:
	hud.set_order_summary(selection.get_selected())

func _on_intel_state_changed(state: String, last_known_position: Vector2) -> void:
	hud.set_intel_state(state, last_known_position)
	print("FRONTLINE_INTEL_STATE state=%s" % state)

	if state == BattleIntelTracker.CONTACT:
		blue.clear_combat_target()
		print("FRONTLINE_INTEL_CONTACT")
	elif state == BattleIntelTracker.CONFIRMED:
		blue.set_combat_target(red)
		print("FRONTLINE_INTEL_CONFIRMED")
		if _ci_multi_command_smoke and _ci_multi_phase == 0:
			_ci_multi_phase = 1
			print("FRONTLINE_RECON_SCOUT_CONFIRMED")
			selection.select_only(blue)
			print("FRONTLINE_SELECTION_IFV_ONLY")
			selection.issue_move(Vector2(1000.0, 900.0))
			print("FRONTLINE_COMMAND_IFV_MOVE")
		elif _ci_los_smoke:
			if _ci_los_phase == 0:
				_ci_los_phase = 1
				recon.global_position = Vector2(1000.0, 900.0)
				print("FRONTLINE_TERRAIN_LOS_TEST_ARMED")
			elif _ci_los_phase == 2:
				_ci_los_phase = 3
				print("FRONTLINE_INTEL_REACQUIRED")
				print("FRONTLINE_FLANK_LOS_REACQUIRED")
				visibility.deploy_smoke(Vector2(1210.0, 750.0), 95.0, 1.4)
				print("FRONTLINE_SMOKE_DEPLOYED")
			elif _ci_los_phase == 4:
				_ci_los_phase = 5
				print("FRONTLINE_SMOKE_CLEARED_REACQUIRED")
				selection.select_only(blue)
				selection.issue_move(objective.global_position)
				print("FRONTLINE_CI_COMBAT_AFTER_LOS_STARTED")
	elif state == BattleIntelTracker.LAST_KNOWN:
		blue.clear_combat_target()
		print("FRONTLINE_INTEL_LAST_KNOWN")
		if _ci_los_smoke:
			if _ci_los_phase == 1:
				if visibility.get_block_reason(recon.global_position, red.global_position) == BattleVisibilityField.TERRAIN:
					print("FRONTLINE_TERRAIN_LOS_BLOCKED")
				_ci_los_phase = 2
				recon.global_position = Vector2(1050.0, 600.0)
			elif _ci_los_phase == 3:
				if visibility.get_block_reason(recon.global_position, red.global_position) == BattleVisibilityField.SMOKE:
					print("FRONTLINE_SMOKE_LOS_BLOCKED")
				_ci_los_phase = 4
	else:
		blue.clear_combat_target()

func _on_blue_health_changed(_current_hp: int, _max_hp_value: int) -> void:
	_refresh_friendly_health()

func _on_recon_health_changed(_current_hp: int, _max_hp_value: int) -> void:
	_refresh_friendly_health()

func _refresh_friendly_health() -> void:
	hud.set_friendly_health(blue.current_hp, blue.max_hp, recon.current_hp, recon.max_hp)

func _on_red_health_changed(current_hp: int, max_hp_value: int) -> void:
	hud.set_enemy_health(current_hp, max_hp_value, current_hp > 0)

func _on_attack_fired(attacker: BattleFormation, _target: BattleFormation, _damage: int) -> void:
	if attacker == red:
		intel.note_target_fired()
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

func _on_recon_died(_formation: BattleFormation) -> void:
	_refresh_friendly_health()
	hud.set_selection_summary(selection.get_selected())
	hud.set_order_summary(selection.get_selected())
	print("FRONTLINE_RECON_LOST")

func _on_objective_state_changed(state: String, progress: float) -> void:
	hud.set_objective(state, progress)

func _on_objective_captured() -> void:
	if _match_finished:
		return
	_match_finished = true
	blue.stop()
	recon.stop()
	red.stop()
	hud.show_victory()
	print("FRONTLINE_OBJECTIVE_CAPTURED objective=CentralBridgehead")
	print("FRONTLINE_VICTORY")
	if _ci_multi_command_smoke and _ci_multi_phase == 3 and not red.is_alive and blue.is_alive and _combat_started:
		print("FRONTLINE_MULTI_FORMATION_COMMAND_SMOKE_PASS")
	elif _ci_los_smoke and _ci_los_phase == 5 and not red.is_alive and blue.is_alive and _combat_started:
		print("FRONTLINE_TERRAIN_LOS_SMOKE_PASS")
		print("FRONTLINE_RECON_CONTACT_SMOKE_PASS")
		print("FRONTLINE_COMBAT_SMOKE_PASS")

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
