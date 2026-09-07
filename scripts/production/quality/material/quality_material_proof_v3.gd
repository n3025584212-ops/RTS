extends "res://scripts/production/quality/material/quality_material_proof_v2.gd"

const ABRAMS_STATIC := "res://assets/golden_scene/quality_material_v3/mbt_abrams_static.glb"

var _grass_card_texture: Texture2D

func _preflight() -> void:
	for path: String in [HOUSE,ABRAMS_STATIC,ROCK_SMALL,ROCK_LARGE]:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _add_pad(center: Vector3,size: Vector2) -> void:
	var pad := MeshInstance3D.new()
	pad.name = "QualityPBRPad"
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = 32
	plane.subdivide_depth = 32
	pad.mesh = plane
	pad.position = center
	pad.material_override = _quality_pad_shader()
	add_child(pad)


func _quality_pad_shader() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
void vertex(){
	lp=VERTEX;
	VERTEX.y += 0.035*sin(VERTEX.x*1.7)+0.025*cos(VERTEX.z*2.1);
}
void fragment(){
	vec2 uv=UV*8.0;
	float macro=0.5+0.5*sin(lp.x*0.71+lp.z*0.53);
	float dirt_mask=smoothstep(0.36,0.78,macro);
	float wet=1.0-smoothstep(0.65,2.8,length(lp.xz-vec2(1.1,0.5)));
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.55,0.69,0.38);
	vec3 dirt=texture(dirt_diff,uv*0.88).rgb*vec3(0.56,0.46,0.31);
	vec3 mud=texture(mud_diff,uv*0.80).rgb*vec3(0.39,0.31,0.23);
	vec3 base=mix(grass,dirt,dirt_mask*0.44);
	base=mix(base,mud,wet*0.20);
	ALBEDO=base;
	NORMAL_MAP=mix(
		mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.88).rgb,dirt_mask*0.44),
		texture(mud_nor,uv*0.80).rgb,wet*0.20
	);
	NORMAL_MAP_DEPTH=0.58;
	ROUGHNESS=mix(0.93,0.78,wet*0.24);
	SPECULAR=0.24;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	return mat


func _build_abrams_proof() -> void:
	var center := Vector3(45,0,0)
	_add_pad(center,Vector2(19,19))
	abrams_root = _spawn_scaled(ABRAMS_STATIC,center,7.4,-18.0,"MaterialProofAbramsV3")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_visual_to(abrams_root,0.02)

	var hull := _vehicle_hull_shader_v3()
	var track := _track_material()
	var rubber := _rubber_material()
	var metal := _metal_material()
	var optics := _optics_material()
	var layered_count := 0

	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = hull
			if key.contains("track") or key.contains("chain"):
				chosen = track
			elif key.contains("tire") or key.contains("rubber") or key.contains("wheel"):
				chosen = rubber
			elif key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif key.contains("barrel") or key.contains("gun") or key.contains("exhaust"):
				chosen = metal
			mi.set_surface_override_material(surface,chosen)
			layered_count += 1
			print("FRONTLINE_MATERIAL_V3_SURFACE key=%s" % key)
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_ruts(center,-18.0)
	_add_procedural_stones(center+Vector3(0,0,4.2),12,5.2)
	_add_micro_grass_ring(center,7.0,20)


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
void vertex(){ lp=VERTEX; }
void fragment(){
	float macro=0.5+0.5*sin(lp.x*0.58+sin(lp.z*0.49)*1.8);
	float fine=0.5+0.5*sin(lp.x*7.2+lp.z*5.6);
	float lower=smoothstep(0.76,-0.52,lp.y);
	float vertical=0.5+0.5*sin(lp.x*2.1-lp.z*1.8);
	vec3 olive=mix(vec3(0.155,0.185,0.060),vec3(0.235,0.255,0.092),macro*0.47);
	vec3 mud=vec3(0.245,0.172,0.090);
	float mud_mask=clamp(lower*(0.18+0.29*fine)+vertical*0.028,0.0,0.50);
	vec3 base=mix(olive,mud,mud_mask);
	float wear=(1.0-lower)*fine*0.05;
	base+=vec3(wear*0.16,wear*0.14,wear*0.08);
	ALBEDO=base;
	METALLIC=0.14+wear*0.65;
	ROUGHNESS=clamp(0.57+mud_mask*0.68-wear*0.30,0.48,0.92);
	SPECULAR=0.31;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat


func _add_vehicle_ruts(center: Vector3,yaw: float) -> void:
	for side: float in [-1.55,1.55]:
		var rut := MeshInstance3D.new()
		rut.name = "VehicleRut"
		var plane := PlaneMesh.new()
		plane.size = Vector2(0.52,7.6)
		rut.mesh = plane
		var angle := deg_to_rad(yaw)
		var lateral := Vector3(cos(angle),0,-sin(angle))*side
		rut.position = center+lateral+Vector3(0,0.018,0)
		rut.rotation_degrees.y = yaw
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png")
		mat.normal_enabled = true
		mat.normal_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png")
		mat.albedo_color = Color(0.43,0.37,0.28)
		mat.roughness = 0.91
		mat.uv1_scale = Vector3(1.0,4.0,1.0)
		rut.material_override = mat
		add_child(rut)


func _build_ground_proof() -> void:
	var center := Vector3(90,0,0)
	_add_pad(center,Vector2(10,10))
	proof_checks["ground_built"] = true

	_add_vehicle_ruts(center,-8.0)
	_add_puddle(center+Vector3(1.4,0.035,0.7),Vector2(1.05,0.42),-6.0)
	_add_micro_grass_ring(center,4.8,46)
	_add_procedural_stones(center,24,4.7)
	proof_checks["ground_microgeometry"] = true


func _add_churn_patch(center: Vector3,size: Vector2,yaw: float) -> void:
	# V3 intentionally removes the rectangular overlay patch.
	pass


func _add_grass_tuft(pos: Vector3,height: float,yaw: float) -> void:
	if _grass_card_texture == null:
		_grass_card_texture = _make_grass_card_texture()
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = _grass_card_texture
	mat.albedo_color = Color(0.72,0.84,0.52,1.0)
	mat.roughness = 0.94
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for j: int in range(3):
		var blade_card := MeshInstance3D.new()
		blade_card.name = "GrassCard"
		var quad := QuadMesh.new()
		quad.size = Vector2(0.56,height*1.35)
		blade_card.mesh = quad
		blade_card.position = pos+Vector3(0,height*0.56,0)
		blade_card.rotation_degrees = Vector3(0,yaw+float(j)*60.0,0)
		blade_card.material_override = mat
		add_child(blade_card)


func _make_grass_card_texture() -> Texture2D:
	var image: Image = Image.create(128,128,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	var centers: Array[float] = [0.18,0.29,0.41,0.52,0.63,0.74,0.84]
	var heights: Array[float] = [0.66,0.82,0.72,0.94,0.78,0.88,0.64]
	for y: int in range(128):
		for x: int in range(128):
			var fx: float = float(x)/127.0
			var fy: float = float(y)/127.0
			var alpha: float = 0.0
			var green: float = 0.0
			for i: int in range(centers.size()):
				var top: float = 1.0-heights[i]
				if fy < top:
					continue
				var t: float = (fy-top)/maxf(heights[i],0.001)
				var lean: float = (0.5-t)*0.055*sin(float(i)*1.73)
				var width: float = (0.026+0.007*float(i%3))*(1.0-t*0.86)
				var d: float = absf(fx-(centers[i]+lean))
				if d < width:
					alpha = maxf(alpha,1.0-smoothstep(width*0.45,width,d))
					green = maxf(green,0.45+0.42*(1.0-t))
			if alpha > 0.01:
				image.set_pixel(x,y,Color(0.18+0.09*green,0.34+0.28*green,0.07,alpha))
	return ImageTexture.create_from_image(image)


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.2,6.2,13.8),Vector3(0,2.25,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(56.0,4.6,10.8),Vector3(45,1.45,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(95.5,6.9,8.0),Vector3(90,0.0,0))
	_write_metrics_v3()
	var all_pass := true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v3() -> void:
	var payload := {
		"task_id": "QUALITY_MATERIAL_PROOF_V3",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"abrams_asset": ABRAMS_STATIC,
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file := FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
