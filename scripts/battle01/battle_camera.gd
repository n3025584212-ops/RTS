extends Camera2D

@export var pan_speed: float = 760.0
@export var zoom_step: float = 0.12
@export var min_zoom: float = 0.55
@export var max_zoom: float = 1.55

func _ready() -> void:
	limit_left = 0
	limit_top = 0
	limit_right = 3200
	limit_bottom = 1800
	position = Vector2(850.0, 900.0)

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if direction != Vector2.ZERO:
		position += direction.normalized() * pan_speed * delta / maxf(zoom.x, 0.01)
		position.x = clampf(position.x, float(limit_left), float(limit_right))
		position.y = clampf(position.y, float(limit_top), float(limit_bottom))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_uniform_zoom(zoom.x + zoom_step)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_uniform_zoom(zoom.x - zoom_step)
			get_viewport().set_input_as_handled()

func _set_uniform_zoom(value: float) -> void:
	var z := clampf(value, min_zoom, max_zoom)
	zoom = Vector2(z, z)
