class_name BattleHUD
extends CanvasLayer

signal restart_requested

const MINIMAP_SCRIPT: Script = preload("res://scripts/battle01/battle_minimap.gd")
const BLUE := Color("4d8cff")
const RED := Color("ff4d4d")
const AMBER := Color("ffc857")
const CYAN := Color("4dd0e1")
const GREEN := Color("6ccb6c")
const TEXT := Color("e6f0f4")
const MUTED := Color("91a4ae")
const PANEL := Color(0.025, 0.055, 0.075, 0.94)
const PANEL_EDGE := Color(0.20, 0.36, 0.44, 0.92)

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
var _mission_line: Label
var _central_state: Label
var _central_progress: ProgressBar
var _industrial_state: Label
var _industrial_progress: ProgressBar
var _selection_header: Label
var _selection_cards: VBoxContainer
var _formation_detail: Label
var _command_feedback: Label
var _supply_title: Label
var _supply_progress: ProgressBar
var _reserve_badge: Label
var _reserve_inf_button: Button
var _reserve_armor_button: Button
var _reserve_dependency: Label
var _intel_summary: Label
var _rally_summary: Label
var _alerts: VBoxContainer
var _debug_container: Control
var _minimap: BattleMinimap

var _selected_formations: Array[BattleFormation] = []
var _known_friendlies: Array[BattleFormation] = []
var _intel_state: String = "UNSEEN"
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _enemy_alive: bool = true
var _central_owner: String = "AI"
var _central_contested: bool = false
var _industrial_owner: String = "AI"
var _industrial_contested: bool = false
var _industrial_locked: bool = true
var _reserve_unlocked: bool = false
var _reserve_committed: bool = false
var _reserve_choice: String = ""
var _last_supply_message: String = ""
var _last_order_text: String = ""
var _alert_records: Array[Dictionary] = []
var _alert_serial: int = 0
var _initialized: bool = false
var _refresh_accumulator: float = 0.0

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	result_panel.visible = false
	_debug_container = $Root/TopLeft
	_debug_container.visible = false
	_create_runtime_status_labels()
	_build_player_hud()
	_style_result_panel()
	set_selection_summary([])
	set_order_summary([])
	set_friendly_health(0, 0, 0, 0)
	set_enemy_health(0, 0, true)
	set_intel_state("UNSEEN", Vector2.ZERO)
	set_objectives("AI", false, 0.0, "AI", false, 0.0, true)
	set_supply_status(0, 0, 0.0, false, "Ready")
	set_reserve_status(false, false, "")
	set_rally_status(false)
	_initialized = true

func _process(delta: float) -> void:
	_refresh_accumulator += delta
	if _refresh_accumulator >= 0.20:
		_refresh_accumulator = 0.0
		_refresh_intel_summary()
		_refresh_alerts(delta + 0.20)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		_debug_container.visible = not _debug_container.visible
		push_alert("INFO", "DEBUG OVERLAY %s" % ("ON" if _debug_container.visible else "OFF"), "debug")

func _build_player_hud() -> void:
	var root: Control = $Root
	var mission_panel := _panel("MissionBattleState", root)
	_set_rect(mission_panel, 18.0, 16.0, 820.0, 108.0)
	var mission_v := _vbox(mission_panel, 14)
	mission_v.add_child(_label("BATTLE STATE  /  OPERATION IRON CROSSING", 11, MUTED))
	_mission_line = _label("SECURE CENTRAL BRIDGEHEAD", 21, TEXT)
	mission_v.add_child(_mission_line)
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 12)
	mission_v.add_child(chips)
	var central_chip := _chip(chips, "CENTRAL  ·  INTERMEDIATE")
	_central_state = _label("AI CONTROL", 13, RED)
	central_chip.add_child(_central_state)
	_central_progress = _progress(central_chip, RED)
	var industrial_chip := _chip(chips, "INDUSTRIAL  ·  FINAL")
	_industrial_state = _label("AI CONTROL  ·  LOCKED", 13, Color(0.58, 0.64, 0.68))
	industrial_chip.add_child(_industrial_state)
	_industrial_progress = _progress(industrial_chip, RED)

	var intel_panel := _panel("EnemyIntel", root)
	_set_right_rect(intel_panel, 350.0, 16.0, 332.0, 108.0)
	var intel_v := _vbox(intel_panel, 14)
	intel_v.add_child(_label("ENEMY INTEL  /  FOW LEGAL", 11, MUTED))
	_intel_summary = _label("NO ENEMY CONTACT", 15, TEXT)
	_intel_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intel_v.add_child(_intel_summary)

	var reserve_panel := _panel("Reserve", root)
	_set_rect(reserve_panel, 18.0, 140.0, 300.0, 248.0)
	var reserve_v := _vbox(reserve_panel, 14)
	reserve_v.add_child(_label("RESERVE  /  ONE CHOICE ONLY", 12, TEXT))
	_reserve_badge = _label("1 COMMITMENT  ·  LOCKED", 14, Color(0.62, 0.67, 0.70))
	reserve_v.add_child(_reserve_badge)
	_reserve_inf_button = _reserve_button("INFANTRY\nLOCKED")
	_reserve_inf_button.pressed.connect(_on_reserve_chosen.bind("INFANTRY"))
	reserve_v.add_child(_reserve_inf_button)
	_reserve_armor_button = _reserve_button("ARMOR\nLOCKED")
	_reserve_armor_button.pressed.connect(_on_reserve_chosen.bind("ARMOR"))
	reserve_v.add_child(_reserve_armor_button)
	_reserve_dependency = _label("SECURE CENTRAL BRIDGEHEAD", 11, MUTED)
	_reserve_dependency.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reserve_v.add_child(_reserve_dependency)

	var rally_panel := _panel("RallyState", root)
	_set_rect(rally_panel, 18.0, 400.0, 300.0, 82.0)
	var rally_v := _vbox(rally_panel, 12)
	rally_v.add_child(_label("RALLY NETWORK", 11, MUTED))
	_rally_summary = _label("WEST REAR  ACTIVE\nBRIDGEHEAD  INACTIVE", 12, TEXT)
	rally_v.add_child(_rally_summary)

	var selection_panel := _panel("SelectionSummary", root)
	_set_bottom_rect(selection_panel, 18.0, 218.0, 620.0, 200.0)
	var selection_v := _vbox(selection_panel, 14)
	_selection_header = _label("NO FORMATION SELECTED", 14, MUTED)
	selection_v.add_child(_selection_header)
	_selection_cards = VBoxContainer.new()
	_selection_cards.add_theme_constant_override("separation", 4)
	selection_v.add_child(_selection_cards)
	_formation_detail = _label("Select a BLUE Formation for exact HP, ammo and order.", 12, MUTED)
	selection_v.add_child(_formation_detail)

	var command_panel := _panel("CommandArea", root)
	_set_bottom_rect(command_panel, 652.0, 218.0, 360.0, 200.0)
	var command_v := _vbox(command_panel, 14)
	command_v.add_child(_label("COMMAND", 12, TEXT))
	var commands := HBoxContainer.new()
	commands.add_theme_constant_override("separation", 6)
	command_v.add_child(commands)
	commands.add_child(_command_chip("MOVE\nRMB", GREEN))
	commands.add_child(_command_chip("SUPPLY\nF", CYAN))
	commands.add_child(_command_chip("WITHDRAW\nX", AMBER))
	_command_feedback = _label("AWAITING ORDERS", 13, MUTED)
	_command_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	command_v.add_child(_command_feedback)
	_supply_title = _label("AMMO SUPPLY  0/2  ·  READY", 12, CYAN)
	command_v.add_child(_supply_title)
	_supply_progress = _progress(command_v, CYAN)

	var alert_panel := _panel("Alerts", root)
	_set_right_rect(alert_panel, 350.0, 140.0, 332.0, 220.0)
	var alert_v := _vbox(alert_panel, 12)
	alert_v.add_child(_label("BATTLE ALERTS", 11, MUTED))
	_alerts = VBoxContainer.new()
	_alerts.add_theme_constant_override("separation", 5)
	alert_v.add_child(_alerts)

	var minimap_panel := _panel("TacticalOverview", root)
	_set_bottom_right_rect(minimap_panel, 350.0, 218.0, 332.0, 200.0)
	var map_v := _vbox(minimap_panel, 10)
	map_v.add_child(_label("TACTICAL OVERVIEW  ·  CLICK TO NAVIGATE", 10, MUTED))
	_minimap = MINIMAP_SCRIPT.new() as BattleMinimap
	_minimap.custom_minimum_size = Vector2(304.0, 160.0)
	_minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_v.add_child(_minimap)
	_minimap.call_deferred("configure", get_parent())

func _style_result_panel() -> void:
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -250.0
	result_panel.offset_top = -145.0
	result_panel.offset_right = 250.0
	result_panel.offset_bottom = 145.0
	result_panel.add_theme_stylebox_override("panel", _style(Color(0.018, 0.040, 0.055, 0.98), BLUE, 3.0, 14.0))
	result_title.add_theme_color_override("font_color", TEXT)
	result_title.add_theme_font_size_override("font_size", 42)
	result_message.add_theme_color_override("font_color", MUTED)
	result_message.add_theme_font_size_override("font_size", 15)
	restart_button.add_theme_stylebox_override("normal", _style(Color(0.08, 0.20, 0.30), BLUE, 2.0, 7.0))
	restart_button.add_theme_color_override("font_color", TEXT)
	restart_button.text = "RESTART BATTLE01"

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
	_selected_formations = formations.duplicate()
	for child: Node in _selection_cards.get_children():
		child.queue_free()
	if formations.is_empty():
		selected_label.text = "Selected Formations: NONE"
		_selection_header.text = "NO FORMATION SELECTED"
		_formation_detail.text = "Select a BLUE Formation for exact HP, ammo and order."
		return
	_selection_header.text = "%d FORMATION%s SELECTED" % [formations.size(), "S" if formations.size() != 1 else ""]
	var debug_summaries := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		debug_summaries.append(_formation_debug_summary(formation))
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0.0, 28.0)
		row.add_theme_constant_override("separation", 8)
		var role := _label(_role_code(formation), 11, BLUE)
		role.custom_minimum_size = Vector2(42.0, 0.0)
		row.add_child(role)
		var callsign := _label(_short_callsign(formation.display_name), 11, TEXT)
		callsign.custom_minimum_size = Vector2(150.0, 0.0)
		row.add_child(callsign)
		var hp := _label("HP %d/%d" % [formation.current_hp, formation.max_hp], 11, _hp_color(formation))
		hp.custom_minimum_size = Vector2(100.0, 0.0)
		row.add_child(hp)
		var ammo_text: String = "CHG %d/%d" % [formation.get_supply_charges(), formation.supply_capacity] if formation.is_supply_truck() else "AMMO %d/%d" % [formation.current_ammo, formation.ammo_capacity]
		var ammo := _label(ammo_text, 11, _ammo_color(formation))
		ammo.custom_minimum_size = Vector2(120.0, 0.0)
		row.add_child(ammo)
		row.add_child(_label(formation.get_order(), 11, _order_color(formation.get_order())))
		_selection_cards.add_child(row)
	selected_label.text = "Selected: %s" % " | ".join(debug_summaries)
	if formations.size() == 1:
		var formation: BattleFormation = formations[0]
		_formation_detail.text = "%s  ·  %s  ·  %s" % [formation.display_name, formation.definition.display_name if formation.definition != null else formation.get_role(), _critical_state(formation)]
	else:
		_formation_detail.text = "Group orders preserve spacing; critical states remain individual."

func set_order_summary(formations: Array[BattleFormation]) -> void:
	if formations.is_empty():
		order_label.text = "Current Orders: --"
		return
	var orders := PackedStringArray()
	var order_counts: Dictionary = {}
	for formation: BattleFormation in formations:
		if formation != null and is_instance_valid(formation):
			orders.append("%s=%s" % [formation.display_name, formation.get_order()])
			order_counts[formation.get_order()] = int(order_counts.get(formation.get_order(), 0)) + 1
	order_label.text = "Current Orders: %s" % " | ".join(orders)
	var display: String
	if order_counts.size() == 1:
		var only_order: String = str(order_counts.keys()[0])
		display = "%s  ·  %d FORMATION%s" % [only_order, formations.size(), "S" if formations.size() != 1 else ""]
	else:
		display = "MIXED ORDERS  ·  %d FORMATIONS" % formations.size()
	if display != _last_order_text:
		_last_order_text = display
		_command_feedback.text = display
	set_selection_summary(formations)

func set_force_status(formations: Array[BattleFormation]) -> void:
	_known_friendlies = formations.duplicate()
	if _force_status_label == null:
		return
	var values := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		values.append(_formation_debug_summary(formation))
		var status_key: String = "formation_%s" % formation.get_instance_id()
		if not formation.is_alive:
			push_alert("CRITICAL", "%s DESTROYED" % formation.display_name, status_key)
		elif formation.ammo_capacity > 0 and formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)):
			push_alert("TACTICAL", "%s  ·  %s" % [formation.display_name, "AMMO EMPTY" if formation.current_ammo == 0 else "LOW AMMO"], status_key)
	_force_status_label.text = "BLUE FORCE: %s" % " | ".join(values)

func set_supply_status(charges: int, max_charges: int, progress_seconds: float, active: bool, message: String) -> void:
	if _supply_status_label != null:
		_supply_status_label.text = "SUPPLY %d/%d — %.1f/4.0s — %s" % [charges, max_charges, progress_seconds, message]
	var concise_state: String = "READY"
	if active: concise_state = "TRANSFER ACTIVE"
	elif charges == 0 and max_charges > 0: concise_state = "EMPTY"
	elif "COMPLETE" in message: concise_state = "COMPLETE"
	elif "INTERRUPTED" in message: concise_state = "INTERRUPTED"
	elif "INVALID" in message: concise_state = "INVALID"
	_supply_title.text = "AMMO SUPPLY  %d/%d  ·  %s" % [charges, max_charges, concise_state]
	_supply_title.add_theme_color_override("font_color", RED if charges == 0 else CYAN)
	_supply_progress.value = clampf(progress_seconds / 4.0 * 100.0, 0.0, 100.0)
	_supply_progress.visible = active
	if _initialized and message != _last_supply_message:
		if "INTERRUPTED" in message or "INVALID" in message:
			push_alert("TACTICAL", message, "supply")
		elif "COMPLETE" in message:
			push_alert("INFO", message.replace("SUPPLY COMPLETE — ", "AMMO TRANSFER COMPLETE  ·  "), "supply")
		elif charges == 0 and max_charges > 0:
			push_alert("TACTICAL", "SUPPLY EMPTY  ·  NO AMMO CHARGES", "supply_empty")
	_last_supply_message = message

func set_reserve_status(unlocked: bool, committed: bool, choice: String) -> void:
	if _reserve_status_label != null:
		_reserve_status_label.text = "RESERVE unlocked=%s committed=%s choice=%s" % [unlocked, committed, choice]
	var was_unlocked: bool = _reserve_unlocked
	var was_committed: bool = _reserve_committed
	_reserve_unlocked = unlocked
	_reserve_committed = committed
	_reserve_choice = choice
	if committed:
		_reserve_badge.text = "COMMITMENT SPENT"
		_reserve_badge.add_theme_color_override("font_color", BLUE)
		_reserve_inf_button.disabled = true
		_reserve_armor_button.disabled = true
		_reserve_inf_button.text = "INFANTRY\n%s" % ("COMMITTED" if choice == "INFANTRY" else "UNAVAILABLE")
		_reserve_armor_button.text = "ARMOR\n%s" % ("COMMITTED" if choice == "ARMOR" else "UNAVAILABLE")
		_reserve_dependency.text = "OTHER CHOICE  ·  OPPORTUNITY SPENT"
	elif unlocked:
		_reserve_badge.text = "1 COMMITMENT  ·  CHOOSE ONE"
		_reserve_badge.add_theme_color_override("font_color", AMBER)
		_reserve_inf_button.disabled = false
		_reserve_armor_button.disabled = false
		_reserve_inf_button.text = "INFANTRY\nAVAILABLE  ·  COMMIT"
		_reserve_armor_button.text = "ARMOR\nAVAILABLE  ·  COMMIT"
		_reserve_dependency.text = "ONE CHOICE ONLY  ·  NO REFUND"
	else:
		_reserve_badge.text = "1 COMMITMENT  ·  LOCKED"
		_reserve_badge.add_theme_color_override("font_color", Color(0.62, 0.67, 0.70))
		_reserve_inf_button.disabled = true
		_reserve_armor_button.disabled = true
		_reserve_inf_button.text = "INFANTRY\nLOCKED"
		_reserve_armor_button.text = "ARMOR\nLOCKED"
		_reserve_dependency.text = "SECURE CENTRAL BRIDGEHEAD"
	if _initialized and unlocked and not was_unlocked:
		push_alert("TACTICAL", "RESERVE UNLOCKED  ·  CHOOSE ONE", "reserve")
	if _initialized and committed and not was_committed:
		push_alert("TACTICAL", "RESERVE COMMITTED  ·  %s  ·  WEST REAR" % choice, "reserve")

func set_objectives(central_owner: String, central_is_contested: bool, central_capture_progress: float, industrial_owner: String, industrial_is_contested: bool, industrial_capture_progress: float, industrial_is_locked: bool) -> void:
	var previous_central_owner: String = _central_owner
	var previous_central_contested: bool = _central_contested
	var previous_industrial_contested: bool = _industrial_contested
	var previous_locked: bool = _industrial_locked
	_central_owner = central_owner
	_central_contested = central_is_contested
	_industrial_owner = industrial_owner
	_industrial_contested = industrial_is_contested
	_industrial_locked = industrial_is_locked
	_central_state.text = _objective_state_text(central_owner, central_is_contested, false, central_capture_progress).replace("UNLOCKED", "ACTIVE")
	_central_state.add_theme_color_override("font_color", _objective_color(central_owner, central_is_contested, false))
	_central_progress.value = central_capture_progress * 100.0
	_central_progress.visible = central_capture_progress > 0.0
	_industrial_state.text = _objective_state_text(industrial_owner, industrial_is_contested, industrial_is_locked, industrial_capture_progress)
	_industrial_state.add_theme_color_override("font_color", _objective_color(industrial_owner, industrial_is_contested, industrial_is_locked))
	_industrial_progress.value = industrial_capture_progress * 100.0
	_industrial_progress.visible = industrial_capture_progress > 0.0
	objective_label.text = "OBJECTIVES Central=%s contested=%s %.0f%% Industrial=%s contested=%s locked=%s %.0f%%" % [central_owner, central_is_contested, central_capture_progress * 100.0, industrial_owner, industrial_is_contested, industrial_is_locked, industrial_capture_progress * 100.0]
	_mission_line.text = "SECURE CENTRAL BRIDGEHEAD" if industrial_is_locked else "INDUSTRIAL CONTESTED  ·  HOLD CENTRAL" if industrial_is_contested else "SECURE INDUSTRIAL  ·  HOLD CENTRAL"
	if _initialized:
		if central_is_contested and not previous_central_contested:
			push_alert("TACTICAL", "CENTRAL BRIDGEHEAD CONTESTED", "central_contested")
		if industrial_is_contested and not previous_industrial_contested:
			push_alert("CRITICAL", "INDUSTRIAL OBJECTIVE CONTESTED", "industrial_contested")
		if central_owner == BattleObjective.OWNER_PLAYER and previous_central_owner != BattleObjective.OWNER_PLAYER:
			push_alert("TACTICAL", "CENTRAL SECURED", "central_captured")
		if previous_locked and not industrial_is_locked:
			push_alert("TACTICAL", "FINAL OBJECTIVE UNLOCKED  ·  INDUSTRIAL", "industrial_unlocked")

func set_rally_status(forward_active: bool) -> void:
	if _rally_status_label != null:
		_rally_status_label.text = "RALLY WEST=ACTIVE FORWARD=%s" % forward_active
	var was_active: bool = _rally_summary != null and "BRIDGEHEAD  ACTIVE" in _rally_summary.text
	_rally_summary.text = "WEST REAR  ACTIVE\nBRIDGEHEAD  %s" % ("ACTIVE" if forward_active else "INACTIVE")
	_rally_summary.add_theme_color_override("font_color", CYAN if forward_active else TEXT)
	if _initialized and forward_active != was_active:
		push_alert("TACTICAL", "BRIDGEHEAD FORWARD RALLY  ·  %s" % ("ACTIVE" if forward_active else "INACTIVE"), "forward_rally")

func set_friendly_health(ifv_hp: int, ifv_max_hp: int, recon_hp: int, recon_max_hp: int) -> void:
	blue_health_label.text = "Friendly Core: IFV %d/%d | RECON %d/%d" % [ifv_hp, ifv_max_hp, recon_hp, recon_max_hp]

func set_enemy_health(current_hp: int, max_hp: int, alive: bool) -> void:
	_enemy_hp = current_hp
	_enemy_max_hp = max_hp
	_enemy_alive = alive
	_refresh_enemy_health()

func set_intel_state(next_state: String, _last_known_position: Vector2) -> void:
	var previous: String = _intel_state
	_intel_state = next_state
	intel_label.text = "Enemy Intel: %s" % next_state.replace("_", " ")
	_refresh_enemy_health()
	_refresh_intel_summary()
	if _initialized and previous != next_state:
		if next_state == "CONTACT": push_alert("TACTICAL", "CONTACT  ·  IDENTITY UNKNOWN", "intel_primary")
		elif next_state == "CONFIRMED": push_alert("TACTICAL", "CONFIRMED  ·  RED FORMATION", "intel_primary")
		elif next_state == "LAST_KNOWN": push_alert("INFO", "CONTACT LOST  ·  LAST KNOWN FROZEN", "intel_primary")

func _refresh_enemy_health() -> void:
	if not _enemy_alive and _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01: DESTROYED"
	elif _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01 HP: %d / %d" % [_enemy_hp, _enemy_max_hp]
	else:
		enemy_health_label.text = "Enemy Strength: HIDDEN"

func _refresh_intel_summary() -> void:
	if _intel_summary == null:
		return
	var rows := PackedStringArray()
	var battle: Node = get_parent()
	if battle != null:
		for child: Node in battle.get_children():
			if not child is BattleFormation:
				continue
			var formation := child as BattleFormation
			if formation.faction != "RED" or not formation.is_alive or not formation.visible:
				continue
			if formation.intel_state == BattleIntelTracker.CONTACT:
				rows.append("◇ CONTACT  ·  IDENTITY UNKNOWN")
			elif formation.intel_state == BattleIntelTracker.CONFIRMED:
				rows.append("■ %s  ·  %s" % [_short_callsign(formation.display_name), _role_code(formation)])
			elif formation.intel_state == BattleIntelTracker.LAST_KNOWN:
				rows.append("⌁ LAST KNOWN  ·  STALE / STATIC")
	if rows.is_empty():
		_intel_summary.text = "NO ENEMY CONTACT"
		_intel_summary.add_theme_color_override("font_color", MUTED)
	else:
		_intel_summary.text = "\n".join(rows.slice(0, 3))
		_intel_summary.add_theme_color_override("font_color", RED if _intel_state == BattleIntelTracker.CONFIRMED else AMBER)

func set_objective(state: String, progress: float) -> void:
	objective_label.text = "Central Bridgehead: %s %d%%" % [state, int(round(progress * 100.0))]

func show_command_feedback(message: String, level: String = "INFO") -> void:
	_command_feedback.text = message
	push_alert(level, message, "command")

func push_alert(level: String, message: String, key: String = "") -> void:
	if _alerts == null or message.is_empty():
		return
	var semantic_key: String = key if not key.is_empty() else message
	for record: Dictionary in _alert_records:
		if str(record.get("key", "")) == semantic_key:
			record["time"] = 7.0 if level == "CRITICAL" else 4.5
			(record["label"] as Label).text = "%s  %s" % [_alert_prefix(level), message]
			return
	_alert_serial += 1
	var alert := _label("%s  %s" % [_alert_prefix(level), message], 12, _alert_color(level))
	alert.name = "Alert%d" % _alert_serial
	alert.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alert.custom_minimum_size = Vector2(0.0, 34.0)
	alert.add_theme_stylebox_override("normal", _style(Color(_alert_color(level), 0.10), Color(_alert_color(level), 0.55), 1.0, 4.0))
	_alerts.add_child(alert)
	_alert_records.append({"key": semantic_key, "level": level, "time": 7.0 if level == "CRITICAL" else 4.5, "label": alert})
	while _alert_records.size() > 4:
		_remove_alert_at(0)

func _refresh_alerts(delta: float) -> void:
	for index: int in range(_alert_records.size() - 1, -1, -1):
		var record: Dictionary = _alert_records[index]
		record["time"] = float(record["time"]) - delta
		_alert_records[index] = record
		if float(record["time"]) <= 0.0:
			_remove_alert_at(index)

func _remove_alert_at(index: int) -> void:
	if index < 0 or index >= _alert_records.size(): return
	var alert_label: Label = _alert_records[index]["label"] as Label
	if alert_label != null: alert_label.queue_free()
	_alert_records.remove_at(index)

func show_victory() -> void:
	result_panel.visible = true
	result_panel.add_theme_stylebox_override("panel", _style(Color(0.018, 0.040, 0.055, 0.98), BLUE, 3.0, 14.0))
	result_title.text = "VICTORY"
	result_title.add_theme_color_override("font_color", BLUE.lightened(0.22))
	result_message.text = "CENTRAL HELD  ·  INDUSTRIAL HELD\nMission complete. Decisive ground secured."
	_mission_line.text = "MISSION COMPLETE  ·  BOTH OBJECTIVES HELD"
	push_alert("CRITICAL", "VICTORY", "terminal")

func show_defeat() -> void:
	result_panel.visible = true
	result_panel.add_theme_stylebox_override("panel", _style(Color(0.055, 0.025, 0.030, 0.98), RED, 3.0, 14.0))
	result_title.text = "DEFEAT"
	result_title.add_theme_color_override("font_color", RED.lightened(0.12))
	result_message.text = "COMBAT / CAPTURE POWER IRRECOVERABLE\nNo legal reserve remains."
	_mission_line.text = "MISSION FAILED  ·  COMBAT POWER IRRECOVERABLE"
	push_alert("CRITICAL", "DEFEAT", "terminal")

func _on_reserve_chosen(kind: String) -> void:
	var war_flow := get_parent().get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	if war_flow != null: war_flow.deploy_reserve(kind)

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _formation_debug_summary(formation: BattleFormation) -> String:
	if not formation.is_alive: return "%s DESTROYED" % formation.display_name
	if formation.is_supply_truck(): return "%s HP %d/%d SUP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.get_supply_charges(), formation.supply_capacity]
	return "%s HP %d/%d AMMO %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.current_ammo, formation.ammo_capacity]

func _role_code(formation: BattleFormation) -> String:
	match formation.get_role():
		"RECON": return "RCN"
		"INFANTRY": return "INF"
		"IFV": return "IFV"
		"TANK", "ARMOR": return "ARM"
		"LOGISTICS": return "LOG"
	return "FRM"

func _short_callsign(value: String) -> String:
	return value.replace("BLUE ", "").replace("RED ", "")

func _critical_state(formation: BattleFormation) -> String:
	if not formation.is_alive: return "DESTROYED"
	if formation.is_supply_truck(): return "AMMO SUPPLY  ·  CHARGES %d/%d" % [formation.get_supply_charges(), formation.supply_capacity]
	if formation.current_ammo == 0: return "AMMO EMPTY"
	if formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)): return "LOW AMMO"
	return "COMBAT READY"

func _hp_color(formation: BattleFormation) -> Color:
	var ratio: float = float(formation.current_hp) / float(maxi(1, formation.max_hp))
	return RED if ratio <= 0.25 else AMBER if ratio <= 0.55 else GREEN

func _ammo_color(formation: BattleFormation) -> Color:
	if formation.is_supply_truck(): return RED if formation.get_supply_charges() == 0 else CYAN
	return RED if formation.current_ammo == 0 else AMBER if formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)) else TEXT

func _order_color(order: String) -> Color:
	if order == "MOVE": return GREEN
	if order == "WITHDRAW": return AMBER
	if order == "DESTROYED": return RED
	return BLUE

func _objective_state_text(owner: String, contested: bool, locked: bool, capture_progress: float) -> String:
	if contested: return "%s CONTROL  ·  CONTESTED" % owner
	if locked: return "%s CONTROL  ·  LOCKED" % owner
	if capture_progress > 0.0: return "%s CONTROL  ·  CAPTURING %d%%" % [owner, int(round(capture_progress * 100.0))]
	return "%s CONTROL  ·  UNLOCKED" % owner

func _objective_color(owner: String, contested: bool, locked: bool) -> Color:
	if contested: return AMBER
	if locked: return Color(0.58, 0.64, 0.68)
	if owner == BattleObjective.OWNER_PLAYER: return BLUE
	if owner == BattleObjective.OWNER_AI: return RED
	return Color(0.69, 0.69, 0.69)

func _alert_prefix(level: String) -> String:
	if level == "CRITICAL": return "▲"
	if level == "TACTICAL": return "◆"
	return "●"

func _alert_color(level: String) -> Color:
	if level == "CRITICAL": return RED
	if level == "TACTICAL": return AMBER
	return Color(0.64, 0.84, 1.0)

func _panel(node_name: String, parent: Control) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(PANEL, PANEL_EDGE, 1.0, 7.0))
	parent.add_child(panel)
	return panel

func _vbox(parent: Control, margin: int) -> VBoxContainer:
	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin - 3)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin - 3)
	parent.add_child(margin_container)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin_container.add_child(box)
	return box

func _chip(parent: Control, heading: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(382.0, 43.0)
	panel.add_theme_stylebox_override("panel", _style(Color(0.045, 0.085, 0.105, 0.92), Color(0.18, 0.31, 0.37, 0.8), 1.0, 4.0))
	parent.add_child(panel)
	var box := _vbox(panel, 8)
	box.add_child(_label(heading, 9, MUTED))
	return box

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _progress(parent: Control, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0.0, 5.0)
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.add_theme_stylebox_override("background", _style(Color(0.02, 0.04, 0.05, 0.9), Color(0.12, 0.20, 0.24, 0.8), 1.0, 2.0))
	bar.add_theme_stylebox_override("fill", _style(Color(color, 0.88), color, 0.0, 2.0))
	parent.add_child(bar)
	return bar

func _reserve_button(value: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color(0.50, 0.56, 0.59))
	button.add_theme_stylebox_override("normal", _style(Color(0.05, 0.10, 0.13), Color(0.20, 0.35, 0.42), 1.0, 5.0))
	button.add_theme_stylebox_override("hover", _style(Color(0.07, 0.16, 0.22), BLUE, 1.5, 5.0))
	button.add_theme_stylebox_override("disabled", _style(Color(0.035, 0.06, 0.075), Color(0.15, 0.20, 0.22), 1.0, 5.0))
	return button

func _command_chip(value: String, color: Color) -> Label:
	var label := _label(value, 11, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(103.0, 44.0)
	label.add_theme_stylebox_override("normal", _style(Color(color, 0.08), Color(color, 0.58), 1.0, 4.0))
	return label

func _style(fill: Color, border: Color, width: float, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(int(round(width)))
	box.set_corner_radius_all(int(round(radius)))
	return box

func _set_rect(control: Control, left: float, top: float, width: float, height: float) -> void:
	control.position = Vector2(left, top)
	control.size = Vector2(width, height)

func _set_right_rect(control: Control, right_margin: float, top: float, width: float, height: float) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.offset_left = -right_margin
	control.offset_right = -right_margin + width
	control.offset_top = top
	control.offset_bottom = top + height

func _set_bottom_rect(control: Control, left: float, bottom_margin: float, width: float, height: float) -> void:
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = left
	control.offset_right = left + width
	control.offset_top = -bottom_margin
	control.offset_bottom = -bottom_margin + height

func _set_bottom_right_rect(control: Control, right_margin: float, bottom_margin: float, width: float, height: float) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = -right_margin
	control.offset_right = -right_margin + width
	control.offset_top = -bottom_margin
	control.offset_bottom = -bottom_margin + height
