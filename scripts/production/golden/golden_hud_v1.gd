class_name GoldenHUDV1
extends CanvasLayer

var panel_count: int = 0
var formation_card_count: int = 0
var minimap_marker_count: int = 0

var _blue := Color(0.20, 0.60, 1.0)
var _red := Color(1.0, 0.24, 0.16)
var _amber := Color(1.0, 0.68, 0.18)
var _text := Color(0.91, 0.95, 0.97)
var _muted := Color(0.58, 0.68, 0.72)


func build() -> void:
	layer = 20
	_build_objectives()
	_build_top_status()
	_build_alerts()
	_build_minimap()
	_build_formation_strip()
	_build_selected_formation()
	_build_world_legend()
	print(
		"FRONTLINE_GOLDEN_HUD_READY panels=%d cards=%d minimap_markers=%d" %
		[panel_count, formation_card_count, minimap_marker_count]
	)


func _build_objectives() -> void:
	var panel := _panel(Vector2(22, 24), Vector2(350, 170), "ObjectivesPanel")
	_label(panel, "MISSION • RIVER CROSSING", Vector2(18, 14), 19, _text)
	_label(panel, "□ Secure the central bridge", Vector2(18, 50), 15, _text)
	_label(panel, "□ Clear the river town", Vector2(18, 76), 15, _text)
	_label(panel, "□ Defeat armored counterattack", Vector2(18, 102), 15, _text)
	_label(panel, "■ Preserve combat power ≥ 70%", Vector2(18, 128), 14, _muted)


func _build_top_status() -> void:
	var panel := _panel(Vector2(570, 20), Vector2(780, 76), "BattleStatePanel")
	_label(panel, "BLUE  418", Vector2(30, 17), 22, _blue)
	_label(panel, "A   B   C   D   E", Vector2(252, 14), 20, _text)
	_label(panel, "27:14", Vector2(358, 38), 20, _text)
	_label(panel, "326  RED", Vector2(628, 17), 22, _red)
	var blue_bar := ColorRect.new()
	blue_bar.position = Vector2(205, 54)
	blue_bar.size = Vector2(180, 5)
	blue_bar.color = Color(_blue.r, _blue.g, _blue.b, 0.85)
	panel.add_child(blue_bar)
	var red_bar := ColorRect.new()
	red_bar.position = Vector2(395, 54)
	red_bar.size = Vector2(180, 5)
	red_bar.color = Color(_red.r, _red.g, _red.b, 0.85)
	panel.add_child(red_bar)


func _build_alerts() -> void:
	var panel := _panel(Vector2(1508, 22), Vector2(388, 214), "AlertPanel")
	_label(panel, "TACTICAL ALERTS", Vector2(18, 13), 17, _text)
	_alert_row(panel, Vector2(18, 48), "ENEMY ARMOR CONFIRMED", _red)
	_alert_row(panel, Vector2(18, 82), "C SECTOR UNDER SHELLING", _amber)
	_alert_row(panel, Vector2(18, 116), "2 FORMATIONS LOW AMMO", _amber)
	_alert_row(panel, Vector2(18, 150), "FIRE SUPPORT READY ×2", _blue)
	_label(panel, "06:42  CLEAR  12°C", Vector2(190, 183), 12, _muted)


func _alert_row(parent: Control, pos: Vector2, value: String, color: Color) -> void:
	var chip := ColorRect.new()
	chip.position = pos
	chip.size = Vector2(8, 23)
	chip.color = color
	parent.add_child(chip)
	_label(parent, value, pos + Vector2(18, 1), 13, _text)


func _build_minimap() -> void:
	var panel := _panel(Vector2(22, 790), Vector2(340, 266), "TacticalMapPanel")
	_label(panel, "TACTICAL MAP", Vector2(15, 11), 15, _text)

	var map := Panel.new()
	map.position = Vector2(14, 42)
	map.size = Vector2(312, 205)
	map.add_theme_stylebox_override("panel", _panel_style(Color(0.032, 0.052, 0.052, 0.96), Color(0.28, 0.39, 0.40, 0.9), 2))
	panel.add_child(map)

	var river := ColorRect.new()
	river.position = Vector2(165, 0)
	river.size = Vector2(28, 205)
	river.color = Color(0.07, 0.30, 0.38, 0.94)
	map.add_child(river)

	_add_map_line(map, Vector2(7, 105), Vector2(304, 95), 6.0, Color(0.30, 0.31, 0.28))
	_add_map_line(map, Vector2(35, 165), Vector2(156, 108), 3.0, Color(0.37, 0.29, 0.18))
	_add_map_line(map, Vector2(194, 35), Vector2(286, 153), 4.0, Color(0.28, 0.29, 0.26))

	for p: Vector2 in [Vector2(52, 128), Vector2(78, 116), Vector2(104, 142), Vector2(126, 109), Vector2(148, 122)]:
		_map_marker(map, p, _blue, 8)
	for p: Vector2 in [Vector2(223, 75), Vector2(253, 98), Vector2(270, 132), Vector2(235, 145)]:
		_map_marker(map, p, _red, 8)

	_label(map, "A", Vector2(168, 82), 14, _text)
	_label(map, "B", Vector2(93, 46), 14, _blue)
	_label(map, "C", Vector2(225, 80), 14, _red)
	_label(map, "N", Vector2(9, 7), 12, _muted)


func _build_formation_strip() -> void:
	var panel := _panel(Vector2(382, 874), Vector2(1012, 182), "FormationStrip")
	_label(panel, "FORMATIONS", Vector2(16, 10), 14, _muted)
	var names := ["1-1 ARMOR", "1-2 ARMOR", "2-1 IFV", "2-2 MECH", "R  RESERVE"]
	for i: int in range(names.size()):
		var card := Panel.new()
		card.position = Vector2(14 + float(i) * 192.0, 40)
		card.size = Vector2(180, 124)
		card.add_theme_stylebox_override(
			"panel",
			_panel_style(
				Color(0.045, 0.075, 0.090, 0.94),
				_blue if i != 4 else _amber,
				2 if i == 0 else 1
			)
		)
		panel.add_child(card)
		_label(card, names[i], Vector2(11, 10), 14, _text)
		_label(card, "TASK  " + (["ADVANCE", "HOLD", "SUPPORT", "ASSAULT", "READY"][i]), Vector2(11, 39), 11, _muted)
		_status_bar(card, Vector2(11, 67), 156, 0.90 - float(i) * 0.08, Color(0.31, 0.78, 0.35))
		_status_bar(card, Vector2(11, 86), 156, 0.72 - float(i) * 0.05, Color(0.28, 0.62, 0.95))
		_label(card, "HP", Vector2(12, 103), 9, _muted)
		_label(card, "AMMO", Vector2(113, 103), 9, _muted)
		formation_card_count += 1


func _build_selected_formation() -> void:
	var panel := _panel(Vector2(1414, 764), Vector2(482, 292), "SelectedFormationPanel")
	_label(panel, "SELECTED • 1-1 ARMOR COMPANY", Vector2(18, 14), 17, _text)
	_label(panel, "MBT PLATOON   4 / 4", Vector2(18, 48), 14, _blue)
	_label(panel, "COMBAT EFFECTIVENESS", Vector2(18, 82), 11, _muted)
	_status_bar(panel, Vector2(18, 101), 250, 0.92, Color(0.32, 0.80, 0.39))
	_label(panel, "AMMUNITION", Vector2(18, 128), 11, _muted)
	_status_bar(panel, Vector2(18, 147), 250, 0.68, Color(0.28, 0.64, 0.98))
	_label(panel, "CURRENT TASK", Vector2(18, 176), 11, _muted)
	_label(panel, "ASSAULT AREA • BRIDGE", Vector2(18, 196), 14, _text)

	var commands := ["MOVE", "ASSAULT", "HOLD", "FALL BACK", "FIRE SUPPORT", "SMOKE"]
	for i: int in range(commands.size()):
		var button := Panel.new()
		var col := i % 3
		var row := i / 3
		button.position = Vector2(290 + float(col) * 60, 52 + float(row) * 77)
		button.size = Vector2(54, 62)
		button.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.085, 0.10, 0.96), Color(0.25, 0.40, 0.48), 1))
		panel.add_child(button)
		var glyphs := ["→", "▲", "▣", "↙", "✦", "≈"]
		_label(button, glyphs[i], Vector2(17, 7), 22, _blue if i != 3 else _amber)
		_label(button, commands[i], Vector2(4, 36), 8, _text)


func _build_world_legend() -> void:
	var panel := _panel(Vector2(22, 228), Vector2(270, 86), "WorldLegend")
	_label(panel, "BLUE  FRIENDLY", Vector2(14, 12), 12, _blue)
	_label(panel, "RED   CONFIRMED HOSTILE", Vector2(14, 34), 12, _red)
	_label(panel, "AMBER CONTACT / WARNING", Vector2(14, 56), 12, _amber)


func _panel(position_value: Vector2, size_value: Vector2, node_name: String) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.position = position_value
	panel.size = size_value
	panel.add_theme_stylebox_override(
		"panel",
		_panel_style(Color(0.025, 0.046, 0.060, 0.91), Color(0.20, 0.38, 0.48, 0.84), 1)
	)
	add_child(panel)
	panel_count += 1
	return panel


func _panel_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(5)
	return style


func _label(parent: Control, value: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label


func _status_bar(parent: Control, pos: Vector2, width: float, ratio: float, color: Color) -> void:
	var bg := ColorRect.new()
	bg.position = pos
	bg.size = Vector2(width, 7)
	bg.color = Color(0.10, 0.13, 0.14, 0.94)
	parent.add_child(bg)
	var fg := ColorRect.new()
	fg.position = pos
	fg.size = Vector2(width * clampf(ratio, 0.0, 1.0), 7)
	fg.color = color
	parent.add_child(fg)


func _map_marker(parent: Control, pos: Vector2, color: Color, size_value: int) -> void:
	var marker := ColorRect.new()
	marker.position = pos - Vector2(size_value, size_value) * 0.5
	marker.size = Vector2(size_value, size_value)
	marker.color = color
	parent.add_child(marker)
	minimap_marker_count += 1


func _add_map_line(parent: Control, a: Vector2, b: Vector2, width: float, color: Color) -> void:
	var line := ColorRect.new()
	var delta := b - a
	line.position = (a + b) * 0.5 - Vector2(delta.length() * 0.5, width * 0.5)
	line.size = Vector2(delta.length(), width)
	line.rotation = atan2(delta.y, delta.x)
	line.pivot_offset = Vector2(line.size.x * 0.5, line.size.y * 0.5)
	line.color = color
	parent.add_child(line)
