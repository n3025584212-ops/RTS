class_name GoldenVFXV1
extends Node3D

var smoke_column_count: int = 0
var fire_count: int = 0
var explosion_count: int = 0
var tracer_segment_count: int = 0
var impact_count: int = 0
var muzzle_flash_count: int = 0

var _world: GoldenWorldV1
var _smoke_materials: Array[StandardMaterial3D] = []
var _fire_material: StandardMaterial3D
var _hot_material: StandardMaterial3D
var _tracer_blue: StandardMaterial3D
var _tracer_red: StandardMaterial3D
var _dust_material: StandardMaterial3D


func build(world: GoldenWorldV1) -> void:
	_world = world
	_build_materials()

	_add_smoke_column(Vector3(9.0, 0, -3.0), 1.5, 9.0, 9)
	_add_smoke_column(Vector3(31.0, 0, -10.0), 2.0, 14.0, 12)
	_add_smoke_column(Vector3(44.0, 0, 15.0), 1.7, 11.0, 10)
	_add_smoke_column(Vector3(21.0, 0, 5.0), 1.2, 8.0, 8)

	_add_fire(Vector3(9.0, 0, -3.0), 1.1)
	_add_fire(Vector3(21.0, 0, 5.0), 0.9)
	_add_fire(Vector3(32.0, 0, -11.0), 1.3)

	_add_explosion(Vector3(13.0, 0, 2.0), 1.9)
	_add_explosion(Vector3(37.0, 0, 7.0), 2.4)
	_add_explosion(Vector3(48.0, 0, -5.0), 1.6)

	_add_muzzle_flash(Vector3(-12.0, 0, 7.0), Vector3(1, 0.08, -0.12), true)
	_add_muzzle_flash(Vector3(-21.0, 0, 9.5), Vector3(1, 0.05, -0.04), true)
	_add_muzzle_flash(Vector3(29.0, 0, -8.0), Vector3(-1, 0.08, 0.1), false)

	_add_tracer_arc(Vector3(-11, 2.0, 7), Vector3(28, 2.3, -7), 1.3, true)
	_add_tracer_arc(Vector3(-24, 1.8, 10), Vector3(38, 2.0, 5), 1.8, true)
	_add_tracer_arc(Vector3(31, 2.1, -8), Vector3(-8, 2.0, 4), 1.0, false)
	_add_tracer_arc(Vector3(43, 2.2, 11), Vector3(-18, 1.7, 18), 1.4, false)

	# Higher artillery / mortar arcs distributed over the town.
	_add_shell_arc(Vector3(-50, 1.0, 33), Vector3(35, 1.0, -2), 20.0, true)
	_add_shell_arc(Vector3(57, 1.0, -30), Vector3(-2, 1.0, 4), 15.0, false)

	for p: Vector3 in [
		Vector3(14, 0, -5), Vector3(23, 0, 11), Vector3(41, 0, -17),
		Vector3(4, 0, 8), Vector3(-2, 0, 1)
	]:
		_add_impact_dust(p)

	print(
		"FRONTLINE_GOLDEN_VFX_READY smoke=%d fire=%d explosions=%d tracers=%d impacts=%d muzzle=%d" %
		[smoke_column_count, fire_count, explosion_count, tracer_segment_count, impact_count, muzzle_flash_count]
	)


func _build_materials() -> void:
	_smoke_materials.clear()
	for i: int in range(5):
		_smoke_materials.append(
			_soft_billboard_material(
				Color(0.12 + float(i) * 0.018, 0.125 + float(i) * 0.018, 0.12 + float(i) * 0.017, 0.64 - float(i) * 0.045),
				0.0,
				i + 3
			)
		)
	_fire_material = _soft_billboard_material(Color(1.0, 0.18, 0.015, 0.92), 5.5, 21)
	_hot_material = _soft_billboard_material(Color(1.0, 0.68, 0.12, 0.96), 7.5, 29)
	_tracer_blue = _emission_material(Color(0.48, 0.84, 1.0), 8.0)
	_tracer_red = _emission_material(Color(1.0, 0.30, 0.12), 8.0)
	_dust_material = _soft_billboard_material(Color(0.43, 0.35, 0.24, 0.55), 0.0, 37)


func _soft_billboard_material(color: Color, emission_energy: float, seed: int) -> StandardMaterial3D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y: int in range(64):
		for x: int in range(64):
			var nx := (float(x) + 0.5) / 32.0 - 1.0
			var ny := (float(y) + 0.5) / 32.0 - 1.0
			var radius := sqrt(nx * nx + ny * ny)
			var edge := clampf(1.0 - radius, 0.0, 1.0)
			var grain := 0.82 + 0.18 * sin(float(x * 17 + y * 31 + seed * 13) * 0.37)
			var alpha := pow(edge, 1.55) * grain
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var texture := ImageTexture.create_from_image(image)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.albedo_texture = texture
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.roughness = 1.0
	if emission_energy > 0.0:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = Color(color.r, color.g, color.b)
		material.emission_energy_multiplier = emission_energy
	return material


func _add_smoke_column(base: Vector3, radius: float, height: float, puffs: int) -> void:
	base.y = _world.height_at(base.x, base.z)
	for i: int in range(puffs):
		var t := float(i) / maxf(1.0, float(puffs - 1))
		var puff := MeshInstance3D.new()
		puff.name = "BattleSmoke"
		var quad := QuadMesh.new()
		var scale_value := radius * (0.78 + t * 1.08) * (0.88 + 0.12 * sin(float(i) * 1.9))
		quad.size = Vector2(scale_value * 2.35, scale_value * 1.75)
		puff.mesh = quad
		var sway := Vector3(
			sin(float(i) * 2.31) * radius * 0.50,
			t * height,
			cos(float(i) * 1.77) * radius * 0.42
		)
		puff.position = base + Vector3(0, 0.9, 0) + sway
		puff.material_override = _smoke_materials[i % _smoke_materials.size()]
		add_child(puff)
	smoke_column_count += 1


func _add_fire(base: Vector3, scale_value: float) -> void:
	base.y = _world.height_at(base.x, base.z)
	for i: int in range(6):
		var flame := MeshInstance3D.new()
		flame.name = "BattleFire"
		var quad := QuadMesh.new()
		var taper := 1.0 - float(i) * 0.085
		quad.size = Vector2(0.72 * scale_value * taper, (1.0 + float(i) * 0.10) * scale_value)
		flame.mesh = quad
		flame.position = base + Vector3(
			sin(float(i) * 2.2) * 0.32 * scale_value,
			0.42 + float(i) * 0.24 * scale_value,
			cos(float(i) * 2.0) * 0.25 * scale_value
		)
		flame.material_override = _hot_material if i < 2 else _fire_material
		add_child(flame)
	var light := OmniLight3D.new()
	light.position = base + Vector3(0, 1.0, 0)
	light.light_color = Color(1.0, 0.34, 0.08)
	light.light_energy = 1.7 * scale_value
	light.omni_range = 6.5 * scale_value
	light.shadow_enabled = false
	add_child(light)
	fire_count += 1


func _add_explosion(base: Vector3, scale_value: float) -> void:
	base.y = _world.height_at(base.x, base.z) + 0.9
	for i: int in range(8):
		var flash := MeshInstance3D.new()
		flash.name = "ExplosionFlash"
		var quad := QuadMesh.new()
		var size_value := scale_value * (1.15 if i == 0 else 0.64 + float(i % 3) * 0.12)
		quad.size = Vector2(size_value, size_value * 0.88)
		flash.mesh = quad
		var angle := float(i) * TAU / 8.0
		flash.position = base + Vector3(cos(angle) * 0.46, sin(float(i) * 1.7) * 0.31, sin(angle) * 0.46) * scale_value
		flash.material_override = _hot_material if i % 2 == 0 else _fire_material
		add_child(flash)
	var light := OmniLight3D.new()
	light.position = base
	light.light_color = Color(1.0, 0.48, 0.12)
	light.light_energy = 2.8 * scale_value
	light.omni_range = 9.0 * scale_value
	light.shadow_enabled = false
	add_child(light)
	explosion_count += 1


func _add_muzzle_flash(base: Vector3, direction: Vector3, friendly: bool) -> void:
	base.y = _world.height_at(base.x, base.z) + 1.35
	direction = direction.normalized()
	var end := base + direction * 2.1
	_add_segment(base, end, 0.12, _hot_material, "MuzzleFlash")
	var core := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.52, 0.52)
	core.mesh = quad
	core.position = end
	core.material_override = _hot_material
	add_child(core)
	muzzle_flash_count += 1


func _arc_point(start: Vector3, finish: Vector3, t: float, arc: float) -> Vector3:
	var p := start.lerp(finish, t)
	p.y += sin(t * PI) * arc
	return p


func _add_tracer_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	# Golden still frame: short luminous streaks imply projectile flight without
	# drawing a full wire between attacker and target.
	var mat := _tracer_blue if friendly else _tracer_red
	for center_t: float in [0.22, 0.48, 0.74]:
		var a := _arc_point(start, finish, maxf(0.0, center_t - 0.035), arc)
		var b := _arc_point(start, finish, minf(1.0, center_t + 0.035), arc)
		_add_segment(a, b, 0.026, mat, "Tracer")
		tracer_segment_count += 1


func _add_shell_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	start.y = _world.height_at(start.x, start.z) + 1.2
	finish.y = _world.height_at(finish.x, finish.z) + 1.0
	var mat := _tracer_blue if friendly else _tracer_red
	for center_t: float in [0.18, 0.38, 0.60, 0.80]:
		var a := _arc_point(start, finish, maxf(0.0, center_t - 0.020), arc)
		var b := _arc_point(start, finish, minf(1.0, center_t + 0.020), arc)
		_add_segment(a, b, 0.020, mat, "ShellTrajectory")
		tracer_segment_count += 1


func _add_impact_dust(base: Vector3) -> void:
	base.y = _world.height_at(base.x, base.z) + 0.25
	for i: int in range(6):
		var dust := MeshInstance3D.new()
		dust.name = "ImpactDust"
		var quad := QuadMesh.new()
		quad.size = Vector2(1.15 + float(i % 2) * 0.28, 0.82 + float(i) * 0.08)
		dust.mesh = quad
		var angle := float(i) * TAU / 6.0
		dust.position = base + Vector3(cos(angle) * 0.58, 0.25 + float(i) * 0.15, sin(angle) * 0.58)
		dust.material_override = _dust_material
		add_child(dust)
	impact_count += 1


func _add_segment(a: Vector3, b: Vector3, radius: float, material: Material, node_name: String) -> void:
	var direction := b - a
	if direction.length_squared() < 0.00001:
		return
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = direction.length()
	cylinder.radial_segments = 8
	var beam := MeshInstance3D.new()
	beam.name = node_name
	beam.mesh = cylinder
	beam.position = (a + b) * 0.5
	var q := Quaternion(Vector3.UP, direction.normalized())
	beam.basis = Basis(q)
	beam.material_override = material
	add_child(beam)


func _emission_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.20
	return material
