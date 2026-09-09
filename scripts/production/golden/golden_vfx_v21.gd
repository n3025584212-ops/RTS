extends "res://scripts/production/golden/golden_vfx_v20.gd"

const VFX_ROOT := "res://assets/golden_scene/vfx_v21"
var _real_smoke_materials: Array[StandardMaterial3D] = []
var _real_explosion_materials: Array[StandardMaterial3D] = []


func _build_materials() -> void:
	super._build_materials()
	_real_smoke_materials.clear()
	for i: int in range(1, 5):
		var tex := load("%s/smoke%d.png" % [VFX_ROOT, i]) as Texture2D
		if tex == null:
			continue
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_texture = tex
		mat.albedo_color = Color(
			0.16 + float(i) * 0.022,
			0.165 + float(i) * 0.020,
			0.16 + float(i) * 0.018,
			0.63 - float(i) * 0.045
		)
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_real_smoke_materials.append(mat)

	_real_explosion_materials.clear()
	var atlas_source := load("%s/explosion_atlas_512x512.png" % VFX_ROOT) as Texture2D
	if atlas_source != null:
		var cell := 512.0 / 3.0
		for i: int in range(9):
			var atlas := AtlasTexture.new()
			atlas.atlas = atlas_source
			atlas.region = Rect2(float(i % 3) * cell, float(i / 3) * cell, cell, cell)
			var mat := StandardMaterial3D.new()
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_texture = atlas
			mat.albedo_color = Color(1.0, 0.86, 0.66, 0.98)
			mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.20, 0.035)
			mat.emission_energy_multiplier = 2.5
			_real_explosion_materials.append(mat)


func _add_smoke_column(base: Vector3, radius: float, height: float, puffs: int) -> void:
	if _real_smoke_materials.is_empty():
		super._add_smoke_column(base, radius, height, puffs)
		return
	base.y = _world.height_at(base.x, base.z)
	var count := maxi(puffs + 4, 10)
	for i: int in range(count):
		var t := float(i) / maxf(1.0, float(count - 1))
		var puff := MeshInstance3D.new()
		puff.name = "V21BattleSmoke"
		var quad := QuadMesh.new()
		var scale_value := radius * (0.82 + t * 1.36) * (0.92 + 0.10 * sin(float(i) * 2.13))
		quad.size = Vector2(scale_value * 3.15, scale_value * 2.72)
		puff.mesh = quad
		var sway := Vector3(
			sin(float(i) * 2.41) * radius * (0.55 + t * 0.60),
			t * height,
			cos(float(i) * 1.83) * radius * (0.48 + t * 0.46)
		)
		puff.position = base + Vector3(0, 1.0, 0) + sway
		puff.material_override = _real_smoke_materials[i % _real_smoke_materials.size()]
		add_child(puff)
	smoke_column_count += 1


func _add_explosion(base: Vector3, scale_value: float) -> void:
	if _real_explosion_materials.is_empty():
		super._add_explosion(base, scale_value)
		return
	base.y = _world.height_at(base.x, base.z) + 1.0
	for i: int in range(7):
		var sprite := MeshInstance3D.new()
		sprite.name = "V21HEExplosion"
		var quad := QuadMesh.new()
		var size_value := scale_value * (1.15 + float(i % 3) * 0.28)
		quad.size = Vector2(size_value * 1.18, size_value)
		sprite.mesh = quad
		var angle := float(i) * TAU / 7.0
		sprite.position = base + Vector3(
			cos(angle) * 0.54 * scale_value,
			0.18 + sin(float(i) * 1.61) * 0.35 * scale_value,
			sin(angle) * 0.54 * scale_value
		)
		sprite.material_override = _real_explosion_materials[(i * 4 + 1) % _real_explosion_materials.size()]
		add_child(sprite)

	var light := OmniLight3D.new()
	light.name = "V21ExplosionLight"
	light.position = base + Vector3(0,0.35,0)
	light.light_color = Color(1.0, 0.37, 0.07)
	light.light_energy = 4.8 * scale_value
	light.omni_range = 11.0 * scale_value
	light.shadow_enabled = false
	add_child(light)

	_add_afterblast_smoke(base, scale_value)
	explosion_count += 1


func _add_afterblast_smoke(base: Vector3, scale_value: float) -> void:
	if _real_smoke_materials.is_empty():
		return
	for i: int in range(4):
		var puff := MeshInstance3D.new()
		puff.name = "V21AfterblastSmoke"
		var quad := QuadMesh.new()
		quad.size = Vector2(scale_value * (1.7 + float(i) * 0.25), scale_value * (1.4 + float(i) * 0.20))
		puff.mesh = quad
		var angle := float(i) * TAU / 4.0 + 0.35
		puff.position = base + Vector3(cos(angle) * scale_value * 0.65, 0.9 + float(i) * 0.42, sin(angle) * scale_value * 0.65)
		puff.material_override = _real_smoke_materials[(i + 1) % _real_smoke_materials.size()]
		add_child(puff)


func _add_fire(base: Vector3, scale_value: float) -> void:
	super._add_fire(base, scale_value * 1.22)
	if _real_smoke_materials.is_empty():
		return
	base.y = _world.height_at(base.x, base.z)
	for i: int in range(3):
		var puff := MeshInstance3D.new()
		puff.name = "V21FireSmoke"
		var quad := QuadMesh.new()
		quad.size = Vector2(scale_value * (1.65 + float(i) * 0.38), scale_value * (1.35 + float(i) * 0.34))
		puff.mesh = quad
		puff.position = base + Vector3(
			sin(float(i) * 1.7) * 0.45 * scale_value,
			1.45 + float(i) * 1.05 * scale_value,
			cos(float(i) * 1.4) * 0.32 * scale_value
		)
		puff.material_override = _real_smoke_materials[i % _real_smoke_materials.size()]
		add_child(puff)


func _add_tracer_arc(start: Vector3, finish: Vector3, arc: float, friendly: bool) -> void:
	var mat := _tracer_blue if friendly else _tracer_red
	for center_t: float in [0.32, 0.61]:
		var a := _arc_point(start, finish, maxf(0.0, center_t - 0.030), arc)
		var b := _arc_point(start, finish, minf(1.0, center_t + 0.030), arc)
		_add_segment(a, b, 0.052, mat, "V21Tracer")
		tracer_segment_count += 1
