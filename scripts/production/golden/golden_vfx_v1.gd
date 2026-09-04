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
	for i: int in range(5):
		var m := StandardMaterial3D.new()
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color = Color(0.20 + float(i) * 0.025, 0.21 + float(i) * 0.022, 0.205 + float(i) * 0.02, 0.62 - float(i) * 0.055)
		m.roughness = 1.0
		m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		_smoke_materials.append(m)

	_fire_material = _emission_material(Color(1.0, 0.20, 0.025), 5.0)
	_hot_material = _emission_material(Color(1.0, 0.72, 0.16), 7.0)
	_tracer_blue = _emission_material(Color(0.48, 0.84, 1.0), 8.0)
	_tracer_red = _emission_material(Color(1.0, 0.30, 0.12), 8.0)

	_dust_material = StandardMaterial3D.new()
	_dust_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_dust_material.albedo_color = Color(0.47, 0.40, 0.29, 0.58)
	_dust_material.roughness = 1.0


func _add_smoke_column(base: Vector3, radius: float, height: float, puffs: int) -> void:
	base.y = _world.height_at(base.x, base.z)
	for i: int in range(puffs):
		var t := float(i) / maxf(1.0, float(puffs - 1))
		var puff := MeshInstance3D.new()
		puff.name = "BattleSmoke"
		var sphere := SphereMesh.new()
		sphere.radius = 0.72
		sphere.height = 1.44
		sphere.radial_segments = 12
		sphere.rings = 7
		puff.mesh = sphere
		var sway := Vector3(
			sin(float(i) * 2.31) * radius * 0.42,
			t * height,
			cos(float(i) * 1.77) * radius * 0.34
		)
		puff.position = base + Vector3(0, 1.0, 0) + sway
		var scale_value := radius * (0.65 + t * 1.05) * (0.84 + 0.16 * sin(float(i) * 1.9))
		puff.scale = Vector3(scale_value, scale_value * 0.85, scale_value)
		puff.material_override = _smoke_materials[i % _smoke_materials.size()]
		add_child(puff)
	smoke_column_count += 1


func _add_fire(base: Vector3, scale_value: float) -> void:
	base.y = _world.height_at(base.x, base.z)
	for i: int in range(5):
		var flame := MeshInstance3D.new()
		flame.name = "BattleFire"
		var sphere := SphereMesh.new()
		sphere.radius = 0.32
		sphere.height = 0.64
		sphere.radial_segments = 10
		sphere.rings = 6
		flame.mesh = sphere
		flame.position = base + Vector3(
			sin(float(i) * 2.2) * 0.28 * scale_value,
			0.35 + float(i) * 0.26 * scale_value,
			cos(float(i) * 2.0) * 0.23 * scale_value
		)
		flame.scale = Vector3(1.0, 1.5 + float(i) * 0.1, 1.0) * scale_value
		flame.material_override = _hot_material if i < 2 else _fire_material
		add_child(flame)

	var light := OmniLight3D.new()
	light.position = base + Vector3(0, 1.1, 0)
	light.light_color = Color(1.0, 0.34, 0.08)
	light.light_energy = 2.3 * scale_value
	light.omni_range = 8.0 * scale_value
	light.shadow_enabled = false
	add_child(light)
	fire_count += 1


func _add_explosion(base: Vector3, scale_value: float) -> void:
	base.y = _world.height_at(base.x, base.z) + 0.9
	for i: int in range(7):
		var orb := MeshInstance3D.new()
		orb.name = "ExplosionCore"
		var sphere := SphereMesh.new()
		sphere.radius = 0.28
		sphere.height = 0.56
		sphere.radial_segments = 10
		sphere.rings = 6
		orb.mesh = sphere
		var angle := float(i) * TAU / 7.0
		orb.position = base + Vector3(cos(angle) * 0.42, sin(float(i) * 1.7) * 0.24, sin(angle) * 0.42) * scale_value
		orb.scale = Vector3.ONE * scale_value * (1.2 if i == 0 else 0.8)
		orb.material_override = _hot_material if i % 2 == 0 else _fire_material
		add_child(orb)

	var light := OmniLight3D.new()
	light.position = base
	light.light_color = Color(1.0, 0.52, 0.16)
	light.light_energy = 5.0 * scale_value
	light.omni_range = 13.0 * scale_value
	light.shadow_enabled = true
	add_child(light)
	explosion_count += 1


func _add_muzzle_flash(base: Vector3, direction: Vector3, friendly: bool) -> void:
	base.y = _world.height_at(base.x, base.z) + 1.35
	direction = direction.normalized()
	var end := base + direction * 2.1
	_add_segment(base, end, 0.12, _hot_material, "MuzzleFlash")
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.24
	sphere.height = 0.48
	core.mesh = sphere
	core.position = end
	core.material_override = _hot_material
	add_child(core)
	muzzle_flash_count += 1


func _add_tracer_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	var mat := _tracer_blue if friendly else _tracer_red
	var previous := start
	for i: int in range(1, 10):
		var t := float(i) / 9.0
		var current := start.lerp(finish, t)
		current.y += sin(t * PI) * arc
		_add_segment(previous, current, 0.045, mat, "Tracer")
		tracer_segment_count += 1
		previous = current


func _add_shell_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	start.y = _world.height_at(start.x, start.z) + 1.2
	finish.y = _world.height_at(finish.x, finish.z) + 1.0
	var mat := _tracer_blue if friendly else _tracer_red
	var previous := start
	for i: int in range(1, 18):
		var t := float(i) / 17.0
		var current := start.lerp(finish, t)
		current.y += sin(t * PI) * arc
		_add_segment(previous, current, 0.035, mat, "ShellTrajectory")
		tracer_segment_count += 1
		previous = current


func _add_impact_dust(base: Vector3) -> void:
	base.y = _world.height_at(base.x, base.z) + 0.25
	for i: int in range(5):
		var dust := MeshInstance3D.new()
		dust.name = "ImpactDust"
		var sphere := SphereMesh.new()
		sphere.radius = 0.35
		sphere.height = 0.70
		sphere.radial_segments = 9
		sphere.rings = 5
		dust.mesh = sphere
		var angle := float(i) * TAU / 5.0
		dust.position = base + Vector3(cos(angle) * 0.55, 0.20 + float(i) * 0.17, sin(angle) * 0.55)
		dust.scale = Vector3(1.35, 1.0, 1.35)
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
