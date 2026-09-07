extends "res://scripts/production/quality/material/quality_material_proof_v2.gd"

const ABRAMS_STATIC := "res://assets/golden_scene/quality_material_v3/mbt_abrams_static.glb"
var _grass_card_texture: Texture2D

func _spawn_scaled(path: String,pos: Vector3,target_size: float,yaw: float,name_value: String) -> Node3D:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("MATERIAL_PROOF_LOAD_FAIL path=%s" % path)
		return null
	var node: Node3D = packed.instantiate() as Node3D
	if node == null:
		return null
	node.name = name_value
	add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	var bounds: AABB = _local_bounds(node)
	var largest: float = maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
	if largest > 0.001:
		var scale_factor: float = target_size/largest
		node.scale = Vector3.ONE*scale_factor
	_ground_visual_to(node,pos.y+0.012)
	return node


func _preflight() -> void:
	for path: String in [HOUSE,ABRAMS_STATIC,GRASS,WEED,ROCK_SMALL,ROCK_LARGE]:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.name = "MaterialProofEnvironmentV3"
	var env: Environment = Environment.new()
	var sky_mat: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25,0.32,0.39)
	sky_mat.sky_horizon_color = Color(0.61,0.63,0.62)
	sky_mat.ground_bottom_color = Color(0.15,0.16,0.14)
	sky_mat.ground_horizon_color = Color(0.42,0.43,0.40)
	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.82
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.76
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_density = 0.0008
	env.fog_light_color = Color(0.60,0.62,0.62)
	env.fog_aerial_perspective = 0.13
	env.ssao_enabled = true
	env.ssao_radius = 1.8
	env.ssao_intensity = 1.32
	env.ssao_power = 1.10
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.99
	env.adjustment_contrast = 1.07
	env.adjustment_saturation = 0.88
	world_env.environment = env
	add_child(world_env)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "MaterialProofSunV3"
	sun.rotation_degrees = Vector3(-47.0,-36.0,0.0)
	sun.light_color = Color(1.0,0.95,0.87)
	sun.light_energy = 1.04
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 85.0
	add_child(sun)

	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.name = "MaterialProofFillV3"
	fill.rotation_degrees = Vector3(-58.0,142.0,0.0)
	fill.light_color = Color(0.47,0.58,0.70)
	fill.light_energy = 0.25
	add_child(fill)


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
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
void vertex(){
	lp=VERTEX;
	VERTEX.y += 0.020*sin(VERTEX.x*1.31)+0.015*cos(VERTEX.z*1.73);
}
void fragment(){
	vec2 uv=UV*7.4;
	float macro=0.5+0.5*sin(lp.x*0.43+lp.z*0.57+sin(lp.x*0.19)*1.7);
	float dirt_mask=smoothstep(0.54,0.82,macro)*0.42;
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.72,0.75,0.62);
	vec3 dirt=texture(dirt_diff,uv*0.83).rgb*vec3(0.72,0.68,0.58);
	vec3 garm=texture(grass_arm,uv).rgb;
	vec3 darm=texture(dirt_arm,uv*0.83).rgb;
	ALBEDO=mix(grass,dirt,dirt_mask);
	NORMAL_MAP=mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.83).rgb,dirt_mask);
	NORMAL_MAP_DEPTH=0.74;
	ROUGHNESS=clamp(mix(garm.g,darm.g,dirt_mask),0.58,0.97);
	AO=clamp(mix(garm.r,darm.r,dirt_mask),0.72,1.0);
	SPECULAR=0.23;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/grass_path_3_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/grass_path_3_nor_gl_1k.png"))
	mat.set_shader_parameter("grass_arm",load("res://assets/golden_scene/pbr/grass_path_3_arm_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
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
				var texture_path: String = standard.albedo_texture.resource_path if standard.albedo_texture != null else ""
				print("FRONTLINE_HOUSE_V3_SURFACE mesh=%s surface=%s material=%s texture=%s" % [mi.name,mi.mesh.surface_get_name(surface),standard.resource_name,texture_path])
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


func _house_authored_surface_v3(source: StandardMaterial3D,y_bounds: Vector2) -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D base_tex : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);
uniform float base_roughness = 0.7;
uniform float base_metallic = 0.0;
uniform float world_y_min = 0.0;
uniform float world_y_span = 1.0;
uniform sampler2D concrete_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D concrete_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D concrete_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D brick_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D brick_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D brick_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
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
	vec2 wall_uv=(abs(wn.x)>abs(wn.z) ? wp.zy : wp.xy)*0.54;
	float luma=dot(tex.rgb,vec3(0.2126,0.7152,0.0722));
	float hi=max(tex.r,max(tex.g,tex.b));
	float lo=min(tex.r,min(tex.g,tex.b));
	float chroma=hi-lo;
	float neutral=smoothstep(0.48,0.72,luma)*(1.0-smoothstep(0.07,0.17,chroma))*vertical;
	float warm=smoothstep(0.06,0.20,tex.r-tex.b)*smoothstep(0.08,0.28,chroma)*vertical*(1.0-neutral);
	float dark=1.0-smoothstep(0.08,0.25,luma);
	vec3 c_diff=texture(concrete_diff,wall_uv).rgb*vec3(0.92,0.91,0.88);
	vec3 c_nor=texture(concrete_nor,wall_uv).rgb;
	vec3 c_arm=texture(concrete_arm,wall_uv).rgb;
	vec3 b_diff=texture(brick_diff,wall_uv*0.86).rgb*vec3(0.91,0.82,0.72);
	vec3 b_nor=texture(brick_nor,wall_uv*0.86).rgb;
	vec3 b_arm=texture(brick_arm,wall_uv*0.86).rgb;
	float concrete_mix=neutral*0.78;
	float brick_mix=warm*0.54;
	vec3 base=mix(tex.rgb,c_diff,concrete_mix);
	base=mix(base,b_diff,brick_mix);
	float lower=(1.0-smoothstep(0.055,0.24,h))*vertical*(1.0-dark*0.78);
	vec3 mud=texture(mud_diff,wall_uv*0.72+vec2(0.31,0.17)).rgb*vec3(0.52,0.45,0.34);
	float stain=lower*(0.10+0.16*(0.5+0.5*sin(wp.x*2.9+wp.z*3.7)));
	base=mix(base,mud,stain);
	vec3 pbr_nor=mix(vec3(0.5,0.5,1.0),c_nor,concrete_mix);
	pbr_nor=mix(pbr_nor,b_nor,brick_mix);
	ALBEDO=base;
	NORMAL_MAP=pbr_nor;
	NORMAL_MAP_DEPTH=0.66;
	float rough=mix(base_roughness,c_arm.g,concrete_mix);
	rough=mix(rough,b_arm.g,brick_mix);
	ROUGHNESS=clamp(rough+stain*0.12-dark*0.20,0.28,0.96);
	METALLIC=clamp(base_metallic*(1.0-concrete_mix)*(1.0-brick_mix),0.0,0.18);
	float ao=mix(1.0,c_arm.r,concrete_mix);
	ao=mix(ao,b_arm.r,brick_mix);
	AO=clamp(ao,0.68,1.0);
	SPECULAR=0.28+dark*0.13;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("base_tex",source.albedo_texture)
	mat.set_shader_parameter("base_color",source.albedo_color)
	mat.set_shader_parameter("uv_scale",Vector2(source.uv1_scale.x,source.uv1_scale.y))
	mat.set_shader_parameter("uv_offset",Vector2(source.uv1_offset.x,source.uv1_offset.y))
	mat.set_shader_parameter("base_roughness",source.roughness)
	mat.set_shader_parameter("base_metallic",source.metallic)
	mat.set_shader_parameter("world_y_min",y_bounds.x)
	mat.set_shader_parameter("world_y_span",maxf(y_bounds.y-y_bounds.x,0.001))
	mat.set_shader_parameter("concrete_diff",load("res://assets/golden_scene/pbr/t_concrete_wall_002_diff_1k.png"))
	mat.set_shader_parameter("concrete_nor",load("res://assets/golden_scene/pbr/t_concrete_wall_002_nor_gl_1k.png"))
	mat.set_shader_parameter("concrete_arm",load("res://assets/golden_scene/pbr/t_concrete_wall_002_arm_1k.png"))
	mat.set_shader_parameter("brick_diff",load("res://assets/golden_scene/pbr/brick_wall_005_diff_1k.png"))
	mat.set_shader_parameter("brick_nor",load("res://assets/golden_scene/pbr/brick_wall_005_nor_gl_1k.png"))
	mat.set_shader_parameter("brick_arm",load("res://assets/golden_scene/pbr/brick_wall_005_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	return mat


func _add_house_debris_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-3.10,0.03,4.60),Vector3(-2.55,0.03,4.82),Vector3(3.12,0.03,4.44)
	]
	for i: int in range(offsets.size()):
		var path: String = ROCK_SMALL if i%2 == 0 else ROCK_LARGE
		_spawn_pbr_rock_v3(path,center+offsets[i],0.28+0.045*float(i),17.0+41.0*float(i),"HouseRubbleV3_%02d" % i)


func _build_abrams_proof() -> void:
	var center: Vector3 = Vector3(45,0,0)
	_add_pad(center,Vector2(19,19))
	abrams_root = _spawn_scaled(ABRAMS_STATIC,center,8.6,-18.0,"MaterialProofAbramsV3")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_abrams_by_wheels(abrams_root,0.045)

	var inspection_fill: OmniLight3D = OmniLight3D.new()
	inspection_fill.name = "AbramsMaterialInspectionFill"
	inspection_fill.position = center+Vector3(5.8,4.6,7.8)
	inspection_fill.light_color = Color(0.78,0.84,0.92)
	inspection_fill.light_energy = 2.8
	inspection_fill.omni_range = 19.0
	inspection_fill.shadow_enabled = false
	add_child(inspection_fill)

	var side_fill: OmniLight3D = OmniLight3D.new()
	side_fill.name = "AbramsSideMaterialFill"
	side_fill.position = center+Vector3(7.4,2.8,-1.5)
	side_fill.light_color = Color(0.88,0.91,0.86)
	side_fill.light_energy = 4.4
	side_fill.omni_range = 16.0
	side_fill.shadow_enabled = false
	add_child(side_fill)

	var hull: ShaderMaterial = _vehicle_hull_shader_v3()
	var side_skirt: ShaderMaterial = hull.duplicate() as ShaderMaterial
	side_skirt.set_shader_parameter("panel_variant",0.34)
	side_skirt.set_shader_parameter("panel_dust",0.92)
	side_skirt.set_shader_parameter("side_skirt_factor",1.0)
	var track: StandardMaterial3D = _track_material_v3()
	var rubber: StandardMaterial3D = _rubber_material_v3()
	var gun: StandardMaterial3D = _gun_material_v3()
	var optics: StandardMaterial3D = _optics_material()
	var layered_count: int = 0
	var body_index: int = 0

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
			elif key.contains("track") or key.contains("sprocket") or key.contains("idler") or key.contains("towcable"):
				chosen = track
			elif key.contains("barrel") or key.contains("gun"):
				chosen = gun
			elif key.contains("guide") or key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif source == null or source_name.is_empty():
				chosen = track
			elif key.contains("material.001"):
				chosen = side_skirt
			elif key.contains("nukclearsign"):
				apply_override = false
			elif key.contains("exhaust"):
				chosen = track
			elif key.contains("body"):
				var panel: ShaderMaterial = hull.duplicate() as ShaderMaterial
				var panel_variant: float = 0.42+0.20*float((body_index*37)%101)/100.0
				var panel_dust: float = 0.24+0.56*float((body_index*23+17)%89)/88.0
				panel.set_shader_parameter("panel_variant",panel_variant)
				panel.set_shader_parameter("panel_dust",panel_dust)
				chosen = panel
				body_index += 1
			if apply_override:
				mi.set_surface_override_material(surface,chosen)
				layered_count += 1
			print("FRONTLINE_MATERIAL_V3_SURFACE key=%s class=%s override=%s" % [key,chosen.get_class(),str(apply_override)])
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_ruts(center,-18.0)
	_add_vehicle_context_v3(center)


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform float panel_variant = 0.5;
uniform float panel_dust = 0.5;
uniform float side_skirt_factor = 0.0;
varying vec3 wp;
varying vec3 wn;
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec2 uv=UV*3.2;
	vec3 weights=pow(abs(wn),vec3(4.0));
	weights/=max(weights.x+weights.y+weights.z,0.001);
	vec3 d_yz=texture(dirt_diff,wp.yz*0.82).rgb;
	vec3 d_xz=texture(dirt_diff,wp.xz*0.82).rgb;
	vec3 d_xy=texture(dirt_diff,wp.xy*0.82).rgb;
	vec3 d_diff=d_yz*weights.x+d_xz*weights.y+d_xy*weights.z;
	vec3 a_yz=texture(dirt_arm,wp.yz*0.82).rgb;
	vec3 a_xz=texture(dirt_arm,wp.xz*0.82).rgb;
	vec3 a_xy=texture(dirt_arm,wp.xy*0.82).rgb;
	vec3 d_arm=a_yz*weights.x+a_xz*weights.y+a_xy*weights.z;
	vec3 d_nor=texture(dirt_nor,uv).rgb;
	vec3 m_diff=texture(mud_diff,wp.xz*0.68+vec2(0.17,0.09)).rgb;
	vec3 m_nor=texture(mud_nor,uv*0.78+vec2(0.17,0.09)).rgb;
	vec3 m_arm=texture(mud_arm,wp.xz*0.68+vec2(0.17,0.09)).rgb;
	float tex_luma=dot(d_diff,vec3(0.2126,0.7152,0.0722));
	float macro=0.5+0.5*sin(wp.x*0.61+wp.z*0.49+sin(wp.y*0.43)*1.7);
	float vertical=clamp(1.0-abs(wn.y),0.0,1.0);
	float low=1.0-smoothstep(0.42,1.38,wp.y);
	float paint_break=smoothstep(0.42,0.68,tex_luma+0.13*sin(wp.x*1.07-wp.z*0.91+wp.y*0.73));
	float dry_patch=smoothstep(0.24,0.68,1.0-tex_luma)*(0.23+0.28*macro);
	float splash=low*smoothstep(0.30,0.66,1.0-tex_luma)*(0.22+0.26*panel_dust);
	float face_dust=vertical*(0.06+0.20*(1.0-tex_luma))*(0.45+0.55*panel_dust);
	float grime=clamp(low*(0.26+0.40*(1.0-tex_luma))+dry_patch*0.28+splash+face_dust+side_skirt_factor*0.16,0.0,0.74);
	vec3 olive_dark=vec3(0.075,0.094,0.031);
	vec3 olive_mid=vec3(0.135,0.148,0.046);
	vec3 olive_light=vec3(0.190,0.185,0.070);
	vec3 olive=mix(olive_dark,olive_mid,macro*0.70);
	olive=mix(olive,olive_light,paint_break*0.30);
	olive*=mix(0.78,1.18,panel_variant);
	olive*=mix(0.64,1.23,tex_luma);
	vec3 dust=vec3(0.255,0.205,0.118)*mix(0.76,1.24,1.0-tex_luma);
	vec3 dry_mud=m_diff*vec3(0.66,0.53,0.36);
	vec3 base=mix(olive,dust,clamp(dry_patch*0.60+panel_dust*0.075+side_skirt_factor*0.08+face_dust*0.42,0.0,0.52));
	base=mix(base,dry_mud,grime*0.82);
	base=mix(base,dust,face_dust*0.24);
	float fleck=0.5+0.5*sin(wp.x*23.0-wp.z*19.0+wp.y*17.0);
	float wear=(1.0-low)*smoothstep(0.92,0.995,fleck)*0.10;
	ALBEDO=base+vec3(0.085,0.080,0.055)*wear;
	NORMAL_MAP=mix(d_nor,m_nor,clamp(grime*1.18,0.0,0.70));
	NORMAL_MAP_DEPTH=0.80;
	METALLIC=0.025+wear*0.46;
	float rough=mix(clamp(0.50+d_arm.g*0.38,0.50,0.90),clamp(0.68+m_arm.g*0.27,0.68,0.97),grime);
	ROUGHNESS=clamp(rough+dry_patch*0.15+face_dust*0.18+side_skirt_factor*0.08-wear*0.25,0.44,0.98);
	AO=clamp(mix(d_arm.r,m_arm.r,grime),0.68,1.0);
	SPECULAR=0.31;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	return mat


func _track_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.145,0.128,0.098)
	mat.metallic = 0.44
	mat.metallic_specular = 0.42
	mat.roughness = 0.68
	return mat


func _rubber_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.046,0.047,0.041)
	mat.metallic = 0.0
	mat.roughness = 0.88
	return mat


func _gun_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.105,0.120,0.048)
	mat.metallic = 0.08
	mat.metallic_specular = 0.33
	mat.roughness = 0.58
	return mat


func _add_vehicle_context_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-4.8,0,-3.4),Vector3(-4.1,0,2.8),Vector3(4.5,0,-3.2),Vector3(4.2,0,3.1),
		Vector3(-2.8,0,4.4),Vector3(3.1,0,4.3)
	]
	for i: int in range(offsets.size()):
		var path: String = GRASS if i%2 == 0 else WEED
		_spawn_scaled(path,center+offsets[i],0.82+0.12*float(i%3),23.0+47.0*float(i),"VehiclePlantV3_%02d" % i)
	for i: int in range(5):
		var a: float = 0.67+float(i)*1.17
		var rr: float = 4.1+0.28*float(i%2)
		var p: Vector3 = center+Vector3(cos(a)*rr,0.02,sin(a)*rr)
		var rock_path: String = ROCK_SMALL if i%2 == 0 else ROCK_LARGE
		_spawn_pbr_rock_v3(rock_path,p,0.20+0.035*float(i%3),31.0*float(i),"VehicleRockV3_%02d" % i)


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
		var width: float = (0.145+0.030*sin(float(i)*0.91+1.2))*sin(PI*t)
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
	mat.albedo_color = Color(0.78,0.72,0.61)
	mat.roughness = 0.92
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
	_add_ground_scattered_grass_v3(center)
	_add_ground_hq_micro_v3(center)
	proof_checks["ground_microgeometry"] = true


func _ground_proof_shader_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
float track_mask(vec2 p){
	float c1=-1.24+0.10*sin(p.y*0.82);
	float c2= 1.24+0.09*sin(p.y*0.77+1.2);
	float a=1.0-smoothstep(0.11,0.31,abs(p.x-c1));
	float b=1.0-smoothstep(0.11,0.31,abs(p.x-c2));
	float ends=1.0-smoothstep(3.65,4.62,abs(p.y));
	return max(a,b)*ends;
}
void vertex(){
	vec2 p=VERTEX.xz;
	float rut=track_mask(p);
	float churn=(1.0-smoothstep(0.68,2.10,length(p-vec2(0.48,0.38))))*(0.48+0.34*sin(p.x*3.2+p.y*2.5));
	float micro=0.020*sin(p.x*1.73)+0.015*cos(p.y*2.31)+0.008*sin((p.x+p.y)*4.9);
	VERTEX.y += micro-0.032*pow(rut,1.55)-0.010*churn;
	lp=vec3(p.x,VERTEX.y,p.y);
}
void fragment(){
	vec2 p=lp.xz;
	vec2 uv=UV*8.1;
	float n1=0.5+0.5*sin(p.x*0.67+p.y*0.49+sin(p.y*0.37)*1.5);
	float n2=0.5+0.5*sin(p.x*1.57-p.y*1.29+sin(p.x*0.71));
	float grass_island=smoothstep(0.60,0.88,0.5+0.5*sin(p.x*0.57-p.y*0.49+sin(p.x*0.31)*1.4));\n\tfloat dirt_mask=clamp(0.12+0.36*n1+0.16*n2-grass_island*0.23,0.0,0.62);
	float gravel_mask=smoothstep(0.72,0.92,0.5+0.5*sin(p.x*0.91-p.y*0.83+1.4))*0.22;
	float rut=track_mask(p);
	float churn=(1.0-smoothstep(0.72,2.22,length(p-vec2(0.48,0.38))))*(0.45+0.35*n2);
	float ellipse=length(vec2((p.x-1.10)/1.10,(p.y-0.58)/0.52));
	float wet=1.0-smoothstep(0.80+0.05*sin(p.x*4.6+p.y*3.8),1.05,ellipse);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.68,0.82,0.48);
	vec3 dirt=texture(dirt_diff,uv*0.88).rgb*vec3(0.74,0.69,0.59);
	vec3 mud=texture(mud_diff,uv*0.79).rgb*vec3(0.67,0.60,0.50);
	vec3 gravel=texture(gravel_diff,uv*0.94).rgb*vec3(0.72,0.70,0.64);
	vec3 garm=texture(grass_arm,uv).rgb;
	vec3 darm=texture(dirt_arm,uv*0.88).rgb;
	vec3 marm=texture(mud_arm,uv*0.79).rgb;
	vec3 rarm=texture(gravel_arm,uv*0.94).rgb;
	float mud_mix=clamp(rut*0.34+churn*0.24+wet*0.12,0.0,0.52);
	vec3 base=mix(grass,dirt,dirt_mask);
	base=mix(base,gravel,gravel_mask);
	base=mix(base,mud,mud_mix);
	base=mix(base,base*vec3(0.78,0.81,0.82),wet*0.08);
	vec3 nrm=mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.88).rgb,dirt_mask);
	nrm=mix(nrm,texture(gravel_nor,uv*0.94).rgb,gravel_mask);
	nrm=mix(nrm,texture(mud_nor,uv*0.79).rgb,mud_mix);
	float rough=mix(garm.g,darm.g,dirt_mask);
	rough=mix(rough,rarm.g,gravel_mask);
	rough=mix(rough,marm.g,mud_mix);
	float ao=mix(garm.r,darm.r,dirt_mask);
	ao=mix(ao,rarm.r,gravel_mask);
	ao=mix(ao,marm.r,mud_mix);
	ALBEDO=base;
	NORMAL_MAP=nrm;
	NORMAL_MAP_DEPTH=0.82;
	ROUGHNESS=clamp(mix(rough,0.20,wet*0.58),0.20,0.98);
	AO=clamp(ao,0.68,1.0);
	SPECULAR=0.23+wet*0.24;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("grass_arm",load("res://assets/golden_scene/pbr/leafy_grass_arm_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	mat.set_shader_parameter("gravel_diff",load("res://assets/golden_scene/pbr/gravel_ground_01_diff_1k.png"))
	mat.set_shader_parameter("gravel_nor",load("res://assets/golden_scene/pbr/gravel_ground_01_nor_gl_1k.png"))
	mat.set_shader_parameter("gravel_arm",load("res://assets/golden_scene/pbr/gravel_ground_01_arm_1k.png"))
	return mat


func _add_ground_natural_clumps_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-3.75,0,-3.10),Vector3(-2.55,0,-2.20),Vector3(-3.35,0,1.55),Vector3(-1.95,0,3.45),
		Vector3(3.55,0,-3.25),Vector3(2.72,0,-1.55),Vector3(3.62,0,1.72),Vector3(2.20,0,3.52),
		Vector3(-0.55,0,-3.82),Vector3(0.68,0,3.72),Vector3(-3.92,0,-0.40),Vector3(3.90,0,0.28),
		Vector3(-1.45,0,-3.25),Vector3(1.62,0,-2.95),Vector3(-2.75,0,2.55),Vector3(2.95,0,2.62)
	]
	for i: int in range(offsets.size()):
		var path: String = GRASS if i%3 != 0 else WEED
		var target: float = 1.18+0.16*float(i%4)
		var plant: Node3D = _spawn_scaled(path,center+offsets[i],target,17.0+37.0*float(i),"GroundPlantV3_%02d" % i)


func _add_ground_scattered_grass_v3(center: Vector3) -> void:
	var offsets: Array[Vector3] = [
		Vector3(-2.95,0,-3.55),Vector3(-2.10,0,-2.85),Vector3(-1.20,0,-2.10),Vector3(0.15,0,-3.55),
		Vector3(1.05,0,-2.60),Vector3(2.05,0,-3.45),Vector3(3.10,0,-2.35),Vector3(-3.45,0,0.72),
		Vector3(-2.30,0,1.65),Vector3(-1.05,0,2.65),Vector3(0.10,0,3.35),Vector3(1.45,0,2.55),
		Vector3(2.55,0,3.35),Vector3(3.35,0,0.82)
	]
	for i: int in range(offsets.size()):
		var plant: Node3D = _spawn_scaled(GRASS,center+offsets[i],0.72+0.08*float(i%3),11.0+53.0*float(i),"GroundSmallGrassV3_%02d" % i)
		if plant != null:
			_ground_visual_to(plant,0.018)


func _add_ground_hq_micro_v3(center: Vector3) -> void:
	var rock_offsets: Array[Vector3] = [
		Vector3(-3.15,0.02,-1.55),Vector3(-2.15,0.02,0.92),Vector3(-0.82,0.02,2.85),
		Vector3(1.75,0.02,-2.18),Vector3(2.82,0.02,1.72),Vector3(3.42,0.02,-0.58),
		Vector3(-3.62,0.02,2.45),Vector3(0.35,0.02,-3.25)
	]
	for i: int in range(rock_offsets.size()):
		var path: String = ROCK_SMALL if i%2 == 0 else ROCK_LARGE
		_spawn_pbr_rock_v3(path,center+rock_offsets[i],0.16+0.035*float(i%3),29.0+43.0*float(i),"GroundPBRRockV3_%02d" % i)


func _spawn_pbr_rock_v3(path: String,pos: Vector3,target_size: float,yaw: float,name_value: String) -> Node3D:
	var rock: Node3D = _spawn_scaled(path,pos,target_size,yaw,name_value)
	if rock == null:
		return null
	var material: ShaderMaterial = _pbr_gravel_rock_material_v3()
	for mi: MeshInstance3D in _collect_meshes(rock):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			mi.set_surface_override_material(surface,material)
	_ground_visual_to(rock,pos.y+0.006)
	return rock


func _pbr_gravel_rock_material_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D gravel_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_arm : repeat_enable, filter_linear_mipmap_anisotropic;
void fragment(){
	vec2 uv=UV*2.3;
	vec3 diff=texture(gravel_diff,uv).rgb*vec3(0.76,0.73,0.66);
	vec3 arm=texture(gravel_arm,uv).rgb;
	ALBEDO=diff;
	NORMAL_MAP=texture(gravel_nor,uv).rgb;
	NORMAL_MAP_DEPTH=0.86;
	ROUGHNESS=clamp(0.76+arm.g*0.21,0.74,0.97);
	AO=clamp(arm.r,0.68,1.0);
	SPECULAR=0.22;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("gravel_diff",load("res://assets/golden_scene/pbr/gravel_ground_01_diff_1k.png"))
	mat.set_shader_parameter("gravel_nor",load("res://assets/golden_scene/pbr/gravel_ground_01_nor_gl_1k.png"))
	mat.set_shader_parameter("gravel_arm",load("res://assets/golden_scene/pbr/gravel_ground_01_arm_1k.png"))
	return mat


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
	await _capture_view(HOUSE_SHOT_V2,Vector3(10.2,5.25,12.2),Vector3(0,2.20,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(51.8,2.75,6.8),Vector3(45,1.10,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(93.5,3.85,5.1),Vector3(90,0.05,0))
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
