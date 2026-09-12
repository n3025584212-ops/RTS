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
}

@export var module_type: ModuleType = ModuleType.BRIDGE_DECK

const SURF := "res://assets/visual_slice/surfaces/"

var materials: Dictionary = {}
var generated_mesh_count: int = 0


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
	print("FRONTLINE_INFRASTRUCTURE_MODULE_READY name=", name, " type=", ModuleType.keys()[module_type], " meshes=", generated_mesh_count)


func _build_materials() -> void:
	materials["concrete"] = _pbr("t_concrete_wall_002_diff.jpg")
	materials["asphalt"] = _pbr("asphalt_02_diff.jpg", "asphalt_02_nor_gl.jpg", "asphalt_02_rough.jpg")
	materials["stone"] = _pbr("rock_boulder_dry_diff.png", "rock_boulder_dry_nor_gl.png", "rock_boulder_dry_rough.png")
	materials["metal"] = _simple(Color(0.105, 0.115, 0.12), 0.53, 0.38)
	materials["dark"] = _simple(Color(0.025, 0.030, 0.032), 0.88, 0.04)


func _pbr(diffuse: String, normal: String = "", roughness: String = "") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(SURF + diffuse)
	if normal != "":
		material.normal_enabled = true
		material.normal_texture = load(SURF + normal)
	if roughness != "":
		material.roughness_texture = load(SURF + roughness)
	material.roughness = 0.78
	material.metallic_specular = 0.16
	material.uv1_triplanar = true
	material.uv1_scale = Vector3(0.22, 0.22, 0.22)
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
		_box("EdgeBeam", Vector3(0.42, 0.62, 12.0), Vector3(x, -0.22, 0.0), "concrete")
	for z in [-4.5, -1.5, 1.5, 4.5]:
		_box("CrossBeam", Vector3(7.75, 0.38, 0.34), Vector3(0.0, -0.53, z), "metal")


func _build_bridge_abutment() -> void:
	_box("BackWall", Vector3(9.7, 3.4, 1.15), Vector3(0.0, 1.15, 0.0), "concrete")
	_box("BearingSeat", Vector3(8.8, 0.62, 2.0), Vector3(0.0, 2.58, -0.20), "concrete")
	_box("Footing", Vector3(10.4, 0.62, 3.25), Vector3(0.0, -0.68, 0.25), "stone")
	_box("WingWallLeft", Vector3(0.56, 2.8, 5.8), Vector3(-4.18, 0.60, 2.55), "concrete", Vector3(0.0, -0.20, 0.0))
	_box("WingWallRight", Vector3(0.56, 2.8, 5.8), Vector3(4.18, 0.60, 2.55), "concrete", Vector3(0.0, 0.20, 0.0))


func _build_bridge_pier() -> void:
	_box("PierFooting", Vector3(5.8, 0.72, 2.7), Vector3(0.0, -2.15, 0.0), "stone")
	_box("PierStem", Vector3(4.3, 4.5, 1.55), Vector3(0.0, 0.0, 0.0), "concrete")
	_box("PierCap", Vector3(8.25, 0.72, 2.05), Vector3(0.0, 2.55, 0.0), "concrete")
	for x in [-2.95, 2.95]:
		_box("BearingBlock", Vector3(0.72, 0.34, 1.28), Vector3(x, 3.03, 0.0), "metal")


func _build_bridge_rail() -> void:
	# One twelve-metre rail segment. Duplicate/rotate on both deck edges.
	for z in [-5.6, -3.6, -1.6, 0.4, 2.4, 4.4, 5.6]:
		_rod("RailPost", Vector3(0.0, 0.0, z), Vector3(0.0, 1.22, z), 0.065, "metal")
	_rod("TopRail", Vector3(0.0, 1.14, -5.85), Vector3(0.0, 1.14, 5.85), 0.075, "metal")
	_rod("MidRail", Vector3(0.0, 0.62, -5.85), Vector3(0.0, 0.62, 5.85), 0.052, "metal")
	_box("ConcreteKerb", Vector3(0.30, 0.28, 11.85), Vector3(0.0, 0.10, 0.0), "concrete")


func _build_retaining_wall() -> void:
	_box("WallFace", Vector3(10.0, 3.2, 0.58), Vector3(0.0, 1.18, 0.0), "concrete")
	_box("WallFooting", Vector3(10.6, 0.55, 2.25), Vector3(0.0, -0.67, 0.45), "stone")
	_box("WallCap", Vector3(10.25, 0.30, 0.86), Vector3(0.0, 2.92, -0.02), "concrete")
	for x in [-4.2, -2.1, 0.0, 2.1, 4.2]:
		_box("Buttress", Vector3(0.34, 2.45, 1.20), Vector3(x, 0.55, 0.55), "concrete")


func _build_culvert() -> void:
	# The headwall is physically split around a real opening; the pipe is a hollow shell.
	_box("HeadwallLeft", Vector3(3.4, 3.1, 0.62), Vector3(-2.65, 0.62, 0.0), "concrete")
	_box("HeadwallRight", Vector3(3.4, 3.1, 0.62), Vector3(2.65, 0.62, 0.0), "concrete")
	_box("HeadwallTop", Vector3(2.35, 0.85, 0.62), Vector3(0.0, 2.10, 0.0), "concrete")
	_box("CulvertApron", Vector3(8.3, 0.34, 3.2), Vector3(0.0, -1.02, 1.26), "stone")
	_box("WingLeft", Vector3(0.46, 2.3, 3.5), Vector3(-4.18, 0.02, 1.38), "concrete", Vector3(0.0, -0.25, 0.0))
	_box("WingRight", Vector3(0.46, 2.3, 3.5), Vector3(4.18, 0.02, 1.38), "concrete", Vector3(0.0, 0.25, 0.0))
	_mesh_instance(_make_pipe_shell(1.08, 1.35, 5.8, 28), materials["concrete"], Vector3(0.0, 0.25, 0.55)).name = "HollowConcretePipe"
	var darkness := CylinderMesh.new()
	darkness.top_radius = 0.94
	darkness.bottom_radius = 0.94
	darkness.height = 0.06
	darkness.radial_segments = 28
	_mesh_instance(darkness, materials["dark"], Vector3(0.0, 0.25, 3.47), Vector3(PI * 0.5, 0.0, 0.0)).name = "PipeInteriorShadow"


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
		# Outer wall.
		_add_quad(st, Vector3(outer0.x, outer0.y, z0), Vector3(outer1.x, outer1.y, z0), Vector3(outer1.x, outer1.y, z1), Vector3(outer0.x, outer0.y, z1))
		# Inner wall, reversed winding.
		_add_quad(st, Vector3(inner1.x, inner1.y, z0), Vector3(inner0.x, inner0.y, z0), Vector3(inner0.x, inner0.y, z1), Vector3(inner1.x, inner1.y, z1))
		# Annular lips at both ends.
		_add_quad(st, Vector3(inner0.x, inner0.y, z0), Vector3(inner1.x, inner1.y, z0), Vector3(outer1.x, outer1.y, z0), Vector3(outer0.x, outer0.y, z0))
		_add_quad(st, Vector3(outer0.x, outer0.y, z1), Vector3(outer1.x, outer1.y, z1), Vector3(inner1.x, inner1.y, z1), Vector3(inner0.x, inner0.y, z1))
	st.generate_normals()
	st.generate_tangents()
	return st.commit()


func _add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for v in [a, b, c, a, c, d]:
		st.set_uv(Vector2(v.x, v.z) * 0.18)
		st.add_vertex(v)
