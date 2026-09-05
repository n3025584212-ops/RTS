extends GoldenWorldV1

func _build_materials() -> void:
	super._build_materials()
	GoldenWorldV17Materials.apply(self)


func _build_environment() -> void:
	super._build_environment()
	GoldenWorldV17Materials.apply_environment(self)


func _build_town() -> void:
	GoldenWorldV17Town.build(self)


func _build_forests_and_hedgerows() -> void:
	GoldenWorldV17Forest.build(self)


func _build_camera() -> void:
	super._build_camera()
	if camera != null:
		camera.fov = 39.0
		camera.position = Vector3(-58.0, 29.0, 52.0)
		camera.look_at(Vector3(8.0, 1.0, -2.0), Vector3.UP)
