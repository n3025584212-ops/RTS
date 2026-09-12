extends Node3D
## FRONTLINE_REFERENCE_REGION_01
## One coherent world cell. Terrain, river, roads, infrastructure, settlement and vegetation
## share the same world-space height functions; no authored north/central/south route topology.

const OUT := "res://artifacts/reference_region_01"
const ASSET := "res://assets/visual_slice/"
const SURF := "res://assets/visual_slice/surfaces/"
const GOLDEN_PBR := "res://assets/golden_scene/pbr/"
const FAMILY := "res://assets/golden_scene/city_v20/"
const INFRA := "res://scenes/production/infrastructure/"
const COVER_FIELD = preload("res://assets/visual_slice/profiles/groundcover_field.tres")

const WORLD_HALF := 300.0
const TERRAIN_STEP := 4.0
const WATER_Y := -2.2
const BRIDGE_Z := 36.0
const BRIDGE_X := -25.0
const BRIDGE_ROAD_Y := 3.35

var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()
var detail_noise := FastNoiseLite.new()
var camera: Camera3D
var materials: Dictionary = {}
var scene_cache: Dictionary = {}
var capture_pending := false
var capture_frame := 12
var capture_view := "overview"
var frame_count := 0

var building_count := 0
var tree_count := 0
var shrub_count := 0
var road_segment_count := 0
var infrastructure_count := 0
var field_count := 0
var prop_count := 0

var used_assets: Array[String] = []
var infrastructure_counts: Dictionary = {}


func _ready() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-frame="):
			capture_frame = maxi(1, int(argument.get_slice("=", 1)))
		elif argument.begins_with("--view="):
			capture_view = argument.get_slice("=", 1).validate_filename()
	capture_pending = "--capture" in OS.get_cmdline_user_args()

	rng.seed = 20260912
	noise.seed = 70031
	noise.frequency = 0.008
	noise.fractal_octaves = 4
	detail_noise.seed = 8177
	detail_noise.frequency = 0.026
	detail_noise.fractal_octaves = 3
	COVER_FIELD.build()

	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_viewport().msaa_3d = Viewport.MSAA_4X
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	get_viewport().scaling_3d_scale = 1.25

	_setup_lighting()
	_build_materials()
	_create_terrain()
	_create_landuse_fields()
	_create_river()
	_create_road_network()
	_create_bridge_and_drainage()
	_create_village()
	_create_storage_node()
	_create_vegetation()
	_create_reference_vehicle()
	_configure_camera()

	print("FRONTLINE_REFERENCE_REGION_READY world_m=600x600 river=MEANDERING road_network=NATURAL bridge=V2 village_buildings=", building_count,
		" fields=", field_count, " infrastructure=", infrastructure_count, " trees=", tree_count,
		" three_lane_authoring=NO visual_acceptance=NOT_CLAIMED renderer=", RenderingServer.get_current_rendering_method())
	set_process(capture_pending)


func _process(_delta: float) -> void:
	frame_count += 1
	if capture_pending and frame_count >= capture_frame:
		capture_pending = false
		_capture_viewport()


func _setup_lighting() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = load("res://scripts/production/visual_slice_sky.gdshader")
	sky_material.set_shader_parameter("panorama", load(ASSET + "sky.hdr"))
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.59, 0.66, 0.76)
	env.ambient_light_energy = 0.48
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.96
	env.ssao_enabled = true
	env.ssao_radius = 2.0
	env.ssao_intensity = 1.65
	env.ssil_enabled = true
	env.ssil_radius = 3.0
	env.ssil_intensity = 0.42
	env.ssr_enabled = true
	env.ssr_max_steps = 40
	env.fog_enabled = true
	env.fog_light_color = Color(0.59, 0.64, 0.68)
	env.fog_light_energy = 0.7
	env.fog_density = 0.00125
	env.fog_sky_affect = 0.12
	env.fog_height = 6.0
	env.fog_height_density = 0.0025

	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-33.0, 48.0, 0.0)
	sun.light_color = Color(1.0, 0.88, 0.72)
	sun.light_energy = 1.65
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 420.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.shadow_bias = 0.03
	sun.shadow_normal_bias = 0.32
	add_child(sun)

	camera = Camera3D.new()
	camera.name = "ReferenceRegionCamera"
	camera.near = 0.25
	camera.far = 1400.0
	camera.current = true
	add_child(camera)


func _build_materials() -> void:
	var terrain := ShaderMaterial.new()
	terrain.shader = load("res://scripts/production/visual_slice_terrain.gdshader")
	for pair in [
		["grass_color", "leafy_grass_diff"],
		["soil_color", "aerial_mud_1_diff"],
		["soil_normal", "aerial_mud_1_nor_gl"],
		["gravel_color", "gravel_ground_01_diff"],
		["asphalt_color", "asphalt_02_diff"],
	]:
		terrain.set_shader_parameter(pair[0], load(SURF + pair[1] + ".jpg"))
	terrain.set_shader_parameter("soil_roughness", load(SURF + "aerial_mud_1_rough.png"))
	terrain.set_shader_parameter("soil_height", load(SURF + "aerial_mud_1_disp.png"))
	terrain.set_shader_parameter("bare_color", load(SURF + "dirt_aerial_03_diff.jpg"))
	terrain.set_shader_parameter("cover_field", COVER_FIELD.texture)
	terrain.set_shader_parameter("cover_origin", COVER_FIELD.origin)
	terrain.set_shader_parameter("cover_extent", COVER_FIELD.extent)
	materials["terrain"] = terrain

	materials["asphalt"] = _pbr(SURF + "asphalt_02_diff.jpg", SURF + "asphalt_02_nor_gl.jpg", Color(0.66, 0.66, 0.64), 0.88, 0.20)
	materials["gravel"] = _pbr(GOLDEN_PBR + "gravel_ground_01_diff_1k.png", GOLDEN_PBR + "gravel_ground_01_nor_gl_1k.png", Color(0.72, 0.69, 0.62), 0.94, 0.20)
	materials["field"] = _pbr(GOLDEN_PBR + "dirt_aerial_03_diff_1k.png", GOLDEN_PBR + "dirt_aerial_03_nor_gl_1k.png", Color(0.68, 0.62, 0.48), 0.96, 0.12)
	materials["yard"] = _pbr(GOLDEN_PBR + "gravel_ground_01_diff_1k.png", GOLDEN_PBR + "gravel_ground_01_nor_gl_1k.png", Color(0.61, 0.59, 0.54), 0.95, 0.28)
	materials["wood"] = _simple(Color(0.19, 0.145, 0.095), 0.87, 0.0)
	materials["metal"] = _simple(Color(0.18, 0.19, 0.18), 0.68, 0.55)

	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	materials["water"] = water


func _pbr(diffuse_path: String, normal_path: String, tint: Color, roughness: float, uv_scale: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(diffuse_path)
	material.albedo_color = tint
	material.normal_enabled = true
	material.normal_texture = load(normal_path)
	material.normal_scale = 0.68
	material.roughness = roughness
	material.metallic_specular = 0.18
	material.uv1_triplanar = true
	material.uv1_scale = Vector3.ONE * uv_scale
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _simple(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material.metallic_specular = 0.25
	return material


func _river_x(z: float) -> float:
	return -28.0 + sin(z * 0.0105) * 42.0 + sin(z * 0.027 + 1.1) * 10.0


func _river_half_width(z: float) -> float:
	return 13.5 + sin(z * 0.017 + 0.8) * 2.2 + sin(z * 0.041) * 1.0


func _natural_height(x: float, z: float) -> float:
	var h := 3.0
	h += noise.get_noise_2d(x, z) * 5.4
	h += detail_noise.get_noise_2d(x, z) * 1.15
	h += sin(x * 0.010 - z * 0.004) * 1.3
	h += smoothstep(150.0, 300.0, absf(x)) * 2.2
	return h


func _river_carved_height(x: float, z: float) -> float:
	var natural := _natural_height(x, z)
	var distance := absf(x - _river_x(z))
	var half_width := _river_half_width(z)
	var floor_y := WATER_Y - 1.45 + detail_noise.get_noise_2d(x * 1.7, z * 1.7) * 0.18
	if distance <= half_width:
		return floor_y
	var t := clampf((distance - half_width) / 48.0, 0.0, 1.0)
	var blend := smoothstep(0.0, 1.0, t)
	var floodplain := natural - (1.0 - blend) * 2.1
	return lerpf(floor_y, floodplain, blend)


func _main_road_z(x: float) -> float:
	var dx := x - BRIDGE_X
	return BRIDGE_Z + sin(dx * 0.008) * 8.0 + sin(dx * 0.021) * 3.0


func _main_road_slope(x: float) -> float:
	var epsilon := 0.5
	return (_main_road_z(x + epsilon) - _main_road_z(x - epsilon)) / (2.0 * epsilon)


func _road_center_height(x: float) -> float:
	var z := _main_road_z(x)
	var natural := _river_carved_height(x, z)
	var approach_t := clampf((92.0 - absf(x - BRIDGE_X)) / 70.0, 0.0, 1.0)
	approach_t = smoothstep(0.0, 1.0, approach_t)
	return lerpf(natural, BRIDGE_ROAD_Y - 0.08, approach_t)


func _height_at(x: float, z: float) -> float:
	var h := _river_carved_height(x, z)
	var bridge_gap := absf(x - BRIDGE_X) < 21.0
	var road_z := _main_road_z(x)
	var road_distance := absf(z - road_z) / sqrt(1.0 + pow(_main_road_slope(x), 2.0))
	if not bridge_gap and road_distance < 9.0:
		var road_blend := 1.0 - smoothstep(3.8, 9.0, road_distance)
		h = lerpf(h, _road_center_height(x), road_blend)
	return h


func _create_terrain() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	var cells := int((WORLD_HALF * 2.0) / TERRAIN_STEP)
	var side := cells + 1

	for iz in range(side):
		var z := -WORLD_HALF + float(iz) * TERRAIN_STEP
		for ix in range(side):
			var x := -WORLD_HALF + float(ix) * TERRAIN_STEP
			var y := _height_at(x, z)
			vertices.append(Vector3(x, y, z))
			var e := 0.45
			normals.append(Vector3(_height_at(x - e, z) - _height_at(x + e, z), e * 2.0, _height_at(x, z - e) - _height_at(x, z + e)).normalized())
			uvs.append(Vector2(x, z))
			tangents.append_array(PackedFloat32Array([1.0, 0.0, 0.0, 1.0]))

	for iz in range(cells):
		for ix in range(cells):
			var a := iz * side + ix
			indices.append_array(PackedInt32Array([a, a + 1, a + side, a + 1, a + side + 1, a + side]))

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TANGENT] = tangents
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var terrain := MeshInstance3D.new()
	terrain.name = "ReferenceRegionTerrain_600m"
	terrain.mesh = mesh
	terrain.material_override = materials["terrain"]
	terrain.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(terrain)


func _create_landuse_fields() -> void:
	var fields: Array[Rect2] = [
		Rect2(Vector2(72, -236), Vector2(92, 92)),
		Rect2(Vector2(174, -248), Vector2(96, 110)),
		Rect2(Vector2(-270, 92), Vector2(105, 112)),
		Rect2(Vector2(-160, 150), Vector2(94, 96)),
	]
	for rect in fields:
		_create_terrain_patch(rect, 8.0, materials["field"], "Farmland_%02d" % field_count)
		field_count += 1


func _create_terrain_patch(rect: Rect2, step: float, material: Material, label: String) -> void:
	var nx := maxi(2, int(rect.size.x / step) + 1)
	var nz := maxi(2, int(rect.size.y / step) + 1)
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for iz in range(nz):
		var vz := float(iz) / float(nz - 1)
		var z := rect.position.y + rect.size.y * vz
		for ix in range(nx):
			var ux := float(ix) / float(nx - 1)
			var x := rect.position.x + rect.size.x * ux
			vertices.append(Vector3(x, _height_at(x, z) + 0.035, z))
			normals.append(Vector3.UP)
			uvs.append(Vector2(ux, vz) * 8.0)
	for iz in range(nz - 1):
		for ix in range(nx - 1):
			var a := iz * nx + ix
			indices.append_array(PackedInt32Array([a, a + nx, a + 1, a + 1, a + nx, a + nx + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var patch := MeshInstance3D.new()
	patch.name = label
	patch.mesh = mesh
	patch.material_override = material
	patch.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(patch)


func _create_river() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 120
	for i in range(segments + 1):
		var z := -WORLD_HALF + float(i) * (WORLD_HALF * 2.0 / float(segments))
		var cx := _river_x(z)
		var width := maxf(8.0, _river_half_width(z) - 1.0)
		for side in [-1.0, 1.0]:
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(float(i) * 0.12, side * 0.5 + 0.5))
			st.add_vertex(Vector3(cx + width * side, WATER_Y, z))
	for i in range(segments):
		var a := i * 2
		for index in [a, a + 2, a + 1, a + 1, a + 2, a + 3]:
			st.add_index(index)
	st.generate_tangents()
	var river := MeshInstance3D.new()
	river.name = "MeanderingRiver"
	river.mesh = st.commit()
	river.material_override = materials["water"]
	river.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	river.layers = 2
	add_child(river)


func _create_road_network() -> void:
	# Main road crosses the river once. It is a geographic road, not a gameplay lane.
	_create_main_road_segment(-WORLD_HALF, BRIDGE_X - 20.0)
	_create_main_road_segment(BRIDGE_X + 20.0, WORLD_HALF)

	var village_road: Array[Vector3] = [
		Vector3(94, 0, _main_road_z(94)),
		Vector3(118, 0, 69),
		Vector3(148, 0, 93),
		Vector3(177, 0, 119),
		Vector3(205, 0, 151),
	]
	_create_polyline_road(village_road, 5.2, "VillageRoad")

	var farm_track: Array[Vector3] = [
		Vector3(-112, 0, _main_road_z(-112)),
		Vector3(-137, 0, 77),
		Vector3(-171, 0, 121),
		Vector3(-209, 0, 166),
	]
	_create_polyline_road(farm_track, 4.4, "FarmTrack", true)


func _create_main_road_segment(x0: float, x1: float) -> void:
	_create_main_strip(x0, x1, 10.0, materials["gravel"], 0.045, "MainRoadShoulder")
	_create_main_strip(x0, x1, 6.4, materials["asphalt"], 0.075, "MainRoadAsphalt")
	road_segment_count += 1


func _create_main_strip(x0: float, x1: float, width: float, material: Material, y_offset: float, label: String) -> void:
	var step := 3.0
	var count := maxi(2, int(absf(x1 - x0) / step) + 1)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(count):
		var t := float(i) / float(count - 1)
		var x := lerpf(x0, x1, t)
		var z := _main_road_z(x)
		var slope := _main_road_slope(x)
		var normal2 := Vector2(-slope, 1.0).normalized()
		for side in [-1.0, 1.0]:
			var px := x + normal2.x * width * 0.5 * side
			var pz := z + normal2.y * width * 0.5 * side
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(x * 0.12, side * 0.5 + 0.5))
			st.add_vertex(Vector3(px, _height_at(px, pz) + y_offset, pz))
	for i in range(count - 1):
		var a := i * 2
		for index in [a, a + 2, a + 1, a + 1, a + 2, a + 3]:
			st.add_index(index)
	st.generate_tangents()
	var road := MeshInstance3D.new()
	road.name = label + "_%02d" % road_segment_count
	road.mesh = st.commit()
	road.material_override = material
	road.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(road)


func _create_polyline_road(points: Array[Vector3], width: float, label: String, dirt: bool = false) -> void:
	var sampled: Array[Vector3] = []
	for segment in range(points.size() - 1):
		var a := points[segment]
		var b := points[segment + 1]
		var distance := Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
		var steps := maxi(2, int(distance / 3.0))
		for i in range(steps):
			var t := float(i) / float(steps)
			var p := a.lerp(b, t)
			p.y = _height_at(p.x, p.z) + 0.07
			sampled.append(p)
	var final_point := points[-1]
	final_point.y = _height_at(final_point.x, final_point.z) + 0.07
	sampled.append(final_point)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(sampled.size()):
		var prev := sampled[maxi(0, i - 1)]
		var next := sampled[mini(sampled.size() - 1, i + 1)]
		var tangent := Vector2(next.x - prev.x, next.z - prev.z).normalized()
		var normal2 := Vector2(-tangent.y, tangent.x)
		for side in [-1.0, 1.0]:
			var p := sampled[i] + Vector3(normal2.x, 0, normal2.y) * width * 0.5 * side
			p.y = _height_at(p.x, p.z) + 0.075
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(float(i) * 0.24, side * 0.5 + 0.5))
			st.add_vertex(p)
	for i in range(sampled.size() - 1):
		var a_index := i * 2
		for index in [a_index, a_index + 2, a_index + 1, a_index + 1, a_index + 2, a_index + 3]:
			st.add_index(index)
	st.generate_tangents()
	var road := MeshInstance3D.new()
	road.name = label
	road.mesh = st.commit()
	road.material_override = materials["field"] if dirt else materials["gravel"]
	road.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(road)
	road_segment_count += 1


func _create_bridge_and_drainage() -> void:
	var deck_center_y := BRIDGE_ROAD_Y - 0.355
	for offset in [-12.0, 0.0, 12.0]:
		_place_infrastructure(INFRA + "BridgeDeckSmall.tscn", Vector3(BRIDGE_X + offset, deck_center_y, BRIDGE_Z), PI * 0.5, "BridgeDeck")
		_place_infrastructure(INFRA + "BridgeRailSteel.tscn", Vector3(BRIDGE_X + offset, deck_center_y + 0.42, BRIDGE_Z - 3.88), PI * 0.5, "BridgeRailNorth")
		_place_infrastructure(INFRA + "BridgeRailSteel.tscn", Vector3(BRIDGE_X + offset, deck_center_y + 0.42, BRIDGE_Z + 3.88), PI * 0.5, "BridgeRailSouth")

	for offset in [-6.0, 6.0]:
		_place_infrastructure(INFRA + "BridgePierConcrete.tscn", Vector3(BRIDGE_X + offset, deck_center_y - 2.95, BRIDGE_Z), PI * 0.5, "BridgePier")

	_place_infrastructure(INFRA + "BridgeAbutmentConcrete.tscn", Vector3(BRIDGE_X - 19.1, deck_center_y - 2.15, BRIDGE_Z), -PI * 0.5, "WestAbutment")
	_place_infrastructure(INFRA + "BridgeAbutmentConcrete.tscn", Vector3(BRIDGE_X + 19.1, deck_center_y - 2.15, BRIDGE_Z), PI * 0.5, "EastAbutment")

	for x in [BRIDGE_X - 27.0, BRIDGE_X + 27.0]:
		for side in [-1.0, 1.0]:
			var z := _main_road_z(x) + side * 3.7
			_place_infrastructure(INFRA + "RoadGuardrailSteel.tscn", Vector3(x, _height_at(x, z) + 0.22, z), PI * 0.5, "ApproachGuardrail")

	for x in [BRIDGE_X - 18.0, BRIDGE_X + 18.0]:
		for z_offset in [-8.5, 8.5]:
			_place_infrastructure(INFRA + "RiverBankRiprap.tscn", Vector3(x, WATER_Y + 1.05, BRIDGE_Z + z_offset), 0.0, "BridgeBankRiprap")

	var culvert_x := 162.0
	var culvert_z := _main_road_z(culvert_x) - 8.5
	_place_infrastructure(INFRA + "CulvertSmall.tscn", Vector3(culvert_x, _height_at(culvert_x, culvert_z) - 0.15, culvert_z), 0.0, "RoadsideCulvert")
	_place_infrastructure(INFRA + "RetainingWallConcrete.tscn", Vector3(BRIDGE_X + 32.0, BRIDGE_ROAD_Y - 1.25, BRIDGE_Z + 7.4), PI * 0.5, "BridgeApproachRetaining")


func _place_infrastructure(path: String, position3: Vector3, yaw: float, label: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Reference region failed to load infrastructure: " + path)
		return null
	var node := packed.instantiate() as Node3D
	node.name = label + "_%02d" % infrastructure_count
	node.position = position3
	node.rotation.y = yaw
	add_child(node)
	infrastructure_count += 1
	infrastructure_counts[path] = int(infrastructure_counts.get(path, 0)) + 1
	_track_asset(path)
	return node


func _create_village() -> void:
	var specs: Array = [
		["family_house_00.glb", Vector3(122, 0, 88), 3.0, -38.0],
		["family_house_01.glb", Vector3(145, 0, 71), 3.0, 132.0],
		["family_house_02.glb", Vector3(162, 0, 110), 3.0, -52.0],
		["family_house_03.glb", Vector3(184, 0, 92), 3.0, 120.0],
		["family_house_04.glb", Vector3(202, 0, 132), 3.0, -64.0],
		["family_house_00.glb", Vector3(222, 0, 109), 3.0, 105.0],
		["family_house_03.glb", Vector3(172, 0, 151), 3.0, 18.0],
		["family_house_01.glb", Vector3(218, 0, 165), 3.0, -22.0],
	]
	for spec in specs:
		var p: Vector3 = spec[1]
		p.y = _height_at(p.x, p.z) - 0.05
		_spawn(FAMILY + String(spec[0]), p, float(spec[2]), float(spec[3]), "VillageHouse")
		building_count += 1

	var ruin_pos := Vector3(113, 0, 126)
	ruin_pos.y = _height_at(ruin_pos.x, ruin_pos.z) - 0.04
	_spawn("res://scenes/production/RiverTownHeroHouseHF.tscn", ruin_pos, 1.02, 28.0, "VillageHeroRuin")
	building_count += 1


func _create_storage_node() -> void:
	var yard_rect := Rect2(Vector2(178, 184), Vector2(82, 58))
	_create_terrain_patch(yard_rect, 5.0, materials["yard"], "StorageYardGround")

	for i in range(12):
		var row := i / 4
		var col := i % 4
		var x := 190.0 + float(col) * 3.2 + rng.randf_range(-0.25, 0.25)
		var z := 198.0 + float(row) * 3.0 + rng.randf_range(-0.2, 0.2)
		_spawn(ASSET + "wooden_military_crate.glb", Vector3(x, _height_at(x, z) + 0.12, z), 1.0, rng.randf_range(-8.0, 8.0), "StorageCrate")
		prop_count += 1

	for i in range(8):
		var x := 224.0 + float(i % 4) * 1.2
		var z := 202.0 + float(i / 4) * 1.35
		_spawn(ASSET + "barrel_03_0.glb", Vector3(x, _height_at(x, z) + 0.02, z), 1.0, rng.randf_range(-20.0, 20.0), "StorageBarrel")
		prop_count += 1

	# A sparse perimeter identifies a functional storage yard without inventing a low-quality hero building.
	for i in range(14):
		var x := 182.0 + float(i) * 5.5
		_add_box(Vector3(x, _height_at(x, 184) + 0.85, 184), Vector3(0.16, 1.7, 0.16), materials["wood"], "YardPost")
		prop_count += 1


func _create_vegetation() -> void:
	# Woodland mass is concentrated on slopes and field boundaries, not evenly scattered noise.
	for i in range(78):
		var x := rng.randf_range(-285.0, -85.0)
		var z := rng.randf_range(-265.0, 20.0)
		if absf(x - _river_x(z)) < _river_half_width(z) + 32.0:
			continue
		if absf(z - _main_road_z(x)) < 13.0:
			continue
		_spawn(ASSET + "island_tree_01_0.glb", Vector3(x, _height_at(x, z), z), rng.randf_range(1.1, 1.75), rng.randf_range(0.0, 360.0), "WoodlandTree")
		tree_count += 1

	for i in range(72):
		var x := rng.randf_range(-275.0, 275.0)
		var z := rng.randf_range(-270.0, 270.0)
		var river_distance := absf(x - _river_x(z))
		if river_distance < _river_half_width(z) + 10.0 or river_distance > _river_half_width(z) + 58.0:
			continue
		_spawn(ASSET + "fir_sapling_medium_0.glb", Vector3(x, _height_at(x, z), z), rng.randf_range(1.0, 1.45), rng.randf_range(0.0, 360.0), "RiverBeltTree")
		tree_count += 1

	for i in range(120):
		var x := rng.randf_range(-270.0, 270.0)
		var z := rng.randf_range(-270.0, 270.0)
		if absf(z - _main_road_z(x)) < 6.5:
			continue
		if x > 100.0 and z > 55.0 and z < 180.0:
			continue
		_spawn(ASSET + "shrub_02_" + str(i % 4) + ".glb", Vector3(x, _height_at(x, z), z), rng.randf_range(0.45, 0.88), rng.randf_range(0.0, 360.0), "Shrub")
		shrub_count += 1


func _create_reference_vehicle() -> void:
	var x := 78.0
	var z := _main_road_z(x)
	_spawn(ASSET + "abrams.glb", Vector3(x, _height_at(x, z) + 0.03, z), 1.0, -84.0, "ApprovedAbramsReference")


func _spawn(path: String, position3: Vector3, scale_value: float, yaw_degrees: float, label: String) -> Node3D:
	if not scene_cache.has(path):
		var resource := load(path)
		if resource == null:
			push_error("Reference region failed to load asset: " + path)
			return null
		scene_cache[path] = resource
	var resource: Resource = scene_cache[path]
	var node: Node3D
	if resource is PackedScene:
		node = (resource as PackedScene).instantiate() as Node3D
	else:
		push_error("Reference region asset is not a PackedScene: " + path)
		return null
	node.name = label
	node.position = position3
	node.rotation_degrees.y = yaw_degrees
	node.scale = Vector3.ONE * scale_value
	add_child(node)
	_track_asset(path)
	return node


func _track_asset(path: String) -> void:
	if not used_assets.has(path):
		used_assets.append(path)


func _add_box(position3: Vector3, size3: Vector3, material: Material, label: String) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size3
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = box
	node.material_override = material
	node.position = position3
	node.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(node)
	return node


func _configure_camera() -> void:
	match capture_view:
		"bridge":
			camera.position = Vector3(BRIDGE_X + 78.0, 36.0, BRIDGE_Z + 76.0)
			camera.look_at(Vector3(BRIDGE_X, 1.2, BRIDGE_Z))
			camera.fov = 47.0
		"village":
			camera.position = Vector3(272.0, 54.0, 214.0)
			camera.look_at(Vector3(166.0, 2.5, 111.0))
			camera.fov = 49.0
		_:
			camera.position = Vector3(258.0, 112.0, 286.0)
			camera.look_at(Vector3(-18.0, -1.0, 28.0))
			camera.fov = 53.0


func _capture_viewport() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	var image := get_viewport().get_texture().get_image()
	var png_path := OUT + "/reference_region_01_" + capture_view + "_1920x1080.png"
	var err := image.save_png(png_path)
	var metrics_path := OUT + "/runtime_metrics_" + capture_view + ".json"
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"capture_view": capture_view,
		"world_extent_m": [600, 600],
		"terrain_step_m": TERRAIN_STEP,
		"river_type": "MEANDERING_CONTINUOUS_RIBBON",
		"river_rectangular_plane": false,
		"road_network_type": "GEOGRAPHIC_NATURAL",
		"three_lane_authoring": false,
		"bridge_source": "INFRASTRUCTURE_V2",
		"infrastructure_instance_count": infrastructure_count,
		"infrastructure_counts": infrastructure_counts,
		"road_segment_count": road_segment_count,
		"building_count": building_count,
		"family_house_source_scale": 3.0,
		"field_count": field_count,
		"tree_count": tree_count,
		"shrub_count": shrub_count,
		"storage_prop_count": prop_count,
		"approved_abrams_retained": true,
		"old_run5_primitive_bridge": false,
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"used_assets": used_assets,
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
	}
	FileAccess.open(metrics_path, FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_REFERENCE_REGION_CAPTURED view=", capture_view, " path=", png_path, " size=", image.get_size(), " error=", err)
	get_tree().quit(err)
