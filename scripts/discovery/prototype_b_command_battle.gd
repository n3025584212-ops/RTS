extends Node2D

const TASK_HOLD := -1
const SECTOR_RIDGE := 0
const SECTOR_CROSSING := 1
const SECTOR_RELAY := 2
const SECTOR_COUNT := 3
const FORMATION_COUNT := 5
const RESERVE_INDEX := 4
const MAP_WIDTH := 1240.0
const FORMATION_SPEED := 112.0
const RESERVE_STABLE_RETURN_SECONDS := 8.0
const OUTCOME_CHECK_START := 82.0

const SECTOR_NAMES := ["RIDGE", "CROSSING", "RELAY"]
const SECTOR_POSITIONS := [Vector2(270.0, 355.0), Vector2(610.0, 320.0), Vector2(950.0, 370.0)]
const STAGING_POSITIONS := [
	Vector2(235.0, 720.0),
	Vector2(440.0, 730.0),
	Vector2(650.0, 735.0),
	Vector2(855.0, 730.0),
	Vector2(1060.0, 760.0),
]
const PRESSURE_PROFILES := [
	[1.55, 1.00, 0.75],
	[0.85, 1.85, 1.00],
	[1.00, 1.20, 1.90],
	[1.55, 1.45, 0.95],
	[0.95, 1.70, 1.60],
	[1.40, 1.30, 1.45],
]
const PHASE_NAMES := [
	"Enemy pressure building on RIDGE",
	"Enemy shifts weight toward CROSSING",
	"Enemy probes RELAY in strength",
	"Enemy counter-pushes RIDGE and CROSSING",
	"Enemy stretches pressure across CROSSING and RELAY",
	"Enemy broad-front pressure",
]

var formations: Array[Dictionary] = []
var sector_pressure: Array[float] = [1.55, 1.00, 0.75]
var sector_control: Array[float] = [0.0, 0.0, 0.0]
var sector_intel: Array[float] = [0.42, 0.35, 0.28]
var selected_formation := 0
var elapsed := 0.0
var decision_count := 0
var reserve_stable_time := 0.0
var phase_index := 0
var previous_phase_index := -1
var battle_state := "RUNNING"
var command_event := "Initial tasks are active. Read the battlefield before moving the reserve."
var enemy_event := "Enemy activity is developing across three objectives."

var situation_label: Label
var selected_label: Label
var formation_status_label: Label
var sector_status_label: Label
var event_label: Label
var outcome_label: Label
var task_buttons: Array[Button] = []
var hold_button: Button

func _ready() -> void:
	_reset_simulation_state()
	_build_ui()
	_update_ui()
	queue_redraw()

func _process(delta: float) -> void:
	if battle_state != "RUNNING":
		_update_ui()
		queue_redraw()
		return

	elapsed += delta
	_update_enemy_pressure()
	_update_intel(delta)
	_update_formations(delta)
	_update_sector_battle(delta)
	_update_reserve_recovery(delta)
	_check_outcome()
	_update_ui()
	queue_redraw()

func _reset_simulation_state() -> void:
	elapsed = 0.0
	decision_count = 0
	reserve_stable_time = 0.0
	phase_index = 0
	previous_phase_index = -1
	battle_state = "RUNNING"
	selected_formation = 0
	sector_pressure = [1.55, 1.00, 0.75]
	sector_control = [0.0, 0.0, 0.0]
	sector_intel = [0.42, 0.35, 0.28]
	command_event = "Initial tasks are active. Read the battlefield before moving the reserve."
	enemy_event = "Enemy activity is developing across three objectives."
	formations = [
		_make_formation("ALPHA", SECTOR_RIDGE, 0, false),
		_make_formation("BRAVO", SECTOR_CROSSING, 1, false),
		_make_formation("CHARLIE", SECTOR_RELAY, 2, false),
		_make_formation("DELTA", SECTOR_CROSSING, 3, false),
		_make_formation("ECHO", TASK_HOLD, 4, true),
	]

func _make_formation(name: String, task: int, staging_index: int, is_reserve: bool) -> Dictionary:
	return {
		"name": name,
		"task": task,
		"position": STAGING_POSITIONS[staging_index],
		"cohesion": 1.0,
		"ammo": 1.0,
		"reserve": is_reserve,
		"committed": not is_reserve,
		"auto_withdraw": false,
		"state": "MOVING" if task != TASK_HOLD else "HOLDING",
	}

func _update_enemy_pressure() -> void:
	phase_index = int(elapsed / 14.0) % PRESSURE_PROFILES.size()
	var profile: Array = PRESSURE_PROFILES[phase_index]
	for sector in range(SECTOR_COUNT):
		sector_pressure[sector] = float(profile[sector])
	if phase_index != previous_phase_index:
		previous_phase_index = phase_index
		enemy_event = PHASE_NAMES[phase_index]

func _update_intel(delta: float) -> void:
	for sector in range(SECTOR_COUNT):
		var friendly_near := false
		for formation in formations:
			var position: Vector2 = formation["position"]
			if position.distance_to(SECTOR_POSITIONS[sector]) <= 165.0:
				friendly_near = true
				break
		if friendly_near:
			sector_intel[sector] = clampf(sector_intel[sector] + delta * 0.060, 0.15, 1.0)
		else:
			sector_intel[sector] = clampf(sector_intel[sector] - delta * 0.018, 0.15, 1.0)

func _update_formations(delta: float) -> void:
	for index in range(formations.size()):
		var formation := formations[index]
		var cohesion: float = formation["cohesion"]
		var ammo: float = formation["ammo"]
		var auto_withdraw: bool = formation["auto_withdraw"]

		if not auto_withdraw and (cohesion <= 0.43 or ammo <= 0.14):
			formation["auto_withdraw"] = true
			auto_withdraw = true
			command_event = "%s is autonomously falling back to recover; its assigned task remains in force." % formation["name"]

		if auto_withdraw:
			var retreat_target: Vector2 = STAGING_POSITIONS[index]
			var retreat_position: Vector2 = formation["position"]
			formation["position"] = retreat_position.move_toward(retreat_target, FORMATION_SPEED * 1.15 * delta)
			if formation["position"].distance_to(retreat_target) <= 12.0:
				formation["cohesion"] = clampf(cohesion + delta * 0.060, 0.35, 1.0)
				formation["ammo"] = clampf(ammo + delta * 0.095, 0.0, 1.0)
				if float(formation["cohesion"]) >= 0.72 and float(formation["ammo"]) >= 0.72:
					formation["auto_withdraw"] = false
					command_event = "%s has recovered and is autonomously resuming its assigned task." % formation["name"]
			formations[index] = formation
			continue

		var task: int = formation["task"]
		var target := _target_for(index, task)
		var current: Vector2 = formation["position"]
		formation["position"] = current.move_toward(target, FORMATION_SPEED * delta)
		if task == TASK_HOLD:
			formation["state"] = "HOLDING / RECOVERING"
			formation["cohesion"] = clampf(cohesion + delta * 0.024, 0.35, 1.0)
			formation["ammo"] = clampf(ammo + delta * 0.055, 0.0, 1.0)
		elif formation["position"].distance_to(target) <= 24.0:
			formation["state"] = "EXECUTING TASK"
		else:
			formation["state"] = "MOVING TO TASK"
		formations[index] = formation

func _update_sector_battle(delta: float) -> void:
	var friendly_power := [0.0, 0.0, 0.0]
	var present := [[], [], []]

	for index in range(formations.size()):
		var formation := formations[index]
		if bool(formation["auto_withdraw"]):
			continue
		var task: int = formation["task"]
		if task == TASK_HOLD:
			continue
		var target := _target_for(index, task)
		var position: Vector2 = formation["position"]
		if position.distance_to(target) > 62.0:
			continue
		var cohesion: float = formation["cohesion"]
		var ammo: float = formation["ammo"]
		var power := cohesion * lerpf(0.55, 1.0, ammo)
		friendly_power[task] += power
		present[task].append(index)

	for sector in range(SECTOR_COUNT):
		var balance: float = float(friendly_power[sector]) - sector_pressure[sector]
		if balance >= 0.0:
			sector_control[sector] = clampf(sector_control[sector] + delta * (3.0 + balance * 5.5), -100.0, 100.0)
		else:
			sector_control[sector] = clampf(sector_control[sector] + delta * balance * 6.5, -100.0, 100.0)

		var sector_present: Array = present[sector]
		if sector_present.is_empty():
			continue
		var pressure_share := sector_pressure[sector] / float(sector_present.size())
		for formation_index in sector_present:
			var formation := formations[formation_index]
			var cohesion: float = formation["cohesion"]
			var ammo: float = formation["ammo"]
			ammo -= delta * (0.010 + pressure_share * 0.009)
			if pressure_share > 1.0:
				cohesion -= delta * 0.030 * (pressure_share - 0.82)
			else:
				cohesion += delta * 0.010
			formation["cohesion"] = clampf(cohesion, 0.34, 1.0)
			formation["ammo"] = clampf(ammo, 0.0, 1.0)
			formations[formation_index] = formation

func _update_reserve_recovery(delta: float) -> void:
	var reserve := formations[RESERVE_INDEX]
	if not bool(reserve["committed"]):
		reserve_stable_time = 0.0
		return
	if bool(reserve["auto_withdraw"]):
		reserve_stable_time = 0.0
		return
	var task: int = reserve["task"]
	if task == TASK_HOLD:
		return
	var balance := _friendly_power_in_sector(task) - sector_pressure[task]
	if sector_control[task] >= 38.0 and balance >= 0.18:
		reserve_stable_time += delta
	else:
		reserve_stable_time = 0.0
	if reserve_stable_time >= RESERVE_STABLE_RETURN_SECONDS:
		reserve["task"] = TASK_HOLD
		reserve["committed"] = false
		reserve["auto_withdraw"] = false
		reserve["state"] = "RETURNING TO RESERVE"
		formations[RESERVE_INDEX] = reserve
		reserve_stable_time = 0.0
		command_event = "ECHO has stabilized %s and is autonomously returning to reserve." % SECTOR_NAMES[task]

func _friendly_power_in_sector(sector: int) -> float:
	var total := 0.0
	for index in range(formations.size()):
		var formation := formations[index]
		if bool(formation["auto_withdraw"]):
			continue
		if int(formation["task"]) != sector:
			continue
		var target := _target_for(index, sector)
		var position: Vector2 = formation["position"]
		if position.distance_to(target) > 62.0:
			continue
		total += float(formation["cohesion"]) * lerpf(0.55, 1.0, float(formation["ammo"]))
	return total

func _target_for(index: int, task: int) -> Vector2:
	if task == TASK_HOLD:
		return STAGING_POSITIONS[index]
	var slot_offset := Vector2.ZERO
	match index:
		0:
			slot_offset = Vector2(-34.0, 36.0)
		1:
			slot_offset = Vector2(-28.0, 42.0)
		2:
			slot_offset = Vector2(30.0, 34.0)
		3:
			slot_offset = Vector2(34.0, 64.0)
		4:
			slot_offset = Vector2(0.0, 86.0)
	return SECTOR_POSITIONS[task] + slot_offset

func _assign_selected_task(task: int) -> void:
	if battle_state != "RUNNING":
		return
	var formation := formations[selected_formation]
	var is_reserve: bool = formation["reserve"]
	var committed: bool = formation["committed"]
	if is_reserve and committed:
		command_event = "ECHO is already committed. Stabilize its current sector before it returns to reserve."
		return
	if is_reserve and task == TASK_HOLD:
		command_event = "ECHO remains uncommitted and available."
		return

	var previous_task: int = formation["task"]
	if previous_task == task:
		return
	formation["task"] = task
	formation["auto_withdraw"] = false
	if is_reserve and task != TASK_HOLD:
		formation["committed"] = true
		reserve_stable_time = 0.0
	formations[selected_formation] = formation
	decision_count += 1
	if is_reserve:
		command_event = "ECHO committed to %s. It now moves and fights autonomously until that sector is stabilized." % _task_name(task)
	else:
		command_event = "%s retasked from %s to %s. Local movement and combat execution remain autonomous." % [formation["name"], _task_name(previous_task), _task_name(task)]

func _select_formation(index: int) -> void:
	selected_formation = clampi(index, 0, formations.size() - 1)
	_update_ui()

func _task_name(task: int) -> String:
	if task == TASK_HOLD:
		return "HOLD"
	return SECTOR_NAMES[task]

func _pressure_readout(sector: int) -> String:
	var intel := sector_intel[sector]
	var pressure := sector_pressure[sector]
	if intel < 0.38:
		return "CONTACT UNCERTAIN"
	var band := "LOW"
	if pressure >= 1.65:
		band = "HIGH"
	elif pressure >= 1.20:
		band = "MEDIUM"
	if intel < 0.72:
		return "%s (EST.)" % band
	return "%s %.2f" % [band, pressure]

func _check_outcome() -> void:
	if sector_control.min() <= -96.0:
		battle_state = "DEFEAT"
		command_event = "A sector collapsed before the force could recover."
		return
	var exhausted := 0
	for formation in formations:
		if float(formation["cohesion"]) <= 0.36:
			exhausted += 1
	if exhausted >= 3:
		battle_state = "DEFEAT"
		command_event = "Too much combat power became ineffective at the same time."
		return
	if elapsed >= OUTCOME_CHECK_START:
		var control_sum := sector_control[0] + sector_control[1] + sector_control[2]
		if control_sum >= 95.0 and sector_control.min() > -25.0:
			battle_state = "VICTORY"
			command_event = "The force has retained initiative across all three objectives."

func _restart() -> void:
	_reset_simulation_state()
	_update_ui()
	queue_redraw()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var top_panel := ColorRect.new()
	top_panel.color = Color(0.035, 0.050, 0.060, 0.95)
	top_panel.position = Vector2(18.0, 16.0)
	top_panel.size = Vector2(1188.0, 132.0)
	layer.add_child(top_panel)

	var top_box := VBoxContainer.new()
	top_box.position = Vector2(15.0, 10.0)
	top_box.size = Vector2(1155.0, 112.0)
	top_panel.add_child(top_box)

	var title := Label.new()
	title.text = "PROTOTYPE B — REPRESENTATIVE COMMAND BATTLE GREYBOX"
	title.add_theme_font_size_override("font_size", 20)
	top_box.add_child(title)

	var rule := Label.new()
	rule.text = "Command loop: read changing contacts → assign/retask formations → let them execute locally → commit or preserve ECHO reserve → respond to the next shift. No individual-unit steering."
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_box.add_child(rule)

	situation_label = Label.new()
	situation_label.add_theme_font_size_override("font_size", 17)
	top_box.add_child(situation_label)

	var side_panel := ColorRect.new()
	side_panel.color = Color(0.050, 0.062, 0.075, 0.98)
	side_panel.position = Vector2(MAP_WIDTH, 0.0)
	side_panel.size = Vector2(360.0, 900.0)
	layer.add_child(side_panel)

	var side_box := VBoxContainer.new()
	side_box.position = Vector2(14.0, 18.0)
	side_box.size = Vector2(332.0, 864.0)
	side_box.add_theme_constant_override("separation", 7)
	side_panel.add_child(side_box)

	var select_header := Label.new()
	select_header.text = "SELECT FORMATION"
	select_header.add_theme_font_size_override("font_size", 17)
	side_box.add_child(select_header)

	var select_grid := GridContainer.new()
	select_grid.columns = 3
	side_box.add_child(select_grid)
	for index in range(formations.size()):
		var button := Button.new()
		button.text = formations[index]["name"]
		button.custom_minimum_size = Vector2(100.0, 38.0)
		button.pressed.connect(_select_formation.bind(index))
		select_grid.add_child(button)

	selected_label = Label.new()
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(selected_label)

	var task_header := Label.new()
	task_header.text = "ASSIGN / RETASK"
	task_header.add_theme_font_size_override("font_size", 17)
	side_box.add_child(task_header)

	task_buttons.clear()
	for sector in range(SECTOR_COUNT):
		var task_button := Button.new()
		task_button.text = "TASK: %s" % SECTOR_NAMES[sector]
		task_button.custom_minimum_size = Vector2(0.0, 38.0)
		task_button.pressed.connect(_assign_selected_task.bind(sector))
		task_buttons.append(task_button)
		side_box.add_child(task_button)

	hold_button = Button.new()
	hold_button.text = "HOLD / RECOVER"
	hold_button.custom_minimum_size = Vector2(0.0, 38.0)
	hold_button.pressed.connect(_assign_selected_task.bind(TASK_HOLD))
	side_box.add_child(hold_button)

	sector_status_label = Label.new()
	sector_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sector_status_label.custom_minimum_size = Vector2(0.0, 124.0)
	side_box.add_child(sector_status_label)

	formation_status_label = Label.new()
	formation_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	formation_status_label.custom_minimum_size = Vector2(0.0, 170.0)
	side_box.add_child(formation_status_label)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(0.0, 92.0)
	side_box.add_child(event_label)

	outcome_label = Label.new()
	outcome_label.add_theme_font_size_override("font_size", 18)
	outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(outcome_label)

	var restart_button := Button.new()
	restart_button.text = "RESTART GREYBOX BATTLE"
	restart_button.custom_minimum_size = Vector2(0.0, 42.0)
	restart_button.pressed.connect(_restart)
	side_box.add_child(restart_button)

func _update_ui() -> void:
	if situation_label == null:
		return
	var phase_remaining := 14.0 - fmod(elapsed, 14.0)
	situation_label.text = "T+%03ds  |  %s  |  next pressure shift ~%.0fs  |  decisions %d" % [int(elapsed), PHASE_NAMES[phase_index], phase_remaining, decision_count]

	var selected := formations[selected_formation]
	selected_label.text = "Selected %s — task %s — %s" % [selected["name"], _task_name(int(selected["task"])), selected["state"]]
	var selected_is_reserve: bool = selected["reserve"]
	for sector in range(task_buttons.size()):
		task_buttons[sector].text = ("COMMIT ECHO: %s" if selected_is_reserve else "TASK: %s") % SECTOR_NAMES[sector]
	hold_button.disabled = selected_is_reserve and bool(selected["committed"])

	var sector_lines: Array[String] = []
	for sector in range(SECTOR_COUNT):
		sector_lines.append("%s  contact %s  intel %d%%  control %+d" % [SECTOR_NAMES[sector], _pressure_readout(sector), int(sector_intel[sector] * 100.0), int(sector_control[sector])])
	sector_status_label.text = "BATTLEFIELD\n" + "\n".join(sector_lines)

	var formation_lines: Array[String] = []
	for index in range(formations.size()):
		var formation := formations[index]
		var reserve_tag := " [RESERVE]" if index == RESERVE_INDEX and not bool(formation["committed"]) else ""
		var withdrawal_tag := " AUTO-FALLBACK" if bool(formation["auto_withdraw"]) else ""
		formation_lines.append("%s%s  %s  C%02d A%02d%s" % [formation["name"], reserve_tag, _task_name(int(formation["task"])), int(float(formation["cohesion"]) * 100.0), int(float(formation["ammo"]) * 100.0), withdrawal_tag])
	formation_status_label.text = "FORMATIONS\n" + "\n".join(formation_lines)

	event_label.text = "ENEMY: %s\nCOMMAND: %s" % [enemy_event, command_event]
	outcome_label.text = "BATTLE STATE: %s" % battle_state

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, MAP_WIDTH, 900.0), Color(0.075, 0.095, 0.095), true)
	draw_rect(Rect2(55.0, 165.0, 1130.0, 650.0), Color(0.165, 0.195, 0.165), true)

	for sector in range(SECTOR_COUNT):
		var pos: Vector2 = SECTOR_POSITIONS[sector]
		var pressure_radius := 42.0 + sector_pressure[sector] * 18.0
		var intel_alpha := lerpf(0.20, 0.55, sector_intel[sector])
		draw_circle(pos, pressure_radius, Color(0.44, 0.09, 0.08, intel_alpha))
		draw_arc(pos, pressure_radius, 0.0, TAU, 48, Color(0.94, 0.30, 0.24, 0.45 + sector_intel[sector] * 0.45), 4.0)
		var marker_count := clampi(int(ceil(sector_pressure[sector])), 1, 3)
		for marker in range(marker_count):
			var marker_pos := pos + Vector2(float(marker - 1) * 23.0, -12.0)
			draw_rect(Rect2(marker_pos - Vector2(7.0, 7.0), Vector2(14.0, 14.0)), Color(0.82, 0.20, 0.16, 0.45 + sector_intel[sector] * 0.5), true)
		var control_normalized := clampf((sector_control[sector] + 100.0) / 200.0, 0.0, 1.0)
		draw_rect(Rect2(pos.x - 92.0, pos.y + 112.0, 184.0, 12.0), Color(0.12, 0.13, 0.13), true)
		draw_rect(Rect2(pos.x - 92.0, pos.y + 112.0, 184.0 * control_normalized, 12.0), Color(0.25, 0.66, 0.88), true)

	for index in range(formations.size()):
		var formation := formations[index]
		var pos: Vector2 = formation["position"]
		var color := Color(0.20, 0.70, 0.95)
		if index == 1:
			color = Color(0.28, 0.58, 0.96)
		elif index == 2:
			color = Color(0.30, 0.82, 0.76)
		elif index == 3:
			color = Color(0.44, 0.66, 0.96)
		elif index == RESERVE_INDEX:
			color = Color(0.96, 0.77, 0.20) if not bool(formation["committed"]) else Color(0.34, 0.86, 0.62)
		if bool(formation["auto_withdraw"]):
			color = color.darkened(0.38)
		draw_circle(pos, 20.0, color)
		draw_arc(pos, 27.0, 0.0, TAU, 32, Color.WHITE if index == selected_formation else Color(0.08, 0.12, 0.14), 3.0)
		for dot in [Vector2(-8.0, -5.0), Vector2(8.0, -5.0), Vector2(0.0, 8.0)]:
			draw_circle(pos + dot, 3.2, Color(0.035, 0.055, 0.070))

func debug_select_formation(index: int) -> void:
	_select_formation(index)

func debug_assign_task(task: int) -> void:
	_assign_selected_task(task)

func debug_snapshot() -> Dictionary:
	return {
		"formation_count": formations.size(),
		"sector_count": SECTOR_COUNT,
		"decision_count": decision_count,
		"reserve_committed": bool(formations[RESERVE_INDEX]["committed"]),
		"reserve_task": int(formations[RESERVE_INDEX]["task"]),
		"alpha_task": int(formations[0]["task"]),
		"charlie_task": int(formations[2]["task"]),
		"battle_state": battle_state,
	}
