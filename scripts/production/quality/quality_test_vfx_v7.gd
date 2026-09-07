extends "res://scripts/production/quality/quality_test_vfx_v5.gd"

func build() -> void:
	_add_smoke(Vector3(16.0,2.0,11.0))
	_add_smoke(Vector3(38.0,2.3,-18.0))
	_add_fire(Vector3(11.0,0.48,3.0))
	_add_fire(Vector3(16.0,0.50,11.0))
	_add_dust_impact(Vector3(4.0,0.20,7.5))
	_add_muzzle_burst(Vector3(-5.5,1.10,6.0),Vector3(0.94,0.03,-0.34))
	print("FRONTLINE_QUALITY_VFX_READY smoke=%d fire=%d sparks=%d" %
		[smoke_emitters,fire_emitters,spark_emitters])


func _add_smoke(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "V16SmokeColumn"
	particles.amount = 58
	particles.lifetime = 7.2
	particles.preprocess = 4.6
	particles.local_coords = false
	particles.position = p

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.78
	process.direction = Vector3(0.16,1.0,-0.05)
	process.spread = 28.0
	process.initial_velocity_min = 0.32
	process.initial_velocity_max = 0.86
	process.gravity = Vector3(0.0,0.055,0.0)
	process.scale_min = 0.55
	process.scale_max = 1.75
	process.color = Color(1,1,1,1)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(2.7,2.7)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.30,0.29,0.27,0.32)
	material.albedo_texture = _soft_disc_texture(96,false)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	smoke_emitters += 1
