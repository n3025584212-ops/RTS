extends Node2D

const MAP_SIZE := Vector2(3200.0, 1800.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Muted military-map ground keeps tactical overlays legible.
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(0.055, 0.075, 0.068), true)
	for x: int in range(0, int(MAP_SIZE.x) + 1, 160):
		draw_line(Vector2(x, 0.0), Vector2(x, MAP_SIZE.y), Color(0.16, 0.22, 0.20, 0.12), 1.0)
	for y: int in range(0, int(MAP_SIZE.y) + 1, 160):
		draw_line(Vector2(0.0, y), Vector2(MAP_SIZE.x, y), Color(0.16, 0.22, 0.20, 0.12), 1.0)

	# Friendly west rear and connected maneuver terrain.
	draw_rect(Rect2(Vector2(120.0, 560.0), Vector2(620.0, 680.0)), Color(0.045, 0.13, 0.18), true)
	draw_rect(Rect2(Vector2(850.0, 1280.0), Vector2(1480.0, 220.0)), Color(0.09, 0.13, 0.085), true)
	for index: int in range(10):
		var tree_position := Vector2(900.0 + index * 145.0, 1330.0 + (index % 2) * 90.0)
		draw_circle(tree_position, 28.0, Color(0.10, 0.20, 0.13, 0.82))
		draw_circle(tree_position + Vector2(18.0, -12.0), 19.0, Color(0.12, 0.24, 0.15, 0.72))

	# River and the only bridge crossing.
	draw_rect(Rect2(Vector2(1480.0, 0.0), Vector2(240.0, MAP_SIZE.y)), Color(0.025, 0.12, 0.19), true)
	for y: int in range(20, int(MAP_SIZE.y), 85):
		draw_line(Vector2(1498.0, y), Vector2(1702.0, y + 22.0), Color(0.16, 0.36, 0.46, 0.28), 2.0)
	draw_rect(Rect2(Vector2(1458.0, 790.0), Vector2(284.0, 220.0)), Color(0.25, 0.25, 0.22), true)
	for y: int in range(804, 1000, 28):
		draw_line(Vector2(1468.0, y), Vector2(1732.0, y), Color(0.43, 0.42, 0.36, 0.58), 3.0)

	# North village compounds.
	draw_rect(Rect2(Vector2(1120.0, 250.0), Vector2(760.0, 360.0)), Color(0.13, 0.13, 0.105), true)
	for row: int in range(2):
		for column: int in range(5):
			var building := Rect2(1160.0 + column * 142.0, 290.0 + row * 150.0, 92.0, 78.0)
			draw_rect(building, Color(0.25, 0.24, 0.19), true)
			draw_rect(building, Color(0.43, 0.40, 0.31, 0.48), false, 3.0)

	# Industrial decisive area with readable factory geometry.
	draw_rect(Rect2(Vector2(2440.0, 520.0), Vector2(560.0, 760.0)), Color(0.12, 0.105, 0.095), true)
	for index: int in range(4):
		var warehouse := Rect2(2490.0 + (index % 2) * 250.0, 590.0 + (index / 2) * 330.0, 185.0, 170.0)
		draw_rect(warehouse, Color(0.23, 0.20, 0.18), true)
		draw_rect(warehouse, Color(0.43, 0.35, 0.29, 0.52), false, 4.0)
	for stack_x: float in [2530.0, 2860.0]:
		draw_rect(Rect2(stack_x, 470.0, 34.0, 145.0), Color(0.20, 0.19, 0.18), true)
		draw_circle(Vector2(stack_x + 17.0, 470.0), 17.0, Color(0.34, 0.30, 0.26))

	# Main axis and secondary route relationships.
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.29, 0.29, 0.26), 40.0)
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.53, 0.51, 0.43, 0.62), 3.0)
	for x: int in range(460, 2840, 90):
		draw_line(Vector2(x, 900.0), Vector2(x + 42.0, 900.0), Color(0.72, 0.69, 0.54, 0.34), 2.0)
	draw_polyline(PackedVector2Array([Vector2(500.0, 860.0), Vector2(960.0, 540.0), Vector2(1240.0, 560.0), Vector2(1460.0, 840.0)]), Color(0.31, 0.34, 0.28, 0.72), 18.0)
	draw_polyline(PackedVector2Array([Vector2(520.0, 1040.0), Vector2(980.0, 1390.0), Vector2(2100.0, 1390.0), Vector2(2660.0, 1060.0)]), Color(0.27, 0.30, 0.23, 0.82), 18.0)

	_draw_landmark_label(Vector2(230.0, 520.0), "WEST REAR  /  BLUE ASSEMBLY", Color(0.38, 0.65, 0.92))
	_draw_landmark_label(Vector2(1120.0, 225.0), "NORTH VILLAGE  /  COVERED MANEUVER", Color(0.56, 0.63, 0.56))
	_draw_landmark_label(Vector2(900.0, 1270.0), "SOUTH FLANK  /  LONG APPROACH", Color(0.56, 0.63, 0.56))
	_draw_landmark_label(Vector2(2440.0, 505.0), "EAST INDUSTRIAL ZONE", Color(0.72, 0.53, 0.42))

func _draw_landmark_label(position: Vector2, value: String, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(color, 0.72))
