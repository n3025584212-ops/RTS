class_name BattleCamera3D
extends Camera3D

@export var focus_sim: Vector2 = Vector2(1180.0, 900.0)
@export var pan_speed_sim: float = 820.0
@export var height_world: float = 12.5
@export var min_height_world: float = 7.2
@export var max_height_world: float = 24.0
@export var zoom_step_world: float = 1.6
@export var oblique_depth_ratio: float = 0.86

func _ready() -> void:
	current = true
	fov = 46.0
	near = 0.1
	far = 120.0
	_apply_camera_transform()
	print("FRONTLINE_CAMERA3D_READY focus=%s height=%.1f" % [focus_sim, height_world])

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
		focus_sim = Battle3DAdapter.clamp_sim(focus_sim + direction.normalized() * pan_speed_sim * delta)
		_apply_camera_transform()

func adjust_zoom(wheel_direction: int) -> void:
	if wheel_direction > 0:
		height_world = maxf(min_height_world, height_world - zoom_step_world)
	elif wheel_direction < 0:
		height_world = minf(max_height_world, height_world + zoom_step_world)
	_apply_camera_transform()

func focus_on_sim(sim_position: Vector2) -> void:
	focus_sim = Battle3DAdapter.clamp_sim(sim_position)
	_apply_camera_transform()

func _apply_camera_transform() -> void:
	var focus_world := Battle3DAdapter.sim_to_world(focus_sim, 0.0)
	global_position = focus_world + Vector3(0.0, height_world, height_world * oblique_depth_ratio)
	look_at(focus_world, Vector3.UP)
