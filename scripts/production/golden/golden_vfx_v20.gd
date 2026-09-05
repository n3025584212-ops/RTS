extends GoldenVFXV1

func build(world: GoldenWorldV1) -> void:
	_world = world
	_build_materials()

	for data: Array in [
		[Vector3(13,0,-3), 2.1, 12.0, 10],
		[Vector3(35,0,-8), 2.5, 15.0, 12],
		[Vector3(50,0,-20), 2.2, 13.0, 10],
		[Vector3(55,0,9), 1.8, 10.0, 8]
	]:
		_add_smoke_column(data[0], data[1], data[2], data[3])

	_add_fire(Vector3(13.5,0,-2.8), 1.0)
	_add_fire(Vector3(50,0,-20), 1.1)
	_add_explosion(Vector3(35,0,5), 2.5)
	_add_explosion(Vector3(52,0,-4), 2.0)
	_add_muzzle_flash(Vector3(-12,0,7), Vector3(1,0.05,-0.10), true)
	_add_muzzle_flash(Vector3(40,0,-8), Vector3(-1,0.05,0.08), false)

	_add_tracer_arc(Vector3(-12,2,7), Vector3(31,2,-7), 1.0, true)
	_add_tracer_arc(Vector3(40,2,-8), Vector3(-7,2,4), 0.8, false)

	for p: Vector3 in [
		Vector3(14,0,-5), Vector3(33,0,7), Vector3(49,0,-7), Vector3(5,0,5)
	]:
		_add_impact_dust(p)

	print(
		"FRONTLINE_GOLDEN_VFX_READY smoke=%d fire=%d explosions=%d tracers=%d impacts=%d muzzle=%d" %
		[smoke_column_count, fire_count, explosion_count, tracer_segment_count, impact_count, muzzle_flash_count]
	)


func _build_materials() -> void:
	super._build_materials()
	_smoke_materials.clear()
	for i: int in range(5):
		_smoke_materials.append(
			_soft_billboard_material(
				Color(0.17 + i * 0.018, 0.175 + i * 0.018, 0.17 + i * 0.016, 0.36 - i * 0.020),
				0.0, i + 81
			)
		)
	_tracer_blue = _emission_material(Color(0.25,0.52,0.78), 2.3)
	_tracer_red = _emission_material(Color(0.90,0.18,0.04), 2.5)


func _add_tracer_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	var mat := _tracer_blue if friendly else _tracer_red
	var a := _arc_point(start, finish, 0.47, arc)
	var b := _arc_point(start, finish, 0.53, arc)
	_add_segment(a, b, 0.022, mat, "Tracer")
	tracer_segment_count += 1
