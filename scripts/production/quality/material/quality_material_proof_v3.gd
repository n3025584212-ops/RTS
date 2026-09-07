extends "res://scripts/production/quality/material/quality_material_proof_v2.gd"

const ABRAMS_STATIC := "res://assets/golden_scene/quality_material_v3/mbt_abrams_static.glb"

var _grass_card_texture: Texture2D

func _preflight() -> void:
	for path: String in [HOUSE,ABRAMS_STATIC,GRASS,WEED,ROCK_SMALL,ROCK_LARGE]:
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


func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(18,18))
	house_root = _spawn_scaled(HOUSE,Vector3.ZERO,10.8,0.0,"MaterialProofHouseV3")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true
	_ground_visual_to(house_root,0.015)

	var y_bounds: Vector2 = _world_y_bounds(house_root)
	var touched: int = 0
	for mi: MeshInstance3D in _collect_meshes(house_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var standard: StandardMaterial3D = source as StandardMaterial3D
				if standard.albedo_texture != null:
					mi.set_surface_override_material(surface,_house_authored_surface_v3(standard,y_bounds))
					touched += 1
				else:
					var preserved: StandardMaterial3D = standard.duplicate() as StandardMaterial3D
					preserved.roughness = clampf(maxf(preserved.roughness,0.58),0.58,0.92)
					preserved.metallic = minf(preserved.metallic,0.08)
					mi.set_surface_override_material(surface,preserved)
					touched += 1
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_debris_v3(Vector3.ZERO)
	_add_micro_grass_ring(Vector3.ZERO,7.0,14)


func _house_authored_surface_v3(source: StandardMaterial3D,y_bounds: Vector2) -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D base_tex : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);
uniform float world_y_min = 0.0;
uniform float world_y_span = 1.0;
varying vec3 wp;
varying vec3 wn;
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec2 suv=UV*uv_scale+uv_offset;
	vec4 tex=texture(base_tex,suv)*base_color;
	float h=clamp((wp.y-world_y_min)/max(world_y_span,0.001),0.0,1.0);
	float vertical=clamp(1.0-abs(wn.y),0.0,1.0);
	float streak=0.5+0.5*sin(wp.x*3.7+wp.z*4.9+sin(wp.y*2.3));
	float fine=0.5+0.5*sin(wp.x*23.0+wp.z*17.0+wp.y*11.0);
	float lower=(1.0-smoothstep(0.05,0.27,h))*vertical;
	float luma=dot(tex.rgb,vec3(0.2126,0.7152,0.0722));
	float dark=1.0-smoothstep(0.07,0.24,luma);
	float grime=lower*(0.12+0.20*streak)*(1.0-dark*0.72);
	vec3 weathered=tex.rgb*vec3(0.72,0.69,0.62)+vec3(0.035,0.028,0.020);
	ALBEDO=mix(tex.rgb,weathered,grime);
	NORMAL_MAP=vec3(0.5+(fine-0.5)*0.050,0.5+(streak-0.5)*0.030,1.0);
	NORMAL_MAP_DEPTH=0.32;
	ROUGHNESS=clamp(0.59+vertical*0.12+grime*0.22-dark*0.22+fine*0.045,0.30,0.94);
	METALLIC=dark*0.025;
	SPECULAR=0.27+dark*0.13;
	AO=clamp(0.90+fine*0.10,0.82,1.0);
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("base_tex",source.albedo_texture)
	mat.set_shader_parameter("base_color",source.albedo_color)
	mat.set_shader_parameter("uv_scale",Vector2(source.uv1_scale.x,source.uv1_scale.y))
	mat.set_shader_parameter("uv_offset",Vector2(source.uv1_offset.x,source.uv1_offset.y))
	mat.set_shader_parameter("world_y_min",y_bounds.x)
	mat.set_shader_parameter("world_y_span",maxf(y_bounds.y-y_bounds.x,0.001))
	return mat


func _add_house_debris_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-3.1,0.07,4.6),Vector3(-2.55,0.06,4.85),Vector3(-1.95,0.05,4.55),
		Vector3(3.15,0.06,4.45),Vector3(3.55,0.05,3.95)
	]
	for i: int in range(offsets.size()):
		var rubble: Node3D = _spawn_scaled(ROCK_SMALL,center+offsets[i],0.28+0.035*float(i%3),17.0+31.0*float(i),"HouseRubbleV3_%02d" % i)
		if rubble != null:
			rubble.position.y += 0.01


func _build_abrams_proof() -> void:
	var center: Vector3 = Vector3(45,0,0)
	_add_pad(center,Vector2(19,19))
	abrams_root = _spawn_scaled(ABRAMS_STATIC,center,7.4,-18.0,"MaterialProofAbramsV3")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_abrams_by_wheels(abrams_root,0.045)

	var hull: ShaderMaterial = _vehicle_hull_shader_v3()
	var track: StandardMaterial3D = _track_material_v3()
	var rubber: StandardMaterial3D = _rubber_material_v3()
	var gun: StandardMaterial3D = _gun_material_v3()
	var optics: StandardMaterial3D = _optics_material()
	var layered_count: int = 0

	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var source: Material = mi.mesh.surface_get_material(surface)
			var source_name: String = ""
			if source != null:
				source_name = source.resource_name.to_lower()
				key += " "+source_name
			var chosen: Material = hull
			var apply_override: bool = true
			if key.contains("wheel"):
				chosen = rubber
			elif key.contains("barrel") or key.contains("gun"):
				chosen = gun
			elif key.contains("guide") or key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif source == null or source_name.is_empty():
				chosen = track
			elif key.contains("nukclearsign") or key.contains("material.001"):
				apply_override = false
			elif key.contains("exhaust"):
				chosen = track
			if apply_override:
				mi.set_surface_override_material(surface,chosen)
				layered_count += 1
			print("FRONTLINE_MATERIAL_V3_SURFACE key=%s class=%s override=%s" % [key,chosen.get_class(),str(apply_override)])
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_ruts(center,-18.0)
	_add_procedural_stones(center+Vector3(0,0,4.2),10,5.2)
	_add_micro_grass_ring(center,7.0,12)


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	float macro=0.5+0.5*sin(wp.x*0.71+sin(wp.z*0.53)*1.7+wp.y*0.19);
	float fine=0.5+0.5*sin(wp.x*8.1+wp.z*6.3+wp.y*5.7);
	float fleck=0.5+0.5*sin(wp.x*31.0-wp.z*27.0+wp.y*19.0);
	float low=1.0-smoothstep(0.65,1.55,wp.y);
	vec3 olive=mix(vec3(0.20,0.225,0.075),vec3(0.315,0.325,0.105),macro*0.58);
	vec3 dust=vec3(0.255,0.185,0.092);
	float mud=clamp(low*(0.12+0.24*fine)+fleck*low*0.035,0.0,0.38);
	vec3 base=mix(olive,dust,mud);
	float wear=(1.0-low)*smoothstep(0.78,0.98,fleck)*0.065;
	ALBEDO=base+vec3(wear*0.20,wear*0.18,wear*0.10);
	NORMAL_MAP=vec3(0.5+(fine-0.5)*0.035,0.5+(fleck-0.5)*0.025,1.0);
	NORMAL_MAP_DEPTH=0.25;
	METALLIC=0.18+wear*0.55;
	ROUGHNESS=clamp(0.54+mud*0.72+fine*0.075-wear*0.25,0.45,0.91);
	SPECULAR=0.34;
	AO=clamp(0.90+fine*0.10,0.84,1.0);
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	return mat


func _track_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.095,0.088,0.072)
	mat.metallic = 0.62
	mat.metallic_specular = 0.46
	mat.roughness = 0.58
	return mat


func _rubber_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.060,0.062,0.052)
	mat.metallic = 0.02
	mat.roughness = 0.84
	return mat


func _gun_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.135,0.145,0.090)
	mat.metallic = 0.38
	mat.metallic_specular = 0.40
	mat.roughness = 0.49
	return mat


func _add_vehicle_ruts(center: Vector3,yaw: float) -> void:
	_add_rut_ribbon_v3(center,yaw,-1.52)
	_add_rut_ribbon_v3(center,yaw,1.52)


func _add_rut_ribbon_v3(center: Vector3,yaw: float,side: float) -> void:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var angle: float = deg_to_rad(yaw)
	var lateral: Vector3 = Vector3(cos(angle),0.0,-sin(angle))
	var forward: Vector3 = Vector3(sin(angle),0.0,cos(angle))
	var segments: int = 14
	for i: int in range(segments):
		var t: float = float(i)/float(segments-1)
		var z: float = -3.85+t*7.70
		var wave: float = 0.075*sin(float(i)*1.37+side)
		var width: float = (0.19+0.045*sin(float(i)*0.91+1.2))*sin(PI*t)
		width = maxf(width,0.045)
		var mid: Vector3 = center+forward*z+lateral*(side+wave)+Vector3(0,0.018,0)
		vertices.append(mid-lateral*width)
		vertices.append(mid+lateral*width)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		uvs.append(Vector2(0.0,t*5.0))
		uvs.append(Vector2(1.0,t*5.0))
		if i < segments-1:
			var base: int = i*2
			indices.append_array(PackedInt32Array([base,base+2,base+1,base+1,base+2,base+3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var rut: MeshInstance3D = MeshInstance3D.new()
	rut.name = "VehicleRutRibbonV3"
	rut.mesh = mesh
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png")
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png")
	mat.albedo_color = Color(0.58,0.53,0.43)
	mat.roughness = 0.94
	rut.material_override = mat
	add_child(rut)


func _build_ground_proof() -> void:
	var center: Vector3 = Vector3(90,0,0)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "TenMeterMaterialGroundV3"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(10.0,10.0)
	plane.subdivide_width = 72
	plane.subdivide_depth = 72
	ground.mesh = plane
	ground.position = center
	ground.material_override = _ground_proof_shader_v3()
	add_child(ground)
	proof_checks["ground_built"] = true

	_add_ground_natural_clumps_v3(center)
	_add_micro_grass_ring(center,4.65,18)
	_add_procedural_stones(center,20,4.55)
	_add_ground_debris_v3(center)
	proof_checks["ground_microgeometry"] = true


func _ground_proof_shader_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
float track_mask(vec2 p){
	float c1=-1.28+0.12*sin(p.y*0.88);
	float c2= 1.28+0.10*sin(p.y*0.82+1.3);
	float a=1.0-smoothstep(0.18,0.48,abs(p.x-c1));
	float b=1.0-smoothstep(0.18,0.48,abs(p.x-c2));
	float ends=1.0-smoothstep(3.75,4.72,abs(p.y));
	return max(a,b)*ends;
}
void vertex(){
	vec2 p=VERTEX.xz;
	float rut=track_mask(p);
	float churn=(1.0-smoothstep(0.75,2.45,length(p-vec2(0.55,0.35))))*(0.45+0.55*sin(p.x*3.1+p.y*2.7)*0.5+0.25);
	float micro=0.026*sin(p.x*2.1)+0.019*cos(p.y*2.7)+0.010*sin((p.x+p.y)*5.4);
	VERTEX.y += micro-0.050*pow(rut,1.55)-0.014*churn;
	lp=vec3(p.x,VERTEX.y,p.y);
}
void fragment(){
	vec2 p=lp.xz;
	vec2 uv=UV*8.7;
	float n1=0.5+0.5*sin(p.x*0.73+p.y*0.57+sin(p.y*0.39)*1.6);
	float n2=0.5+0.5*sin(p.x*1.91-p.y*1.43+sin(p.x*0.83));
	float dirt_mask=clamp(0.12+0.34*n1+0.20*n2,0.0,0.68);
	float rut=track_mask(p);
	float churn=(1.0-smoothstep(0.75,2.55,length(p-vec2(0.55,0.35))))*(0.55+0.45*n2);
	float ellipse=length(vec2((p.x-1.20)/1.22,(p.y-0.62)/0.58));
	float wet=1.0-smoothstep(0.78+0.06*sin(p.x*5.0+p.y*4.0),1.08,ellipse);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.50,0.61,0.34);
	vec3 dirt=texture(dirt_diff,uv*0.91).rgb*vec3(0.55,0.45,0.31);
	vec3 mud=texture(mud_diff,uv*0.83).rgb*vec3(0.43,0.34,0.25);
	float mud_mix=clamp(rut*0.72+churn*0.42+wet*0.46,0.0,0.88);
	vec3 base=mix(grass,dirt,dirt_mask*0.62);
	base=mix(base,mud,mud_mix);
	base=mix(base,base*vec3(0.58,0.63,0.66),wet*0.38);
	vec3 nrm=mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.91).rgb,dirt_mask*0.62);
	nrm=mix(nrm,texture(mud_nor,uv*0.83).rgb,mud_mix);
	ALBEDO=base;
	NORMAL_MAP=nrm;
	NORMAL_MAP_DEPTH=0.72;
	ROUGHNESS=clamp(0.93-rut*0.06-churn*0.04-wet*0.66,0.22,0.95);
	SPECULAR=0.25+wet*0.22;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	return mat


func _add_ground_natural_clumps_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-3.7,0,-3.1),Vector3(-2.4,0,-1.9),Vector3(-3.3,0,1.5),Vector3(-1.8,0,3.4),
		Vector3(3.5,0,-3.2),Vector3(2.6,0,-1.3),Vector3(3.6,0,1.8),Vector3(2.1,0,3.5),
		Vector3(-0.3,0,-3.8),Vector3(0.6,0,3.7),Vector3(-3.9,0,-0.3),Vector3(3.9,0,0.2)
	]
	for i: int in range(offsets.size()):
		var path: String = GRASS if i%3 != 0 else WEED
		var target: float = 0.62+0.09*float(i%4)
		var plant: Node3D = _spawn_scaled(path,center+offsets[i],target,17.0+37.0*float(i),"GroundPlantV3_%02d" % i)
		if plant != null:
			plant.position.y += 0.012


func _add_ground_debris_v3(center: Vector3) -> void:
	for i: int in range(7):
		var shard: MeshInstance3D = MeshInstance3D.new()
		shard.name = "GroundDebrisV3"
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.28+0.05*float(i%3),0.035,0.075+0.018*float((i+1)%3))
		shard.mesh = box
		var a: float = float(i)*2.173
		var radius: float = 1.8+0.31*float(i)
		shard.position = center+Vector3(cos(a)*radius,0.035,sin(a)*radius)
		shard.rotation_degrees = Vector3(0,23.0+41.0*float(i),float(i%2)*7.0)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		var shade: float = 0.10+0.018*float(i%3)
		mat.albedo_color = Color(shade*1.16,shade,shade*0.76)
		mat.metallic = 0.12 if i%3 == 0 else 0.0
		mat.roughness = 0.86
		shard.material_override = mat
		add_child(shard)


func _add_churn_patch(center: Vector3,size: Vector2,yaw: float) -> void:
	# V3 intentionally removes the rectangular overlay patch.
	pass


func _add_grass_tuft(pos: Vector3,height: float,yaw: float) -> void:
	if _grass_card_texture == null:
		_grass_card_texture = _make_grass_card_texture()
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = _grass_card_texture
	mat.albedo_color = Color(0.54,0.66,0.36,1.0)
	mat.roughness = 0.95
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for j: int in range(3):
		var blade_card: MeshInstance3D = MeshInstance3D.new()
		blade_card.name = "GrassCardV3"
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(0.44,height*1.12)
		blade_card.mesh = quad
		var offset_angle: float = deg_to_rad(yaw+float(j)*61.0)
		blade_card.position = pos+Vector3(cos(offset_angle)*0.035,height*0.47,sin(offset_angle)*0.035)
		blade_card.rotation_degrees = Vector3(0,yaw+float(j)*61.0,0)
		blade_card.material_override = mat
		add_child(blade_card)


func _make_grass_card_texture() -> Texture2D:
	var image: Image = Image.create(192,192,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	var centers: Array[float] = [0.12,0.22,0.31,0.40,0.50,0.59,0.69,0.78,0.87]
	var heights: Array[float] = [0.58,0.79,0.70,0.91,0.82,0.96,0.73,0.86,0.62]
	for y: int in range(192):
		for x: int in range(192):
			var fx: float = float(x)/191.0
			var fy: float = float(y)/191.0
			var alpha: float = 0.0
			var tone: float = 0.0
			for i: int in range(centers.size()):
				var top: float = 1.0-heights[i]
				if fy < top:
					continue
				var t: float = (fy-top)/maxf(heights[i],0.001)
				var bend: float = (0.5-t)*0.050*sin(float(i)*1.41)+(t*t)*0.028*sin(float(i)*2.13)
				var taper: float = maxf(0.12,1.0-t*0.91)
				var width: float = (0.021+0.006*float(i%4))*taper
				var d: float = absf(fx-(centers[i]+bend))
				if d < width:
					var blade_alpha: float = 1.0-smoothstep(width*0.36,width,d)
					alpha = maxf(alpha,blade_alpha)
					tone = maxf(tone,0.34+0.56*(1.0-t)+0.08*sin(float(i)*2.7))
			if alpha > 0.01:
				var base_dark: float = smoothstep(0.72,1.0,fy)
				var r: float = 0.12+0.07*tone+0.025*base_dark
				var g: float = 0.25+0.31*tone-0.035*base_dark
				var b: float = 0.045+0.030*tone
				image.set_pixel(x,y,Color(r,g,b,clampf(alpha,0.0,1.0)))
	return ImageTexture.create_from_image(image)


func _world_y_bounds(root: Node3D) -> Vector2:
	var minimum: float = INF
	var maximum: float = -INF
	for mi: MeshInstance3D in _collect_meshes(root):
		if mi.mesh == null:
			continue
		var aabb: AABB = mi.mesh.get_aabb()
		var corners: Array[Vector3] = [
			aabb.position,
			aabb.position+Vector3(aabb.size.x,0,0),
			aabb.position+Vector3(0,aabb.size.y,0),
			aabb.position+Vector3(0,0,aabb.size.z),
			aabb.position+Vector3(aabb.size.x,aabb.size.y,0),
			aabb.position+Vector3(aabb.size.x,0,aabb.size.z),
			aabb.position+Vector3(0,aabb.size.y,aabb.size.z),
			aabb.position+aabb.size
		]
		for corner: Vector3 in corners:
			var world_point: Vector3 = mi.global_transform*corner
			minimum = minf(minimum,world_point.y)
			maximum = maxf(maximum,world_point.y)
	if is_inf(minimum) or is_inf(maximum):
		return Vector2(0.0,1.0)
	return Vector2(minimum,maximum)


func _ground_abrams_by_wheels(root: Node3D,target_y: float) -> void:
	var minimum: float = INF
	var matched: int = 0
	for mi: MeshInstance3D in _collect_meshes(root):
		if mi.mesh == null:
			continue
		var wheel_mesh: bool = false
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var source: Material = mi.mesh.surface_get_material(surface)
			if source != null:
				key += " "+source.resource_name.to_lower()
			if key.contains("wheel"):
				wheel_mesh = true
				break
		if not wheel_mesh:
			continue
		matched += 1
		var aabb: AABB = mi.mesh.get_aabb()
		var corners: Array[Vector3] = [
			aabb.position,
			aabb.position+Vector3(aabb.size.x,0,0),
			aabb.position+Vector3(0,aabb.size.y,0),
			aabb.position+Vector3(0,0,aabb.size.z),
			aabb.position+Vector3(aabb.size.x,aabb.size.y,0),
			aabb.position+Vector3(aabb.size.x,0,aabb.size.z),
			aabb.position+Vector3(0,aabb.size.y,aabb.size.z),
			aabb.position+aabb.size
		]
		for corner: Vector3 in corners:
			var world_point: Vector3 = mi.global_transform*corner
			minimum = minf(minimum,world_point.y)
	if matched > 0 and not is_inf(minimum):
		var delta: float = target_y-minimum
		root.position.y += delta
		print("FRONTLINE_ABRAMS_WHEEL_GROUND matched=%d min_before=%.4f delta=%.4f root_y=%.4f" % [matched,minimum,delta,root.position.y])
	else:
		_ground_visual_to(root,target_y)
		print("FRONTLINE_ABRAMS_WHEEL_GROUND fallback=true")


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.2,6.2,13.8),Vector3(0,2.25,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(55.8,4.15,10.6),Vector3(45,1.25,0))
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
