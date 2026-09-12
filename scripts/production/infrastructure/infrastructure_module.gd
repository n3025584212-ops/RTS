extends Node3D
## Reusable visual infrastructure modules for FRONTLINE world slices.
## Geometry is local to the module so each .tscn can be instanced independently.


enum ModuleType {
	BRIDGE_DECK,
	BRIDGE_ABUTMENT,
	BRIDGE_PIER,
	BRIDGE_RAIL,
	RETAINING_WALL,
	CULVERT,
	ROAD_GUARDRAIL,
	RIPRAP_BANK,
}

@export var module_type: ModuleType = ModuleType.BRIDGE_DECK

const SURF := "res://assets/visual_slice/surfaces/"
const GOLDEN_PBR := "res://assets/golden_scene/pbr/"
const VISUAL_ASSET := "res://assets/visual_slice/"

var materials: Dictionary = {}
var generated_mesh_count: int = 0
var generated_asset_count: int = 0


func _ready() -> void:
	_build_materials()
	match module_type:
		ModuleType.BRIDGE_DECK:
			_build_bridge_deck()
		ModuleType.BRIDGE_ABUTMENT:
			_build_bridge_abutment()
		ModuleType.BRIDGE_PIER:
			_build_bridge_pier()
		ModuleType.BRIDGE_RAIL:
			_build_bridge_rail()
		ModuleType.RETAINING_WALL:
			_build_retaining_wall()
		ModuleType.CULVERT:
			_build_culvert()
		ModuleType.ROAD_GUARDRAIL:
			_build_road_guardrail()
		ModuleType.RIPRAP_BANK:
			_build_riprap_bank()
	print("FRONTLINE_INFRASTRUCTURE_MODULE_READY name=", name, " type=", ModuleType.keys()[module_type],
		" meshes=", generated_mesh_count, " source_assets=", generated_asset_count)


func _build_materials() -> void:
	materials["concrete"] = _pbr_abs(
		GOLDEN_PBR + "t_concrete_wall_002_diff_1k.png",
		GOLDEN_PBR + "t_concrete_wall_002_nor_gl_1k.png",
		Color(0.71, 0.70, 0.66), 0.91, 0.26)
	materials["concrete_dark"] = _pbr_abs(
		GOLDEN_PBR + "t_concrete_wall_002_diff_1k.png",
		GOLDEN_PBR + "t_concrete_wall_002_nor_gl_1k.png",
		Color(0.52, 0.54, 0.51), 0.94, 0.29)
	materials["asphalt"] = _pbr_abs(
		SURF + "asphalt_02_diff.jpg", SURF + "asphalt_02_nor_gl.jpg",
		Color(0.72, 0.72, 0.70), 0.87, 0.30)
	materials["soil"] = _pbr_abs(
		GOLDEN_PBR + "dirt_aerial_03_diff_1k.png",
		GOLDEN_PBR + "dirt_aerial_03_nor_gl_1k.png",
		Color(0.68, 0.63, 0.54), 0.96, 0.24)
	materials["gravel"] = _pbr_abs(
		GOLDEN_PBR + "gravel_ground_01_diff_1k.png",
		GOLDEN_PBR + "gravel_ground_01_nor_gl_1k.png",
		Color(0.68, 0.66, 0.61), 0.94, 0.31)
	materials["stone"] = _pbr_abs(
		SURF + "rock_boulder_dry_diff.png", SURF + "rock_boulder_dry_nor_gl.png",
		Color(0.69, 0.66, 0.57), 0.93, 0.31)
	materials["metal"] = _simple(Color(0.095, 0.105, 0.108), 0.63, 0.42)
	materials["weathered_metal"] = _simple(Color(0.24, 0.255, 0.25), 0.72, 0.47)
	materials["dark"] = _simple(Color(0.020, 0.024, 0.025), 0.91, 0.03)


func _pbr_abs(diffuse_path: String, normal_path: String = "", tint: Color = Color.WHITE,
		roughness: float = 0.82, uv_scale: float = 0.24) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(diffuse_path)
	material.albedo_color = tint
	if normal_path != "":
		material.normal_enabled = true
		material.normal_texture = load(normal_path)
		material.normal_scale = 0.72
	material.roughness = roughness
	material.metallic_specular = 0.15
	material.uv1_triplanar = true
	material.uv1_scale = Vector3.ONE * uv_scale
	return material


func _simple(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material.metallic_specular = 0.35
	return material


func _mesh_instance(mesh: Mesh, material: Material, position3: Vector3, rotation3: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position3
	instance.rotation = rotation3
	instance.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	generated_mesh_count += 1
	return instance


func _box(label: String, size3: Vector3, position3: Vector3, material_key: String, rotation3: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size3
	var instance := _mesh_instance(mesh, materials[material_key], position3, rotation3)
	instance.name = label
	return instance


func _cylinder(label: String, radius: float, height: float, position3: Vector3, material_key: String, sides: int = 18) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	mesh.rings = 2
	var instance := _mesh_instance(mesh, materials[material_key], position3)
	instance.name = label
	return instance


func _rod(label: String, a: Vector3, b: Vector3, radius: float, material_key: String) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = a.distance_to(b)
	mesh.radial_segments = 12
	mesh.rings = 1
	var instance := _mesh_instance(mesh, materials[material_key], (a + b) * 0.5)
	instance.name = label
	instance.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
	return instance


func _build_bridge_deck() -> void:
	# Twelve-metre repeatable span. Longer crossings are assembled from span modules.
	_box("ConcreteDeckSlab", Vector3(8.4, 0.58, 12.0), Vector3(0.0, 0.0, 0.0), "concrete")
	_box("AsphaltWearCourse", Vector3(7.55, 0.13, 11.84), Vector3(0.0, 0.355, 0.0), "asphalt")
	for x in [-3.92, 3.92]:
		_box("EdgeBeam", Vector3(0.42, 0.62, 12.0), Vector3(x, -0.22, 0.0), "concrete_dark")
	for z in [-4.5, -1.5, 1.5, 4.5]:
		_box("CrossBeam", Vector3(7.75, 0.38, 0.34), Vector3(0.0, -0.53, z), "metal")


func _build_bridge_abutment() -> void:
	# V2 deliberately exposes less monolithic concrete and gives terrain something to bury into.
	_box("BackWall", Vector3(9.0, 2.55, 0.78), Vector3(0.0, 0.78, 0.0), "concrete_dark")
	_box("BearingSeat", Vector3(8.5, 0.48, 1.42), Vector3(0.0, 2.16, -0.16), "concrete")
	_box("BuriedFooting", Vector3(9.8, 0.54, 2.75), Vector3(0.0, -0.84, 0.22), "stone")
	_box("WingWallLeft", Vector3(0.46, 2.25, 5.5), Vector3(-3.95, 0.35, 2.28), "concrete_dark", Vector3(0.0, -0.34, 0.0))
	_box("WingWallRight", Vector3(0.46, 2.25, 5.5), Vector3(3.95, 0.35, 2.28), "concrete_dark", Vector3(0.0, 0.34, 0.0))
	_box("GravelContactApron", Vector3(9.1, 0.24, 3.6), Vector3(0.0, -0.92, 1.10), "gravel")


func _build_bridge_pier() -> void:
	# Twin rounded columns remove the V1 rectangular-block silhouette.
	_box("PierFooting", Vector3(5.7, 0.68, 2.65), Vector3(0.0, -2.18, 0.0), "stone")
	for x in [-1.65, 1.65]:
		_cylinder("PierColumn", 0.78, 4.45, Vector3(x, 0.0, 0.0), "concrete_dark", 20)
	_box("PierCap", Vector3(8.1, 0.62, 1.90), Vector3(0.0, 2.48, 0.0), "concrete")
	for x in [-2.85, 2.85]:
		_box("BearingBlock", Vector3(0.68, 0.30, 1.18), Vector3(x, 2.94, 0.0), "metal")


func _build_bridge_rail() -> void:
	for z in [-5.6, -3.6, -1.6, 0.4, 2.4, 4.4, 5.6]:
		_rod("RailPost", Vector3(0.0, 0.0, z), Vector3(0.0, 1.18, z), 0.060, "weathered_metal")
	_rod("TopRail", Vector3(0.0, 1.10, -5.85), Vector3(0.0, 1.10, 5.85), 0.072, "weathered_metal")
	_rod("MidRail", Vector3(0.0, 0.60, -5.85), Vector3(0.0, 0.60, 5.85), 0.050, "weathered_metal")
	_box("ConcreteKerb", Vector3(0.28, 0.26, 11.85), Vector3(0.0, 0.09, 0.0), "concrete_dark")


func _build_retaining_wall() -> void:
	_box("WallFace", Vector3(10.0, 2.65, 0.54), Vector3(0.0, 0.88, 0.0), "concrete_dark")
	_box("BuriedWallFooting", Vector3(10.6, 0.52, 2.10), Vector3(0.0, -0.77, 0.42), "stone")
	_box("WallCap", Vector3(10.15, 0.25, 0.78), Vector3(0.0, 2.32, -0.02), "concrete")
	_box("GravelToe", Vector3(10.3, 0.22, 1.65), Vector3(0.0, -0.58, -0.72), "gravel")
	for x in [-4.1, -2.05, 0.0, 2.05, 4.1]:
		_box("Buttress", Vector3(0.30, 2.05, 1.05), Vector3(x, 0.42, 0.48), "concrete_dark")
	for x in [-3.2, 0.0, 3.2]:
		var drain := CylinderMesh.new()
		drain.top_radius = 0.075
		drain.bottom_radius = 0.075
		drain.height = 0.10
		drain.radial_segments = 10
		_mesh_instance(drain, materials["dark"], Vector3(x, 0.10, -0.32), Vector3(PI * 0.5, 0.0, 0.0)).name = "WallDrain"


func _build_culvert() -> void:
	# V2 road culvert is deliberately smaller than the oversized V1 showcase object.
	_box("HeadwallLeft", Vector3(2.55, 2.15, 0.52), Vector3(-1.92, 0.28, 0.0), "concrete_dark")
	_box("HeadwallRight", Vector3(2.55, 2.15, 0.52), Vector3(1.92, 0.28, 0.0), "concrete_dark")
	_box("HeadwallTop", Vector3(1.55, 0.58, 0.52), Vector3(0.0, 1.48, 0.0), "concrete")
	_box("CulvertApron", Vector3(6.4, 0.26, 2.6), Vector3(0.0, -0.77, 1.08), "gravel")
	_box("WingLeft", Vector3(0.40, 1.65, 3.0), Vector3(-3.12, -0.08, 1.22), "concrete_dark", Vector3(0.0, -0.29, 0.0))
	_box("WingRight", Vector3(0.40, 1.65, 3.0), Vector3(3.12, -0.08, 1.22), "concrete_dark", Vector3(0.0, 0.29, 0.0))
	_mesh_instance(_make_pipe_shell(0.76, 0.94, 5.2, 28), materials["concrete_dark"], Vector3(0.0, 0.04, 0.48)).name = "HollowConcretePipe"
	var darkness := CylinderMesh.new()
	darkness.top_radius = 0.70
	darkness.bottom_radius = 0.70
	darkness.height = 0.05
	darkness.radial_segments = 28
	_mesh_instance(darkness, materials["dark"], Vector3(0.0, 0.04, 3.11), Vector3(PI * 0.5, 0.0, 0.0)).name = "PipeInteriorShadow"
	_box("SoilShoulderLeft", Vector3(2.1, 0.42, 2.6), Vector3(-2.95, -0.60, -0.55), "soil", Vector3(0.0, 0.0, -0.08))
	_box("SoilShoulderRight", Vector3(2.1, 0.42, 2.6), Vector3(2.95, -0.60, -0.55), "soil", Vector3(0.0, 0.0, 0.08))


func _build_road_guardrail() -> void:
	# Ten-metre repeatable roadside W-beam approximation, independent from bridge parapets.
	for z in [-4.6, -2.3, 0.0, 2.3, 4.6]:
		_box("GuardPost", Vector3(0.13, 1.12, 0.13), Vector3(0.0, 0.28, z), "weathered_metal")
	_box("LowerBeam", Vector3(0.16, 0.22, 10.2), Vector3(-0.055, 0.72, 0.0), "weathered_metal", Vector3(0.0, 0.0, 0.035))
	_box("UpperBeam", Vector3(0.16, 0.22, 10.2), Vector3(0.055, 0.91, 0.0), "weathered_metal", Vector3(0.0, 0.0, -0.035))
	_box("GravelShoulder", Vector3(1.1, 0.14, 10.4), Vector3(0.30, -0.33, 0.0), "gravel")


func _build_riprap_bank() -> void:
	# A reusable shore strip built from the same source rocks already proven in Run #5.
	_box("BankGravelBed", Vector3(10.4, 0.24, 4.6), Vector3(0.0, -0.54, 0.0), "gravel", Vector3(0.11, 0.0, 0.0))
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = 240817
	for i in range(42):
		var variant := i % 6
		var path := VISUAL_ASSET + "rock_moss_set_01_" + str(variant) + ".glb"
		var packed := load(path) as PackedScene
		if packed == null:
			push_error("Riprap source failed to load: " + path)
			continue
		var rock := packed.instantiate() as Node3D
		var z := local_rng.randf_range(-2.1, 2.1)
		var x := local_rng.randf_range(-4.9, 4.9)
		var slope_y := -0.10 - (z + 2.1) * 0.12
		rock.position = Vector3(x, slope_y + local_rng.randf_range(-0.08, 0.10), z)
		rock.rotation = Vector3(local_rng.randf_range(-0.18, 0.18), local_rng.randf() * TAU, local_rng.randf_range(-0.20, 0.20))
		var s := local_rng.randf_range(0.18, 0.34)
		rock.scale = Vector3(s * local_rng.randf_range(0.85, 1.22), s, s * local_rng.randf_range(0.85, 1.18))
		add_child(rock)
		generated_asset_count += 1


func _make_pipe_shell(inner_radius: float, outer_radius: float, length: float, segments: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var outer0 := Vector2(cos(a0), sin(a0)) * outer_radius
		var outer1 := Vector2(cos(a1), sin(a1)) * outer_radius
		var inner0 := Vector2(cos(a0), sin(a0)) * inner_radius
		var inner1 := Vector2(cos(a1), sin(a1)) * inner_radius
		var z0 := -length * 0.5
		var z1 := length * 0.5
		_add_quad(st, Vector3(outer0.x, outer0.y, z0), Vector3(outer1.x, outer1.y, z0), Vector3(outer1.x, outer1.y, z1), Vector3(outer0.x, outer0.y, z1))
		_add_quad(st, Vector3(inner1.x, inner1.y, z0), Vector3(inner0.x, inner0.y, z0), Vector3(inner0.x, inner0.y, z1), Vector3(inner1.x, inner1.y, z1))
		_add_quad(st, Vector3(inner0.x, inner0.y, z0), Vector3(inner1.x, inner1.y, z0), Vector3(outer1.x, outer1.y, z0), Vector3(outer0.x, outer0.y, z0))
		_add_quad(st, Vector3(outer0.x, outer0.y, z1), Vector3(outer1.x, outer1.y, z1), Vector3(inner1.x, inner1.y, z1), Vector3(inner0.x, inner0.y, z1))
	st.generate_normals()
	st.generate_tangents()
	return st.commit()


func _add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for v in [a, b, c, a, c, d]:
		st.set_uv(Vector2(v.x, v.z) * 0.18)
		st.add_vertex(v)
