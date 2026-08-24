class_name BattleHUD
extends CanvasLayer

signal restart_requested

@onready var task_label: Label = $Root/TopLeft/Task
@onready var selected_label: Label = $Root/TopLeft/Selected
@onready var order_label: Label = $Root/TopLeft/Order
@onready var blue_health_label: Label = $Root/TopLeft/BlueHealth
@onready var enemy_health_label: Label = $Root/TopLeft/EnemyHealth
@onready var intel_label: Label = $Root/TopLeft/Intel
@onready var objective_label: Label = $Root/TopLeft/Objective
@onready var controls_label: Label = $Root/TopLeft/Controls
@onready var result_panel: PanelContainer = $Root/VictoryPanel
@onready var result_title: Label = $Root/VictoryPanel/VBox/Victory
@onready var result_message: Label = $Root/VictoryPanel/VBox/Message
@onready var restart_button: Button = $Root/VictoryPanel/VBox/Restart

var _force_status_label: Label
var _supply_status_label: Label
var _reserve_status_label: Label
var _rally_status_label: Label

var _intel_state: String = "UNSEEN"
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _enemy_alive: bool = true

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	result_panel.visible = false
	_create_runtime_status_labels()
	controls_label.text = "LMB/Shift/Box select | RMB Move | F Supply | X Withdraw | Shift+X West | 1 Reserve INF | 2 Reserve Armor"
	set_selection_summary([])
	set_order_summary([])
	set_friendly_health(0, 0, 0, 0)
	set_enemy_health(0, 0, true)
	set_intel_state("UNSEEN", Vector2.ZERO)
	set_objectives("AI", false, 0.0, "AI", false, 0.0, true)
	set_supply_status(0, 0, 0.0, false, "Ready")
	set_reserve_status(false, false, "")
	set_rally_status(false)

func _create_runtime_status_labels() -> void:
	var container: VBoxContainer = $Root/TopLeft
	_force_status_label = Label.new()
	_force_status_label.name = "ForceStatus"
	container.add_child(_force_status_label)
	_supply_status_label = Label.new()
	_supply_status_label.name = "SupplyStatus"
	container.add_child(_supply_status_label)
	_reserve_status_label = Label.new()
	_reserve_status_label.name = "ReserveStatus"
	container.add_child(_reserve_status_label)
	_rally_status_label = Label.new()
	_rally_status_label.name = "RallyStatus"
	container.add_child(_rally_status_label)

func set_selection_summary(formations: Array[BattleFormation]) -> void:
	if formations.is_empty():
		selected_label.text = "Selected Formations: NONE"
		return
	var summaries: PackedStringArray = []
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		if formation.is_supply_truck():
			summaries.append("%s HP %d/%d SUP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.get_supply_charges(), formation.supply_capacity])
		elif formation.ammo_capacity > 0:
			var expected_after_supply: int = mini(formation.ammo_capacity, formation.current_ammo + int(round(float(formation.ammo_capacity) * 0.5)))
			summaries.append("%s HP %d/%d AMMO %d/%d → SUPPLY %d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.current_ammo, formation.ammo_capacity, expected_after_supply])
		else:
			summaries.append("%s HP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp])
	selected_label.text = "Selected: %s" % " | ".join(summaries)

func set_order_summary(formations: Array[BattleFormation]) -> void:
	if formations.is_empty():
		order_label.text = "Current Orders: --"
		return
	var orders: PackedStringArray = []
	for formation: BattleFormation in formations:
		if formation != null and is_instance_valid(formation):
			orders.append("%s=%s" % [formation.display_name, formation.get_order()])
	order_label.text = "Current Orders: %s" % " | ".join(orders)

func set_force_status(formations: Array[BattleFormation]) -> void:
	if _force_status_label == null:
		return
	var values: PackedStringArray = []
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		if not formation.is_alive:
			values.append("%s DESTROYED" % formation.display_name)
		elif formation.is_supply_truck():
			values.append("%s HP %d/%d SUP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.get_supply_charges(), formation.supply_capacity])
		elif formation.ammo_capacity > 0:
			values.append("%s HP %d/%d A %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.current_ammo, formation.ammo_capacity])
		else:
			values.append("%s HP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp])
	_force_status_label.text = "BLUE FORCE: %s" % " | ".join(values)

func set_supply_status(charges: int, max_charges: int, progress_seconds: float, active: bool, message: String) -> void:
	if _supply_status_label == null:
		return
	if active:
		_supply_status_label.text = "SUPPLY %d/%d — %.1f/4.0s — %s" % [charges, max_charges, progress_seconds, message]
	else:
		_supply_status_label.text = "SUPPLY %d/%d — %s" % [charges, max_charges, message]

func set_reserve_status(unlocked: bool, committed: bool, choice: String) -> void:
	if _reserve_status_label == null:
		return
	if committed:
		_reserve_status_label.text = "RESERVE: COMMITTED — %s (other choice unavailable)" % choice
	elif unlocked:
		_reserve_status_label.text = "RESERVE: AVAILABLE — [1] INFANTRY / [2] ARMOR — 1 commitment"
	else:
		_reserve_status_label.text = "RESERVE: LOCKED — INFANTRY / ARMOR"

func set_objectives(
	central_owner: String,
	central_contested: bool,
	central_progress: float,
	industrial_owner: String,
	industrial_contested: bool,
	industrial_progress: float,
	industrial_locked: bool
) -> void:
	var central_state: String = "%s%s" % [central_owner, " CONTESTED" if central_contested else ""]
	if central_progress > 0.0:
		central_state += " %d%%" % int(round(central_progress * 100.0))
	var industrial_state: String = "LOCKED / %s" % industrial_owner if industrial_locked else "%s%s" % [industrial_owner, " CONTESTED" if industrial_contested else ""]
	if industrial_progress > 0.0:
		industrial_state += " %d%%" % int(round(industrial_progress * 100.0))
	objective_label.text = "OBJECTIVES — Central: %s | Industrial: %s" % [central_state, industrial_state]

func set_rally_status(forward_active: bool) -> void:
	if _rally_status_label == null:
		return
	_rally_status_label.text = "RALLY — WEST REAR: ACTIVE | BRIDGEHEAD FORWARD: %s" % ("ACTIVE" if forward_active else "INACTIVE")

func set_friendly_health(ifv_hp: int, ifv_max_hp: int, recon_hp: int, recon_max_hp: int) -> void:
	# Legacy focused-smoke compatibility. Full active-force status is shown separately.
	blue_health_label.text = "Friendly Core: IFV %d/%d | RECON %d/%d" % [ifv_hp, ifv_max_hp, recon_hp, recon_max_hp]

func set_enemy_health(current_hp: int, max_hp: int, alive: bool) -> void:
	_enemy_hp = current_hp
	_enemy_max_hp = max_hp
	_enemy_alive = alive
	_refresh_enemy_health()

func set_intel_state(state: String, last_known_position: Vector2) -> void:
	_intel_state = state
	if state == "UNSEEN":
		intel_label.text = "Enemy Intel: UNSEEN"
	elif state == "CONTACT":
		intel_label.text = "Enemy Intel: CONTACT — identity pending"
	elif state == "CONFIRMED":
		intel_label.text = "Enemy Intel: CONFIRMED — RED INF-01"
	elif state == "LAST_KNOWN":
		intel_label.text = "Enemy Intel: LAST KNOWN @ %.0f, %.0f" % [last_known_position.x, last_known_position.y]
	else:
		intel_label.text = "Enemy Intel: %s" % state
	_refresh_enemy_health()

func _refresh_enemy_health() -> void:
	if not _enemy_alive and _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01: DESTROYED"
	elif _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01 HP: %d / %d" % [_enemy_hp, _enemy_max_hp]
	elif _intel_state == "CONTACT":
		enemy_health_label.text = "Enemy Strength: UNKNOWN"
	elif _intel_state == "LAST_KNOWN":
		enemy_health_label.text = "Enemy Strength: STALE / UNKNOWN"
	else:
		enemy_health_label.text = "Enemy Strength: NO CONTACT"

func set_objective(state: String, progress: float) -> void:
	# Legacy API retained for existing QA runners.
	if state == "CAPTURING":
		objective_label.text = "Central Bridgehead: CAPTURING %d%%" % int(round(progress * 100.0))
	else:
		objective_label.text = "Central Bridgehead: %s" % state

func show_victory() -> void:
	result_panel.visible = true
	result_title.text = "VICTORY"
	result_message.text = "Central Bridgehead and Industrial Objective secured."
	task_label.text = "MISSION COMPLETE — BOTH OBJECTIVES HELD"

func show_defeat() -> void:
	result_panel.visible = true
	result_title.text = "DEFEAT"
	result_message.text = "Combat/capture force collapsed with no legal reserve remaining."
	task_label.text = "MISSION FAILED — COMBAT POWER IRRECOVERABLE"

func _on_restart_pressed() -> void:
	restart_requested.emit()
