extends Node2D

const BUILD_ID: String = "BATTLE01_M2_RUNTIME_SHELL_V1"
const FORMATION_DEFINITION_PATHS := [
	"res://resources/formations/recon.tres",
	"res://resources/formations/infantry.tres",
	"res://resources/formations/ifv.tres",
	"res://resources/formations/tank.tres",
]

@onready var navigation: BattleNavigation = $Navigation
@onready var visibility: BattleVisibilityField = $VisibilityField
@onready var selection: BattleSelectionController = $SelectionController
@onready var intel: BattleIntelTracker = $IntelTracker
@onready var command_area: BattleObjective = $CommandArea
@onready var war_flow: BattlePlayerWarFlow = $PlayerWarFlow
@onready var hud: BattleHUD = $HUD
@onready var roster: BattleFormalCombatRoster = $FormalCombatRoster

@onready var recon: BattleFormation = $BlueRecon
@onready var blue_infantry_1: BattleFormation = $BlueInfantry
@onready var blue_infantry_2: BattleFormation = $BlueInfantry2
@onready var blue_ifv: BattleFormation = $BlueFormation
@onready var blue_armor: BattleFormation = $BlueArmor
@onready var primary_red: BattleFormation = $RedFormation

var _friendlies: Array[BattleFormation] = []
var _red_formations: Array[BattleFormation] = []
var _combat_started: bool = false
var _runtime_shell_attempts: int = 0
var _player_intel_transition_memory: Dictionary = {}

func _ready() -> void:
	if _validate_formation_definitions():
		print("FRONTLINE_M2_FORMATION_DEFINITIONS_READY count=%d" % FORMATION_DEFINITION_PATHS.size())

	_friendlies = [recon, blue_infantry_1, blue_infantry_2, blue_ifv, blue_armor]
	for formation: BattleFormation in _friendlies:
		_bind_friendly(formation)

	# Frozen M2 fire-discipline baseline.
	recon.set_hold_fire_enabled(true)

	primary_red.set_navigation(navigation)
	primary_red.set_visibility_field(visibility)
	_bind_red_formation(primary_red)

	selection.configure(_friendlies)
	selection.selection_changed.connect(_on_selection_changed)
	selection.move_order_issued.connect(_on_move_order_issued)
	selection.advance_order_issued.connect(_on_advance_order_issued)
	selection.hold_fire_changed.connect(_on_hold_fire_changed)

	intel.intel_state_changed.connect(_on_intel_state_changed)
	intel.intel_record_changed.connect(_on_intel_record_changed)
	intel.configure(_friendlies, primary_red, visibility)

	hud.restart_requested.connect(_on_restart_requested)
	war_flow.victory.connect(_on_war_flow_victory)
	war_flow.defeat.connect(_on_war_flow_defeat)
	war_flow.configure(_friendlies)

	hud.set_selection_summary(selection.get_selected())
	hud.set_order_summary(selection.get_selected())
	hud.set_force_status(_friendlies)
	hud.set_enemy_health(primary_red.current_hp, primary_red.max_hp, primary_red.is_alive)
	hud.set_intel_state(BattleIntelTracker.UNSEEN, Vector2.ZERO)

	call_deferred("_complete_runtime_shell")

	print("FRONTLINE_BOOT_OK build=%s" % BUILD_ID)
	print("FRONTLINE_M2_BLUE_ROSTER_READY recon=1 infantry=2 ifv=1 armor=1 supply=0")
	print("FRONTLINE_M2_OBJECTIVE_READY id=RED_COMMAND_AREA count=1")
	print("FRONTLINE_M2_LEGACY_FLOW_DISABLED supply=1 reserve_unlock=1 staging=1 dual_objective=1 reinforcement_spawn=1")

func _complete_runtime_shell() -> void:
	_red_formations = roster.get_initial_enemy_combat_formations()
	if _red_formations.size() != 4:
		if _runtime_shell_attempts < 4:
			_runtime_shell_attempts += 1
			call_deferred("_complete_runtime_shell")
			return
		push_error("M2 runtime shell expected exactly four RED combat formations.")
		return

	for formation: BattleFormation in _red_formations:
		_bind_red_formation(formation)
	intel.add_targets(_red_formations)

	var counts: Dictionary = roster.get_roster_counts()
	print("FRONTLINE_M2_RUNTIME_ROSTER_READY blue=%d red=%d red_infantry=%d red_ifv=%d red_armor=%d" % [
		_friendlies.size(),
		_red_formations.size(),
		int(counts.get("enemy_infantry", 0)),
		int(counts.get("enemy_ifv", 0)),
		int(counts.get("enemy_armor", 0)),
	])

func _bind_friendly(formation: BattleFormation) -> void:
	if formation == null:
		return
	formation.set_navigation(navigation)
	formation.set_visibility_field(visibility)
	if not formation.order_changed.is_connected(_on_friendly_order_changed):
		formation.order_changed.connect(_on_friendly_order_changed)
	if not formation.health_changed.is_connected(_on_any_friendly_health_changed):
		formation.health_changed.connect(_on_any_friendly_health_changed)
	if not formation.ammo_changed.is_connected(_on_any_friendly_ammo_changed):
		formation.ammo_changed.connect(_on_any_friendly_ammo_changed)
	if not formation.attack_fired.is_connected(_on_attack_fired):
		formation.attack_fired.connect(_on_attack_fired)
	if not formation.died.is_connected(_on_friendly_died):
		formation.died.connect(_on_friendly_died)

func _bind_red_formation(formation: BattleFormation) -> void:
	if formation == null or not is_instance_valid(formation):
		return
	formation.set_navigation(navigation)
	formation.set_visibility_field(visibility)
	var health_callback: Callable = _on_red_health_changed.bind(formation)
	if not formation.health_changed.is_connected(health_callback):
		formation.health_changed.connect(health_callback)
	if not formation.attack_fired.is_connected(_on_attack_fired):
		formation.attack_fired.connect(_on_attack_fired)
	if not formation.died.is_connected(_on_red_died):
		formation.died.connect(_on_red_died)

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
	if war_flow.is_match_finished():
		return
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_X:
		war_flow.withdraw_selected()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_H:
		selection.toggle_hold_fire_selected()
		get_viewport().set_input_as_handled()

func _on_selection_changed(formations: Array[BattleFormation]) -> void:
	hud.set_selection_summary(formations)
	hud.set_order_summary(formations)

func _on_move_order_issued(formations: Array[BattleFormation], _target: Vector2) -> void:
	hud.set_order_summary(formations)
	hud.show_command_feedback("MOVE · %d FORMATION%s" % [formations.size(), "S" if formations.size() != 1 else ""], "INFO")

func _on_advance_order_issued(formations: Array[BattleFormation], _target: Vector2) -> void:
	hud.set_order_summary(formations)
	hud.show_command_feedback("ADVANCE · %d FORMATION%s" % [formations.size(), "S" if formations.size() != 1 else ""], "INFO")

func _on_hold_fire_changed(formations: Array[BattleFormation], enabled: bool) -> void:
	hud.set_order_summary(formations)
	hud.show_command_feedback(("HOLD FIRE" if enabled else "WEAPONS FREE") + " · %d FORMATION%s" % [formations.size(), "S" if formations.size() != 1 else ""], "TACTICAL" if enabled else "INFO")

func _on_friendly_order_changed(_order_name: String) -> void:
	hud.set_order_summary(selection.get_selected())

func _on_any_friendly_health_changed(_current_hp: int, _max_hp_value: int) -> void:
	hud.set_force_status(_friendlies)

func _on_any_friendly_ammo_changed(_current_ammo: int, _max_ammo: int) -> void:
	hud.set_force_status(_friendlies)
	hud.set_selection_summary(selection.get_selected())

func _on_friendly_died(_formation: BattleFormation) -> void:
	hud.set_force_status(_friendlies)
	hud.set_selection_summary(selection.get_selected())
	hud.set_order_summary(selection.get_selected())
	war_flow.force_evaluate_match_state()

func _on_red_health_changed(current_hp: int, max_hp_value: int, formation: BattleFormation) -> void:
	if formation == primary_red:
		hud.set_enemy_health(current_hp, max_hp_value, current_hp > 0)

func _on_red_died(formation: BattleFormation) -> void:
	if formation == primary_red:
		hud.set_enemy_health(0, primary_red.max_hp, false)
	war_flow.force_evaluate_match_state()

func _on_attack_fired(attacker: BattleFormation, _target: BattleFormation, _damage: int) -> void:
	if attacker != null and attacker.faction == "RED":
		intel.note_target_fired(attacker)
	if not _combat_started:
		_combat_started = true
		print("FRONTLINE_M2_COMBAT_STARTED")

func _on_intel_state_changed(state: String, last_known_position: Vector2) -> void:
	hud.set_intel_state(state, last_known_position)
	print("FRONTLINE_M2_INTEL_STATE state=%s" % state)

func _on_intel_record_changed(target: BattleFormation, next_state: String, _last_known: Vector2) -> void:
	if target == null:
		return
	var memory: Dictionary = _player_intel_transition_memory.get(target, {"state": BattleIntelTracker.UNSEEN, "was_lost": false})
	var was_lost: bool = bool(memory.get("was_lost", false))
	if next_state == BattleIntelTracker.LAST_KNOWN:
		memory["was_lost"] = true
	elif next_state == BattleIntelTracker.CONFIRMED:
		if was_lost:
			hud.push_alert("TACTICAL", "RECONFIRMED · %s" % target.display_name, "reconfirmed_%s" % target.get_instance_id())
		memory["was_lost"] = false
	memory["state"] = next_state
	_player_intel_transition_memory[target] = memory

func _on_war_flow_victory() -> void:
	print("FRONTLINE_M2_COMMAND_AREA_VICTORY")

func _on_war_flow_defeat() -> void:
	print("FRONTLINE_M2_FORCE_COLLAPSE_DEFEAT")

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
