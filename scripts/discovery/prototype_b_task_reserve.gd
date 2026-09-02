extends Node2D

const SECTOR_LEFT := 0
const SECTOR_RIGHT := 1
const TASK_HOLD := -1
const MAP_WIDTH := 1240.0
const FORMATION_SPEED := 105.0
const RESERVE_STABLE_RETURN_SECONDS := 6.0

const SECTOR_POSITIONS := [Vector2(420.0, 360.0), Vector2(840.0, 360.0)]
const STAGING_POSITIONS := [Vector2(420.0, 720.0), Vector2(840.0, 720.0), Vector2(630.0, 790.0)]

var formations: Array[Dictionary] = []
var sector_pressure: Array[float] = [1.8, 0.8]
var sector_control: Array[float] = [0.0, 0.0]
var selected_formation := 0
var elapsed := 0.0
var decision_count := 0
var reserve_stable_time := 0.0
var last_event := "Observe both axes, then decide whether the reserve is needed."

var title_label: Label
var situation_label: Label
var selected_label: Label
var formation_status_label: Label
var decision_label: Label
var left_button: Button
var right_button: Button
var hold_button: Button

func _ready() -> void:
	formations = [
		{
			"name": "ALPHA",
			"role": "TASK FORCE",
			"task": SECTOR_LEFT,
			"position": STAGING_POSITIONS[0],
			"cohesion": 1.0,
			"reserve": false,
			"committed": true,
		},
		{
			"name": "BRAVO",
			"role": "TASK FORCE",
			"task": SECTOR_RIGHT,
			"position": STAGING_POSITIONS[1],
			"cohesion": 1.0,
			"reserve": false,
			"committed": true,
		},
		{
			"name": "RESERVE",
			"role": "RESERVE",
			"task": TASK_HOLD,
			"position": STAGING_POSITIONS[2],
			"cohesion": 1.0,
			"reserve": true,
			"committed": false,
		},
	]
	_build_ui()
	_update_ui()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	_update_pressure()
	_update_formations(delta)
	_update_sector_outcomes(delta)
	_update_reserve_recovery(delta)
	_update_ui()
	queue_redraw()

func _update_pressure() -> void:
	var cycle := int(elapsed / 14.0) % 3
	match cycle:
		0:
			sector_pressure[SECTOR_LEFT] = 1.8
			sector_pressure[SECTOR_RIGHT] = 0.8
		1:
			sector_pressure[SECTOR_LEFT] = 0.9
			sector_pressure[SECTOR_RIGHT] = 1.9
		_:
			sector_pressure[SECTOR_LEFT] = 1.25
			sector_pressure[SECTOR_RIGHT] = 1.25

func _update_formations(delta: float) -> void:
	for index in range(formations.size()):
		var formation := formations[index]
		var target := _target_for(index)
		var current: Vector2 = formation["position"]
		formation["position"] = current.move_toward(target, FORMATION_SPEED * delta)
		formations[index] = formation

func _update_sector_outcomes(delta: float) -> void:
	var friendly_power: Array[float] = [0.0, 0.0]
	var present_by_sector: Array[Array] = [[], []]
	for index in range(formations.size()):
		var formation := formations[index]
		var task: int = formation["task"]
		if task == TASK_HOLD:
			continue
		var position: Vector2 = formation["position"]
		if position.distance_to(SECTOR_POSITIONS[task]) > 70.0:
			continue
		var cohesion: float = formation["cohesion"]
		friendly_power[task] += cohesion
		present_by_sector[task].append(index)

	for sector in [SECTOR_LEFT, SECTOR_RIGHT]:
		var balance := friendly_power[sector] - sector_pressure[sector]
		if balance >= 0.0:
			sector_control[sector] = clampf(sector_control[sector] + delta * (4.0 + balance * 5.0), -100.0, 100.0)
		else:
			sector_control[sector] = clampf(sector_control[sector] + delta * balance * 7.0, -100.0, 100.0)

		var present: Array = present_by_sector[sector]
		if present.is_empty():
			continue
		var pressure_share := sector_pressure[sector] / float(present.size())
		for formation_index in present:
			var formation := formations[formation_index]
			var cohesion: float = formation["cohesion"]
			if pressure_share > 1.0:
				cohesion -= delta * 0.025 * (pressure_share - 0.9)
			else:
				cohesion += delta * 0.012
			formation["cohesion"] = clampf(cohesion, 0.35, 1.0)
			formations[formation_index] = formation

func _update_reserve_recovery(delta: float) -> void:
	var reserve := formations[2]
	if not reserve["committed"]:
		reserve_stable_time = 0.0
		return
	var task: int = reserve["task"]
	if task == TASK_HOLD:
		return
	var friendly_power := _friendly_power_in_sector(task)
	if sector_control[task] >= 30.0 and friendly_power >= sector_pressure[task] + 0.15:
		reserve_stable_time += delta
	else:
		reserve_stable_time = 0.0
	if reserve_stable_time >= RESERVE_STABLE_RETURN_SECONDS:
		reserve["task"] = TASK_HOLD
		reserve["committed"] = false
		reserve["cohesion"] = maxf(float(reserve["cohesion"]), 0.75)
		formations[2] = reserve
		reserve_stable_time = 0.0
		last_event = "RESERVE has automatically disengaged after stabilizing the axis and is available again."

func _friendly_power_in_sector(sector: int) -> float:
	var total := 0.0
	for formation in formations:
		if int(formation["task"]) != sector:
			continue
		var position: Vector2 = formation["position"]
		if position.distance_to(SECTOR_POSITIONS[sector]) <= 70.0:
			total += float(formation["cohesion"])
	return total

func _target_for(index: int) -> Vector2:
	var formation := formations[index]
	var task: int = formation["task"]
	if task == TASK_HOLD:
		return STAGING_POSITIONS[index]
	var offset := Vector2.ZERO
	if index == 0:
		offset = Vector2(-34.0, 32.0)
	elif index == 1:
		offset = Vector2(34.0, 32.0)
	elif index == 2:
		offset = Vector2(0.0, 74.0)
	return SECTOR_POSITIONS[task] + offset

func _assign_selected_task(task: int) -> void:
	var formation := formations[selected_formation]
	var is_reserve: bool = formation["reserve"]
	if is_reserve and bool(formation["committed"]):
		last_event = "RESERVE is already committed. It will return only after the axis is stabilized."
		return
	if is_reserve and task == TASK_HOLD:
		last_event = "RESERVE remains uncommitted and available."
		return

	var previous_task: int = formation["task"]
	if previous_task == task:
		return
	formation["task"] = task
	if is_reserve and task != TASK_HOLD:
		formation["committed"] = true
		reserve_stable_time = 0.0
	formations[selected_formation] = formation
	decision_count += 1
	last_event = "%s tasked to %s. Movement and local combat are now autonomous." % [formation["name"], _task_name(task)]

func _select_formation(index: int) -> void:
	selected_formation = index
	_update_ui()

func _task_name(task: int) -> String:
	match task:
		SECTOR_LEFT:
			return "LEFT AXIS"
		SECTOR_RIGHT:
			return "RIGHT AXIS"
		_:
			return "HOLD / RESERVE"

func _pressure_word(value: float) -> String:
	if value >= 1.7:
		return "HIGH"
	if value >= 1.2:
		return "MEDIUM"
	return "LOW"

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var top_panel := ColorRect.new()
	top_panel.color = Color(0.04, 0.055, 0.07, 0.94)
	top_panel.position = Vector2(18.0, 18.0)
	top_panel.size = Vector2(1188.0, 120.0)
	layer.add_child(top_panel)

	var top_box := VBoxContainer.new()
	top_box.position = Vector2(16.0, 10.0)
	top_box.size = Vector2(1150.0, 100.0)
	top_panel.add_child(top_box)

	title_label = Label.new()
	title_label.text = "PROTOTYPE B — TASK COMMAND / FORMATION AUTONOMY / RESERVE"
	title_label.add_theme_font_size_override("font_size", 20)
	top_box.add_child(title_label)

	var rule_label := Label.new()
	rule_label.text = "Your decision: assign formations to an axis and decide when to commit the reserve. You never steer individual units."
	rule_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_box.add_child(rule_label)

	situation_label = Label.new()
	situation_label.add_theme_font_size_override("font_size", 17)
	top_box.add_child(situation_label)

	var side_panel := ColorRect.new()
	side_panel.color = Color(0.055, 0.065, 0.08, 0.97)
	side_panel.position = Vector2(MAP_WIDTH, 0.0)
	side_panel.size = Vector2(360.0, 900.0)
	layer.add_child(side_panel)

	var side_box := VBoxContainer.new()
	side_box.position = Vector2(16.0, 24.0)
	side_box.size = Vector2(328.0, 850.0)
	side_box.add_theme_constant_override("separation", 10)
	side_panel.add_child(side_box)

	var choose_label := Label.new()
	choose_label.text = "1. SELECT FORMATION"
	choose_label.add_theme_font_size_override("font_size", 18)
	side_box.add_child(choose_label)

	for index in range(formations.size()):
		var button := Button.new()
		button.text = "%d  %s" % [index + 1, formations[index]["name"]]
		button.custom_minimum_size = Vector2(0.0, 42.0)
		button.pressed.connect(_select_formation.bind(index))
		side_box.add_child(button)

	selected_label = Label.new()
	selected_label.add_theme_font_size_override("font_size", 17)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(selected_label)

	var task_header := Label.new()
	task_header.text = "2. ASSIGN TASK"
	task_header.add_theme_font_size_override("font_size", 18)
	side_box.add_child(task_header)

	left_button = Button.new()
	left_button.text = "TASK: LEFT AXIS"
	left_button.custom_minimum_size = Vector2(0.0, 46.0)
	left_button.pressed.connect(_assign_selected_task.bind(SECTOR_LEFT))
	side_box.add_child(left_button)

	right_button = Button.new()
	right_button.text = "TASK: RIGHT AXIS"
	right_button.custom_minimum_size = Vector2(0.0, 46.0)
	right_button.pressed.connect(_assign_selected_task.bind(SECTOR_RIGHT))
	side_box.add_child(right_button)

	hold_button = Button.new()
	hold_button.text = "HOLD / KEEP IN RESERVE"
	hold_button.custom_minimum_size = Vector2(0.0, 46.0)
	hold_button.pressed.connect(_assign_selected_task.bind(TASK_HOLD))
	side_box.add_child(hold_button)

	formation_status_label = Label.new()
	formation_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	formation_status_label.custom_minimum_size = Vector2(0.0, 160.0)
	side_box.add_child(formation_status_label)

	decision_label = Label.new()
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.custom_minimum_size = Vector2(0.0, 120.0)
	side_box.add_child(decision_label)

	var footer := Label.new()
	footer.text = "Greybox test: if this feels like moving three pieces instead of commanding formations, the prototype fails."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(footer)

func _update_ui() -> void:
	if situation_label == null:
		return
	var cycle_left := 14.0 - fmod(elapsed, 14.0)
	situation_label.text = "LEFT pressure: %s (%.1f)   |   RIGHT pressure: %s (%.1f)   |   threat shift in %.0fs" % [
		_pressure_word(sector_pressure[SECTOR_LEFT]), sector_pressure[SECTOR_LEFT],
		_pressure_word(sector_pressure[SECTOR_RIGHT]), sector_pressure[SECTOR_RIGHT],
		cycle_left,
	]

	var selected := formations[selected_formation]
	selected_label.text = "Selected: %s — current task: %s" % [selected["name"], _task_name(int(selected["task"]))]

	var reserve := formations[2]
	var reserve_state := "AVAILABLE"
	if reserve["committed"]:
		reserve_state = "COMMITTED to %s" % _task_name(int(reserve["task"]))
	formation_status_label.text = "ALPHA  %s  cohesion %.0f%%\nBRAVO  %s  cohesion %.0f%%\nRESERVE  %s  cohesion %.0f%%\n\nAxis control: LEFT %.0f / RIGHT %.0f" % [
		_task_name(int(formations[0]["task"])), float(formations[0]["cohesion"]) * 100.0,
		_task_name(int(formations[1]["task"])), float(formations[1]["cohesion"]) * 100.0,
		reserve_state, float(reserve["cohesion"]) * 100.0,
		sector_control[SECTOR_LEFT], sector_control[SECTOR_RIGHT],
	]
	decision_label.text = "DECISIONS: %d\n%s" % [decision_count, last_event]

	var selected_is_reserve: bool = selected["reserve"]
	hold_button.disabled = selected_is_reserve and bool(selected["committed"])
	left_button.text = "COMMIT RESERVE: LEFT" if selected_is_reserve else "TASK: LEFT AXIS"
	right_button.text = "COMMIT RESERVE: RIGHT" if selected_is_reserve else "TASK: RIGHT AXIS"

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, MAP_WIDTH, 900.0), Color(0.085, 0.105, 0.105), true)
	draw_rect(Rect2(80.0, 160.0, 1080.0, 650.0), Color(0.18, 0.21, 0.18), true)
	draw_line(Vector2(630.0, 170.0), Vector2(630.0, 790.0), Color(0.30, 0.33, 0.30), 3.0)

	for sector in [SECTOR_LEFT, SECTOR_RIGHT]:
		var pos: Vector2 = SECTOR_POSITIONS[sector]
		var pressure_radius := 44.0 + sector_pressure[sector] * 17.0
		draw_circle(pos, pressure_radius, Color(0.38, 0.10, 0.10, 0.42))
		draw_arc(pos, pressure_radius, 0.0, TAU, 48, Color(0.95, 0.30, 0.25), 4.0)
		var control_width := clampf((sector_control[sector] + 100.0) / 200.0, 0.0, 1.0) * 210.0
		draw_rect(Rect2(pos.x - 105.0, pos.y + 112.0, 210.0, 12.0), Color(0.16, 0.16, 0.16), true)
		draw_rect(Rect2(pos.x - 105.0, pos.y + 112.0, control_width, 12.0), Color(0.28, 0.66, 0.90), true)

	for index in range(formations.size()):
		var formation := formations[index]
		var pos: Vector2 = formation["position"]
		var color := Color(0.18, 0.74, 0.96)
		if index == 1:
			color = Color(0.30, 0.55, 0.98)
		elif index == 2:
			color = Color(0.96, 0.78, 0.22) if not formation["committed"] else Color(0.24, 0.82, 0.72)
		draw_circle(pos, 21.0, color)
		draw_arc(pos, 27.0, 0.0, TAU, 32, Color.WHITE if index == selected_formation else Color(0.10, 0.14, 0.16), 3.0)
		for dot in [Vector2(-8.0, -5.0), Vector2(8.0, -5.0), Vector2(0.0, 8.0)]:
			draw_circle(pos + dot, 3.5, Color(0.04, 0.07, 0.09))

func debug_select_formation(index: int) -> void:
	_select_formation(index)

func debug_assign_task(task: int) -> void:
	_assign_selected_task(task)

func debug_snapshot() -> Dictionary:
	return {
		"decision_count": decision_count,
		"reserve_committed": bool(formations[2]["committed"]),
		"reserve_task": int(formations[2]["task"]),
		"alpha_task": int(formations[0]["task"]),
		"bravo_task": int(formations[1]["task"]),
	}
