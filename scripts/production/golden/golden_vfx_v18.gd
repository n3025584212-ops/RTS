extends GoldenVFXV1

func build(world: GoldenWorldV1) -> void:
	_world = world
	_build_materials()

	for data: Array in [
		[Vector3(12.5,0,-2.8), 2.2, 13.0, 12],
		[Vector3(31.0,0,-10.0), 2.8, 17.0, 14],
		[Vector3(45.0,0,15.0), 2.1, 13.5, 11],
		[Vector3(22.0,0,5.0), 1.7, 10.0, 9],
		[Vector3(50.0,0,-22.0), 2.6, 17.0, 14],
		[Vector3(54.0,0,8.5), 1.9, 13.0, 11],
		[Vector3(39.0,0,-3.0), 1.5, 9.0, 8],
		[Vector3(61.0,0,18.0), 1.7, 10.5, 9]
	]:
		_add_smoke_column(data[0], data[1], data[2], data[3])

	for data: Array in [
		[Vector3(13.5,0,-2.8),1.15], [Vector3(31,0,-6.5),1.1],
		[Vector3(50,0,-22),1.3], [Vector3(52,0,8.5),1.15],
		[Vector3(40,0,-3),0.95]
	]:
		_add_fire(data[0], data[1])

	for data: Array in [
		[Vector3(13,0,2),2.5], [Vector3(37,0,7),3.1],
		[Vector3(48,0,-5),2.3], [Vector3(57,0,15),2.1]
	]:
		_add_explosion(data[0], data[1])

	_add_muzzle_flash(Vector3(-12,0,7), Vector3(1,0.08,-0.12), true)
	_add_muzzle_flash(Vector3(-21,0,9.5), Vector3(1,0.05,-0.04), true)
	_add_muzzle_flash(Vector3(-4,0,3), Vector3(1,0.06,-0.08), true)
	_add_muzzle_flash(Vector3(29,0,-8), Vector3(-1,0.08,0.1), false)
	_add_muzzle_flash(Vector3(43,0,11), Vector3(-1,0.05,0.0), false)

	_add_tracer_arc(Vector3(-11,2,7), Vector3(28,2.3,-7), 1.3, true)
	_add_tracer_arc(Vector3(-24,1.8,10), Vector3(38,2,5), 1.8, true)
	_add_tracer_arc(Vector3(-4,1.9,3), Vector3(48,2,-5), 1.2, true)
	_add_tracer_arc(Vector3(31,2.1,-8), Vector3(-8,2,4), 1.0, false)
	_add_tracer_arc(Vector3(43,2.2,11), Vector3(-18,1.7,18), 1.4, false)
	_add_shell_arc(Vector3(-50,1,33), Vector3(35,1,-2), 20.0, true)
	_add_shell_arc(Vector3(57,1,-30), Vector3(-2,1,4), 15.0, false)
	_add_shell_arc(Vector3(-40,1,26), Vector3(55,1,14), 18.0, true)

	for p: Vector3 in [
		Vector3(14,0,-5), Vector3(23,0,11), Vector3(41,0,-17),
		Vector3(4,0,8), Vector3(-2,0,1), Vector3(35,0,-3),
		Vector3(54,0,15), Vector3(61,0,-18)
	]:
		_add_impact_dust(p)

	print(
		"FRONTLINE_GOLDEN_VFX_READY smoke=%d fire=%d explosions=%d tracers=%d impacts=%d muzzle=%d" %
		[smoke_column_count, fire_count, explosion_count, tracer_segment_count, impact_count, muzzle_flash_count]
	)


func _build_materials() -> void:
	super._build_materials()
	_smoke_materials.clear()
	for i: int in range(6):
		_smoke_materials.append(
			_soft_billboard_material(
				Color(0.20 + i * 0.018, 0.205 + i * 0.018, 0.20 + i * 0.016, 0.40 - i * 0.022),
				0.0,
				i + 41
			)
		)
	_tracer_blue = _emission_material(Color(0.34, 0.68, 0.92), 5.2)
	_tracer_red = _emission_material(Color(1.0, 0.24, 0.06), 6.0)
	_dust_material = _soft_billboard_material(Color(0.36, 0.29, 0.20, 0.50), 0.0, 63)
