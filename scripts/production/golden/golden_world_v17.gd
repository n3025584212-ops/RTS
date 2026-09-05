extends GoldenWorldV1

func _build_materials() -> void:
	super._build_materials()
	GoldenWorldV17Materials.apply(self)
	GoldenWorldV20Terrain.apply(self)


func _build_environment() -> void:
	super._build_environment()
	GoldenWorldV17Materials.apply_environment(self)
	GoldenWorldV20Terrain.apply_environment(self)


func _build_town() -> void:
	GoldenWorldV20TownCore.build(self)
	GoldenWorldV20TownStreets.add(self)


func _build_fields() -> void:
	super._build_fields()
	GoldenWorldV18Ground.add(self)


func _build_forests_and_hedgerows() -> void:
	GoldenWorldV17Forest.build(self)


func _build_camera() -> void:
	super._build_camera()
	if camera != null:
		camera.fov = 41.0
		camera.position = Vector3(-61.0, 54.0, 58.0)
		camera.look_at(Vector3(10.0, 0.5, -3.0), Vector3.UP)
