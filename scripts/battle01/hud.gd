class_name BattleHUD
extends CanvasLayer

signal restart_requested

@onready var debug_container: VBoxContainer = $Root/TopLeft
@onready var task_label: Label = $Root/TopLeft/Task
@onready var selected_label: Label = $Root/TopLeft/Selected
@onready var order_label: Label = $Root/TopLeft/Order
@onready var blue_health_label: Label = $Root/TopLeft/BlueHealth
@onready var enemy_health_label: Label = $Root/TopLeft/EnemyHealth
@onready var intel_label: Label = $Root/TopLeft/Intel
@onready var objective_label: Label = $Root/TopLeft/Objective
@onready var controls_label: Label = $Root/TopLeft/Controls
@onready var notice_label: Label = $Root/TopLeft/PrototypeNotice
@onready var result_panel: PanelContainer = $Root/VictoryPanel
@onready var result_title: Label = $Root/VictoryPanel/VBox/Victory
@onready var result_message: Label = $Root/VictoryPanel/VBox/Message
@onready var restart_button: Button = $Root/VictoryPanel/VBox/Restart

var _selected_formations: Array[BattleFormation] = []
var _known_friendlies: Array[BattleFormation] = []
var _intel_state: String = BattleIntelTracker.UNSEEN
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _enemy_alive: bool = true
var _last_feedback: String = "AWAITING ORDERS"

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	result_panel.visible = false
	debug_container.visible = true
	_install_tactical_skin()
	task_label.text = "MISSION: Probe the defense, commit combat power, secure the RED Command Area."
	controls_label.text = "WASD PAN  •  WHEEL ZOOM  •  LMB SELECT  •  RMB MOVE  •  SHIFT+RMB ADVANCE"
	notice_label.text = "TACTICAL NET  •  COMMAND LINK ACTIVE"
	set_selection_summary([])
	set_order_summary([])
	set_force_status([])
	set_intel_state(BattleIntelTracker.UNSEEN, Vector2.ZERO)
	set_command_area(BattleObjective.OWNER_AI, false, 0.0, false)

func _install_tactical_skin() -> void:
	var backing := Panel.new()
	backing.name = "TacticalStatusBacking"
	backing.position = Vector2(14.0, 14.0)
	backing.size = Vector2(780.0, 292.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.035, 0.043, 0.88)
	style.border_color = Color(0.16, 0.38, 0.48, 0.82)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	backing.add_theme_stylebox_override("panel", style)
	$Root.add_child(backing)
	$Root.move_child(backing, 0)

	for child: Node in debug_container.get_children():
		if child is Label:
			var label := child as Label
			label.add_theme_color_override("font_color", Color(0.89, 0.94, 0.95))
			label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
			label.add_theme_constant_override("shadow_offset_x", 1)
			label.add_theme_constant_override("shadow_offset_y", 1)
	controls_label.add_theme_font_size_override("font_size", 12)
	notice_label.add_theme_color_override("font_color", Color(0.45, 0.76, 0.88))
	objective_label.add_theme_color_override("font_color", Color(1.0, 0.70, 0.30))


func set_selection_summary(formations: Array[BattleFormation]) -> void:
	_selected_formations = formations.duplicate()
	if formations.is_empty():
		selected_label.text = "Selected Formations: NONE"
		return
	var names := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation != null and is_instance_valid(formation):
			names.append(formation.display_name)
	selected_label.text = "Selected Formations: %s" % " | ".join(names)

func set_order_summary(formations: Array[BattleFormation]) -> void:
	if formations.is_empty():
		order_label.text = "Current Orders: %s" % _last_feedback
		return
	var values := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		var fire_state: String = "HOLD FIRE" if formation.is_hold_fire_enabled() else "WEAPONS FREE"
		values.append("%s=%s/%s" % [formation.display_name, formation.get_order(), fire_state])
	order_label.text = "Current Orders: %s" % " | ".join(values)

func set_force_status(formations: Array[BattleFormation]) -> void:
	_known_friendlies = formations.duplicate()
	if formations.is_empty():
		blue_health_label.text = "BLUE FORCE: initializing"
		return
	var values := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		var life: String = "DESTROYED" if not formation.is_alive else "HP %d/%d" % [formation.current_hp, formation.max_hp]
		var ammo: String = ""
		if formation.ammo_capacity > 0:
			ammo = " AMMO %d/%d" % [formation.current_ammo, formation.ammo_capacity]
		values.append("%s %s%s" % [formation.display_name, life, ammo])
	blue_health_label.text = "BLUE FORCE: %s" % " | ".join(values)

func set_friendly_health(_ifv_hp: int, _ifv_max_hp: int, _recon_hp: int, _recon_max_hp: int) -> void:
	# Legacy compatibility. The active M2 HUD uses set_force_status for all five BLUE formations.
	if not _known_friendlies.is_empty():
		set_force_status(_known_friendlies)

func set_enemy_health(current_hp: int, max_hp: int, alive: bool) -> void:
	_enemy_hp = current_hp
	_enemy_max_hp = max_hp
	_enemy_alive = alive
	_refresh_enemy_health()

func set_intel_state(next_state: String, _last_known_position: Vector2) -> void:
	_intel_state = next_state
	intel_label.text = "Enemy Intel: %s" % next_state.replace("_", " ")
	_refresh_enemy_health()

func _refresh_enemy_health() -> void:
	if _intel_state != BattleIntelTracker.CONFIRMED:
		enemy_health_label.text = "Enemy Strength: HIDDEN"
		return
	if not _enemy_alive:
		enemy_health_label.text = "Confirmed RED contact: DESTROYED"
	else:
		enemy_health_label.text = "Confirmed RED contact: HP %d/%d" % [_enemy_hp, _enemy_max_hp]

func set_command_area(owner: String, contested: bool, progress: float, counterattack_clear: bool) -> void:
	var state_text: String
	if contested:
		state_text = "CONTESTED"
	elif progress > 0.0:
		state_text = "CAPTURING %.0f%%" % (progress * 100.0)
	elif owner == BattleObjective.OWNER_PLAYER:
		state_text = "PLAYER CONTROL"
	elif owner == BattleObjective.OWNER_AI:
		state_text = "RED CONTROL"
	else:
		state_text = owner
	var zone_text: String = "CLEAR" if counterattack_clear else "RED COMBAT POWER NEARBY"
	objective_label.text = "RED COMMAND AREA: %s | COUNTERATTACK ZONE: %s" % [state_text, zone_text]

func show_command_feedback(message: String, _level: String = "INFO") -> void:
	_last_feedback = message
	order_label.text = "Current Orders: %s" % message

func push_alert(level: String, message: String, _key: String = "") -> void:
	if message.is_empty():
		return
	notice_label.text = "TACTICAL NET · %s · %s" % [level, message]

func show_victory() -> void:
	result_panel.visible = true
	result_title.text = "VICTORY"
	result_message.text = "RED Command Area secured and local counterattack zone cleared."

func show_defeat() -> void:
	result_panel.visible = true
	result_title.text = "DEFEAT"
	result_message.text = "All four BLUE main combat formations were destroyed."

# ---------------------------------------------------------------------
# Legacy API compatibility. Inactive historical scripts may still parse against
# BattleHUD, but M2 does not expose Supply, Reserve, forward-rally or dual-objective UI.
# ---------------------------------------------------------------------

func set_supply_status(_charges: int, _max_charges: int, _progress_seconds: float, _active: bool, _message: String) -> void:
	pass

func set_reserve_status(_unlocked: bool, _committed: bool, _choice: String) -> void:
	pass

func set_rally_status(_forward_active: bool) -> void:
	pass

func set_objectives(
	_central_owner: String,
	_central_is_contested: bool,
	_central_capture_progress: float,
	industrial_owner: String,
	industrial_is_contested: bool,
	industrial_capture_progress: float,
	_industrial_is_locked: bool
) -> void:
	set_command_area(industrial_owner, industrial_is_contested, industrial_capture_progress, false)

func set_objective(state: String, progress: float) -> void:
	objective_label.text = "RED COMMAND AREA: %s %.0f%%" % [state, progress * 100.0]

func _on_restart_pressed() -> void:
	restart_requested.emit()
