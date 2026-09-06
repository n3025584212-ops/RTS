class_name QualityTestVFXV1
extends Node3D

var smoke_emitters: int = 0
var fire_emitters: int = 0
var spark_emitters: int = 0

func build() -> void:
	_add_smoke(Vector3(19.0, 2.0, -4.0))
	_add_fire(Vector3(18.4, 0.55, -4.2))
	_add_sparks(Vector3(1.5, 1.1, 4.0))
	print("FRONTLINE_QUALITY_VFX_READY smoke=%d fire=%d sparks=%d" %
		[smoke_emitters, fire_emitters, spark_emitters])


func _add_smoke(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualitySmoke"
	particles.amount = 56
	particles.lifetime = 6.5
	particles.preprocess = 4.0
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.85
	process.direction = Vector3(0.08, 1.0, -0.05)
	process.spread = 24.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 0.95
	process.gravity = Vector3(0.0, 0.10, 0.0)
	process.scale_min = 0.55
	process.scale_max = 1.75
	process.color = Color(0.18, 0.18, 0.17, 0.34)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(2.4, 2.4)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.19, 0.19, 0.18, 0.34)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	smoke_emitters += 1


func _add_fire(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualityFire"
	particles.amount = 34
	particles.lifetime = 1.1
	particles.preprocess = 1.0
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.34
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 38.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 1.25
	process.gravity = Vector3(0.0, -0.10, 0.0)
	process.scale_min = 0.14
	process.scale_max = 0.48
	process.color = Color(1.0, 0.30, 0.04, 0.92)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.7, 1.0)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.24, 0.035, 0.86)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.16, 0.02)
	material.emission_energy_multiplier = 2.2
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	fire_emitters += 1


func _add_sparks(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualityImpactSparks"
	particles.amount = 24
	particles.lifetime = 0.7
	particles.preprocess = 0.45
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.16
	process.direction = Vector3(0.2, 0.9, 0.15)
	process.spread = 72.0
	process.initial_velocity_min = 1.4
	process.initial_velocity_max = 4.0
	process.gravity = Vector3(0.0, -5.0, 0.0)
	process.scale_min = 0.035
	process.scale_max = 0.10
	process.color = Color(1.0, 0.58, 0.14, 1.0)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.56, 0.12)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.34, 0.05)
	material.emission_energy_multiplier = 3.0
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	spark_emitters += 1
