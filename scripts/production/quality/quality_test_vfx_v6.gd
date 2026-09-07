extends "res://scripts/production/quality/quality_test_vfx_v5.gd"

func _add_smoke(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "DesignSmokeColumn"
	particles.amount = 72
	particles.lifetime = 7.5
	particles.preprocess = 5.2
	particles.local_coords = false
	particles.position = p

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.82
	process.direction = Vector3(0.18,1.0,-0.04)
	process.spread = 27.0
	process.initial_velocity_min = 0.38
	process.initial_velocity_max = 1.05
	process.gravity = Vector3(0.0,0.06,0.0)
	process.scale_min = 0.72
	process.scale_max = 2.15
	process.color = Color(1,1,1,1)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(3.4,3.4)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.15,0.15,0.145,0.62)
	material.albedo_texture = _soft_disc_texture(128,false)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	smoke_emitters += 1
