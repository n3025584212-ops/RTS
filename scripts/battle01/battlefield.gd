extends Node2D

const MAP_SIZE := Vector2(3200.0, 1800.0)

static var _landmark_style: StyleBoxFlat

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# --- Base ground: layered military-map material ---
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(0.050, 0.070, 0.064), true)
	for x: int in range(3):
		for y: int in range(3):
			var patch_pos := Vector2(140.0 + x * 1050.0 + (y % 2) * 260.0, 140.0 + y * 620.0)
			draw_circle(patch_pos, 250.0, Color(0.075, 0.098, 0.084, 0.42))
	for x: int in range(0, int(MAP_SIZE.x) + 1, 160):
		draw_line(Vector2(x, 0.0), Vector2(x, MAP_SIZE.y), Color(0.16, 0.22, 0.20, 0.12), 1.0)
	for y: int in range(0, int(MAP_SIZE.y) + 1, 160):
		draw_line(Vector2(0.0, y), Vector2(MAP_SIZE.x, y), Color(0.16, 0.22, 0.20, 0.12), 1.0)
	for x: int in range(160, int(MAP_SIZE.x), 320):
		for y: int in range(160, int(MAP_SIZE.y), 320):
			draw_line(Vector2(x - 4.0, y), Vector2(x + 4.0, y), Color(0.30, 0.38, 0.34, 0.16), 1.0)
			draw_line(Vector2(x, y - 4.0), Vector2(x, y + 4.0), Color(0.30, 0.38, 0.34, 0.16), 1.0)

	# --- West rear assembly ---
	draw_rect(Rect2(Vector2(120.0, 560.0), Vector2(620.0, 680.0)), Color(0.040, 0.115, 0.160), true)
	draw_rect(Rect2(Vector2(120.0, 560.0), Vector2(620.0, 680.0)), Color(0.30, 0.55, 0.90, 0.16), false, 3.0)
	for index: int in range(5):
		var tent := Vector2(190.0 + index * 108.0, 660.0 + (index % 2) * 96.0)
		draw_colored_polygon(PackedVector2Array([tent + Vector2(-22.0, 14.0), tent, tent + Vector2(22.0, 14.0)]), Color(0.16, 0.28, 0.36, 0.85))
		draw_line(tent + Vector2(0.0, -14.0), tent + Vector2(0.0, 14.0), Color(0.55, 0.70, 0.82, 0.9), 2.0)
	_draw_flag(Vector2(310.0, 900.0), Color("4d8cff"))
	draw_circle(Vector2(320.0, 900.0), 26.0, Color(0.30, 0.55, 1.0, 0.14))
	draw_arc(Vector2(320.0, 900.0), 26.0, 0.0, TAU, 20, Color(0.40, 0.65, 1.0, 0.8), 2.0)

	# --- Forest canopy clusters ---
	_draw_forest(Vector2(850.0, 1280.0), 9, 148.0)
	_draw_forest(Vector2(590.0, 300.0), 4, 132.0)
	_draw_forest(Vector2(1900.0, 1500.0), 5, 142.0)
	_draw_forest(Vector2(2140.0, 330.0), 3, 128.0)

	# --- River, banks and the only bridge crossing ---
	draw_rect(Rect2(Vector2(1480.0, 0.0), Vector2(240.0, MAP_SIZE.y)), Color(0.020, 0.095, 0.155), true)
	draw_rect(Rect2(Vector2(1474.0, 0.0), Vector2(14.0, MAP_SIZE.y)), Color(0.12, 0.22, 0.24, 0.55), true)
	draw_rect(Rect2(Vector2(1712.0, 0.0), Vector2(14.0, MAP_SIZE.y)), Color(0.12, 0.22, 0.24, 0.55), true)
	for y: int in range(16, int(MAP_SIZE.y), 85):
		draw_line(Vector2(1502.0, y), Vector2(1698.0, y + 22.0), Color(0.18, 0.40, 0.50, 0.30), 2.0)
		draw_line(Vector2(1502.0, y + 40.0), Vector2(1698.0, y + 62.0), Color(0.14, 0.34, 0.44, 0.22), 2.0)
	# Bridge: deck + truss geometry.
	var deck := Rect2(Vector2(1458.0, 790.0), Vector2(284.0, 220.0))
	draw_rect(deck, Color(0.28, 0.28, 0.25), true)
	draw_rect(Rect2(deck.position + Vector2(0.0, 12.0), Vector2(deck.size.x, 8.0)), Color(0.40, 0.40, 0.35, 0.8), true)
	draw_rect(Rect2(deck.position + Vector2(0.0, deck.size.y - 20.0), Vector2(deck.size.x, 8.0)), Color(0.40, 0.40, 0.35, 0.8), true)
	for x: float in range(1472.0, 1730.0, 26.0):
		draw_line(Vector2(x, 802.0), Vector2(x, 998.0), Color(0.52, 0.51, 0.45, 0.62), 3.0)
		draw_line(Vector2(x, 800.0), Vector2(x, 800.0), Color(0.52, 0.51, 0.45, 0.62), 3.0)
	for x: float in range(1472.0, 1730.0, 52.0):
		draw_line(Vector2(x, 806.0), Vector2(x + 26.0, 994.0), Color(0.60, 0.58, 0.50, 0.34), 2.0)
	draw_line(Vector2(1458.0, 900.0), Vector2(1742.0, 900.0), Color(0.66, 0.64, 0.54, 0.75), 3.0)
	draw_arc(Vector2(1600.0, 900.0), 40.0, 0.0, TAU, 32, Color(0.72, 0.70, 0.58, 0.9), 2.0)
	draw_arc(Vector2(1600.0, 900.0), 40.0, 0.0, TAU, 32, Color(0.72, 0.70, 0.58, 0.5), 1.0)

	# --- North village compounds ---
	draw_rect(Rect2(Vector2(1120.0, 250.0), Vector2(760.0, 360.0)), Color(0.115, 0.115, 0.095), true)
	for row: int in range(2):
		for column: int in range(5):
			var building_pos := Vector2(1160.0 + column * 142.0, 290.0 + row * 150.0)
			_draw_pitched_house(building_pos, Color(0.30, 0.28, 0.22), Color(0.42, 0.38, 0.30))

	# --- East industrial decisive zone ---
	draw_rect(Rect2(Vector2(2440.0, 520.0), Vector2(560.0, 760.0)), Color(0.115, 0.100, 0.092), true)
	for index: int in range(4):
		var warehouse_pos := Vector2(2490.0 + (index % 2) * 250.0, 590.0 + (index / 2) * 330.0)
		_draw_sawtooth_roof(warehouse_pos, Vector2(185.0, 170.0))
	_draw_stack(Vector2(2530.0, 470.0))
	_draw_stack(Vector2(2860.0, 470.0))
	# Chimney + smoke.
	draw_rect(Rect2(Vector2(2770.0, 440.0), Vector2(16.0, 90.0)), Color(0.30, 0.26, 0.22), true)
	draw_circle(Vector2(2778.0, 424.0), 10.0, Color(0.16, 0.15, 0.14, 0.55))
	draw_circle(Vector2(2788.0, 408.0), 8.0, Color(0.14, 0.14, 0.13, 0.38))
	draw_circle(Vector2(2796.0, 394.0), 6.0, Color(0.12, 0.12, 0.12, 0.26))
	# Storage tanks.
	for tank_index: int in range(2):
		var tank_pos := Vector2(2600.0 + tank_index * 70.0, 1010.0)
		draw_circle(tank_pos, 26.0, Color(0.22, 0.20, 0.18, 0.95))
		draw_arc(tank_pos, 26.0, 0.0, TAU, 24, Color(0.44, 0.38, 0.32, 0.85), 3.0)

	# --- Road network: main axis with casing + dash, secondary dirt routes ---
	_draw_main_road()
	_draw_secondary_route(PackedVector2Array([Vector2(500.0, 860.0), Vector2(960.0, 540.0), Vector2(1240.0, 560.0), Vector2(1460.0, 840.0)]), Color(0.33, 0.36, 0.30, 0.85))
	_draw_secondary_route(PackedVector2Array([Vector2(520.0, 1040.0), Vector2(980.0, 1390.0), Vector2(2100.0, 1390.0), Vector2(2660.0, 1060.0)]), Color(0.30, 0.33, 0.27, 0.85))

	# --- Landmark chips ---
	_draw_landmark_chip(Vector2(230.0, 520.0), "WEST REAR  /  BLUE ASSEMBLY", Color(0.38, 0.65, 0.92))
	_draw_landmark_chip(Vector2(1120.0, 225.0), "NORTH VILLAGE  /  COVERED MANEUVER", Color(0.56, 0.63, 0.56))
	_draw_landmark_chip(Vector2(900.0, 1270.0), "SOUTH FLANK  /  LONG APPROACH", Color(0.56, 0.63, 0.56))
	_draw_landmark_chip(Vector2(2440.0, 505.0), "EAST INDUSTRIAL ZONE", Color(0.72, 0.53, 0.42))
	_draw_landmark_chip(Vector2(1600.0, 762.0), "CENTRAL BRIDGE", Color(0.80, 0.76, 0.60))

func _draw_flag(position: Vector2, color: Color) -> void:
	draw_line(position + Vector2(0.0, -22.0), position + Vector2(0.0, 14.0), Color(0.7, 0.8, 0.9, 0.9), 2.5)
	draw_colored_polygon(PackedVector2Array([position + Vector2(0.0, -22.0), position + Vector2(16.0, -17.0), position + Vector2(0.0, -12.0)]), color)

func _draw_forest(center: Vector2, count: int, spacing: float) -> void:
	for index: int in range(count):
		var tree_position := center + Vector2((index % 5) * spacing * 0.62, (index / 5) * spacing * 0.55 + (index % 2) * 26.0)
		draw_circle(tree_position + Vector2(6.0, 10.0), 15.0, Color(0.02, 0.04, 0.03, 0.35))
		draw_circle(tree_position, 21.0, Color(0.09, 0.20, 0.13, 0.88))
		draw_circle(tree_position + Vector2(11.0, -7.0), 14.0, Color(0.11, 0.24, 0.15, 0.80))
		draw_circle(tree_position + Vector2(-9.0, -4.0), 12.0, Color(0.08, 0.18, 0.12, 0.72))

func _draw_pitched_house(position: Vector2, wall: Color, roof: Color) -> void:
	draw_rect(Rect2(position, Vector2(92.0, 78.0)), wall, true)
	draw_rect(Rect2(position, Vector2(92.0, 78.0)), Color(0.55, 0.50, 0.40, 0.55), false, 2.0)
	draw_colored_polygon(PackedVector2Array([position + Vector2(-8.0, 6.0), position + Vector2(46.0, -14.0), position + Vector2(100.0, 6.0)]), roof)
	draw_rect(Rect2(position + Vector2(30.0, 34.0), Vector2(22.0, 30.0)), Color(0.16, 0.14, 0.12, 0.9), true)
	draw_rect(Rect2(position + Vector2(62.0, 30.0), Vector2(12.0, 12.0)), Color(0.55, 0.50, 0.40, 0.75), true)
	draw_rect(Rect2(position + Vector2(12.0, 30.0), Vector2(12.0, 12.0)), Color(0.55, 0.50, 0.40, 0.75), true)

func _draw_sawtooth_roof(position: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(position, size), Color(0.24, 0.21, 0.19), true)
	draw_rect(Rect2(position, size), Color(0.45, 0.37, 0.30, 0.6), false, 3.0)
	var tooth_count: int = 5
	var tooth_width: float = size.x / float(tooth_count)
	for index: int in range(tooth_count):
		var x0: float = position.x + index * tooth_width
		draw_colored_polygon(PackedVector2Array([
			Vector2(x0, position.y),
			Vector2(x0 + tooth_width * 0.5, position.y - 12.0),
			Vector2(x0 + tooth_width, position.y),
		]), Color(0.34, 0.30, 0.26))
	draw_rect(Rect2(position + Vector2(size.x * 0.34, size.y * 0.42), Vector2(size.x * 0.30, size.y * 0.5)), Color(0.14, 0.12, 0.11, 0.9), true)

func _draw_stack(position: Vector2) -> void:
	draw_rect(Rect2(position, Vector2(34.0, 145.0)), Color(0.21, 0.20, 0.19), true)
	draw_rect(Rect2(position, Vector2(34.0, 145.0)), Color(0.40, 0.35, 0.30, 0.5), false, 2.0)
	draw_circle(position + Vector2(17.0, 0.0), 17.0, Color(0.36, 0.31, 0.27))
	draw_arc(position + Vector2(17.0, 0.0), 17.0, PI, TAU, 16, Color(0.50, 0.42, 0.34, 0.7), 2.0)

func _draw_main_road() -> void:
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.20, 0.20, 0.18), 44.0)
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.42, 0.41, 0.36), 40.0)
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.62, 0.60, 0.50, 0.75), 2.5)
	for x: int in range(460, 2840, 90):
		draw_line(Vector2(x, 900.0), Vector2(x + 42.0, 900.0), Color(0.78, 0.75, 0.60, 0.5), 2.0)

func _draw_secondary_route(points: PackedVector2Array, color: Color) -> void:
	draw_polyline(points, Color(color, 0.35), 24.0)
	draw_polyline(points, color, 14.0)
	draw_polyline(points, Color(0.82, 0.78, 0.62, 0.18), 1.5)

func _draw_landmark_chip(position: Vector2, value: String, color: Color) -> void:
	if _landmark_style == null:
		_landmark_style = StyleBoxFlat.new()
		_landmark_style.bg_color = Color(0.028, 0.052, 0.068, 0.88)
		_landmark_style.border_color = Color(0.30, 0.46, 0.54, 0.75)
		_landmark_style.set_border_width_all(1)
		_landmark_style.set_corner_radius_all(4)
	var font := ThemeDB.fallback_font
	var font_size := 12
	var text_width: float = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var rect := Rect2(position - Vector2(text_width * 0.5 + 7.0, -18.0), Vector2(text_width + 14.0, 18.0))
	rect.position.y -= 18.0
	draw_style_box(_landmark_style, rect)
	draw_line(Vector2(position.x, position.y - 2.0), Vector2(position.x, rect.position.y + rect.size.y), Color(color, 0.8), 1.5)
	draw_string(font, rect.position + Vector2(7.0, 13.0), value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(color, 0.92))