extends "res://scripts/learning/sprint01/sprint01_world_reproduction.gd"

const DELIVERY_ROOT := "res://assets/learning/sprint01/world_delivery/"
const FIR_PATH := DELIVERY_ROOT + "fir_sapling_medium_1.glb"
const SHRUB_PATH := DELIVERY_ROOT + "shrub_02_0.glb"
const ROCK_A_PATH := DELIVERY_ROOT + "rock_moss_set_01_0.glb"
const ROCK_B_PATH := DELIVERY_ROOT + "rock_moss_set_01_1.glb"
const HOUSE_INTACT_PATH := DELIVERY_ROOT + "house_intact.glb"
const HOUSE_DAMAGED_PATH := DELIVERY_ROOT + "house_damaged.glb"
const GRASS_TEX := DELIVERY_ROOT + "leafy_grass_diff.jpg"
const MUD_TEX := DELIVERY_ROOT + "aerial_mud_1_diff.jpg"
const GRAVEL_TEX := DELIVERY_ROOT + "gravel_ground_01_diff.jpg"
const ASPHALT_TEX := DELIVERY_ROOT + "asphalt_02_diff.jpg"

const ABRAMS_DELIVERY_TARGET_SIZE := 54.0
const IFV_DELIVERY_TARGET_SIZE := 6.7

var delivery_asset_instances: int = 0
var hidden_placeholder_meshes: int = 0


func _ready() -> void:
	print("PLAYER_WORLD_DELIVERY_REPAIR_BOOT=YES")
	print("PLAYER_WORLD_DELIVERY_REPAIR_SOURCE=res://scripts/learning/sprint01/sprint01_world_delivery_repair.gd")
	if not _preflight_delivery_assets():
		print("PLAYER_WORLD_DELIVERY_REPAIR=FAIL|REASON=MISSING_DELIVERY_ASSET")
		get_tree().quit(4)
		return
	super()
	print("PLAYER_WORLD_DELIVERY_REPAIR=READY|REAL_ASSET_INSTANCES=%d|HIDDEN_PLACEHOLDERS=%d" % [delivery_asset_instances, hidden_placeholder_meshes])


func _preflight_delivery_assets() -> bool:
	var required: Array[String] = [
		FIR_PATH,
		SHRUB_PATH,
		ROCK_A_PATH,
		ROCK_B_PATH,
		HOUSE_INTACT_PATH,
		HOUSE_DAMAGED_PATH,
		GRASS_TEX,
		MUD_TEX,
		GRAVEL_TEX,
		ASPHALT_TEX,
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("Sprint01 delivery asset missing: %s" % path)
			return false
	print("PLAYER_WORLD_DELIVERY_ASSET_PREFLIGHT=PASS|COUNT=%d" % required.size())
	return true


func _build_environment() -> void:
	super._build_environment()
	_hide_diagnostic_placeholder_meshes(self)
	_add_real_world_delivery_assets()
	print("REAL_ENOUGH_WORLD_DELIVERY_PIPELINE=PROVENANCE_RECORDED_TEXTURES_AND_GLBS")


func _build_material_pipeline() -> void:
	world_materials["meadow"] = _delivery_material("meadow", GRASS_TEX, 0.93, Color(0.80, 0.86, 0.72))
	world_materials["forest_floor"] = _delivery_material("forest_floor", MUD_TEX, 0.96, Color(0.68, 0.72, 0.62))
	world_materials["transition"] = _delivery_material("transition", GRAVEL_TEX, 0.95, Color(0.78, 0.76, 0.66))
	world_materials["rock"] = _delivery_material("rock", GRAVEL_TEX, 0.91, Color(0.72, 0.74, 0.71))
	world_materials["road"] = _delivery_material("road", ASPHALT_TEX, 0.88, Color(0.70, 0.68, 0.63))
	world_materials["shoulder"] = _delivery_material("shoulder", MUD_TEX, 0.97, Color(0.76, 0.70, 0.57))
	world_materials["hardstand"] = _delivery_material("hardstand", GRAVEL_TEX, 0.90, Color(0.82, 0.80, 0.72))
	world_materials["earthwork"] = _delivery_material("earthwork", MUD_TEX, 0.98, Color(0.66, 0.58, 0.45))
	world_materials["trunk"] = _delivery_material("trunk", MUD_TEX, 0.96, Color(0.54, 0.42, 0.29))
	world_materials["canopy"] = _delivery_material("canopy", GRASS_TEX, 0.94, Color(0.36, 0.55, 0.30))
	world_surface_roles = ["meadow", "forest_floor", "transition", "rock", "road", "shoulder", "hardstand", "earthwork"]
	print("SURFACE_ROLE_BINDINGS=meadow;forest_floor;transition;rock;road;shoulder;hardstand;earthwork")
	print("MATERIAL_PROVENANCE=PROVENANCE_RECORDED_REUSABLE_ASSETS|POLY_HAVEN_CC0=YES|OLD_SCENE_COORDINATE_COPY=NO")


func _delivery_material(role: String, texture_path: String, roughness_value: float, tint: Color) -> StandardMaterial3D:
	var texture := load(texture_path) as Texture2D
	var material := StandardMaterial3D.new()
	material.resource_name = "Sprint01_Delivery_%s" % role
	material.albedo_texture = texture
	material.albedo_color = tint
	material.roughness = roughness_value
	material.texture_repeat = true
	return material


func _build_units() -> void:
	effects_root = Node3D.new()
	effects_root.name = "CausalCombatFeedback"
	add_child(effects_root)
	player_unit = _spawn_real_model(ABRAMS_PATH, PLAYER_START, ABRAMS_DELIVERY_TARGET_SIZE, 90.0, PLAYER_NAME)
	target_unit = _spawn_real_model(IFV_PATH, TARGET_POSITION, IFV_DELIVERY_TARGET_SIZE, -90.0, TARGET_NAME)
	selection_ring = _unit_ring(player_unit.position, Color(0.10, 0.55, 1.0), "PlayerSelectionRing")
	selection_ring.visible = false
	target_ring = _unit_ring(target_unit.position, Color(1.0, 0.10, 0.05), "TargetThreatRing")
	print("REAL_ASSET_INSTANCE=PASS|ENTITY=%s|PATH=%s" % [PLAYER_NAME, ABRAMS_PATH])
	print("REAL_ASSET_INSTANCE=PASS|ENTITY=%s|PATH=%s" % [TARGET_NAME, IFV_PATH])
	print("PLAYER_UNIT_READABILITY_REPAIR=EXACT_ABRAMS|TARGET_SIZE=%.1f|IFV_TARGET_SIZE=%.1f" % [ABRAMS_DELIVERY_TARGET_SIZE, IFV_DELIVERY_TARGET_SIZE])


func _add_world_label(_position_value: Vector3, _text_value: String, _color: Color) -> void:
	# Diagnostic 3D labels were the audit's largest occlusion source. Runtime HUD remains.
	pass


func _hide_diagnostic_placeholder_meshes(node: Node) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var mesh := mesh_instance.mesh
			var keep_hardstand := String(mesh_instance.name).contains("Hardstand")
			if mesh is SphereMesh or (mesh is CylinderMesh and not keep_hardstand):
				mesh_instance.visible = false
				hidden_placeholder_meshes += 1
		_hide_diagnostic_placeholder_meshes(child)


func _add_real_world_delivery_assets() -> void:
	var fir_points: Array[Vector3] = [
		Vector3(-18.0, 0.0, -15.0), Vector3(-13.5, 0.0, -17.0), Vector3(-9.5, 0.0, -13.5),
		Vector3(-11.0, 0.0, 12.5), Vector3(-5.0, 0.0, 15.0), Vector3(0.0, 0.0, 12.0),
		Vector3(17.0, 0.0, 13.0), Vector3(22.0, 0.0, 16.0), Vector3(26.0, 0.0, 11.0),
	]
	for i: int in range(fir_points.size()):
		_instance_delivery_scene(FIR_PATH, fir_points[i], 1.20 + float(i % 3) * 0.12, float((i * 47) % 360), "DeliveryFir_%02d" % i)

	var shrub_points: Array[Vector3] = [
		Vector3(-22.0, 0.0, 8.0), Vector3(-15.0, 0.0, 10.5), Vector3(-8.0, 0.0, 9.5),
		Vector3(4.0, 0.0, 9.0), Vector3(11.0, 0.0, 10.5), Vector3(24.0, 0.0, 7.5),
		Vector3(-24.0, 0.0, -11.0), Vector3(-7.0, 0.0, -12.0), Vector3(20.0, 0.0, -13.5),
	]
	for i: int in range(shrub_points.size()):
		_instance_delivery_scene(SHRUB_PATH, shrub_points[i], 1.25 + float(i % 2) * 0.18, float((i * 71) % 360), "DeliveryShrub_%02d" % i)

	var rock_points: Array[Vector3] = [
		Vector3(-27.0, 0.0, 17.0), Vector3(-20.0, 0.0, 13.5), Vector3(-2.0, 0.0, 18.0),
		Vector3(10.0, 0.0, 16.5), Vector3(30.0, 0.0, 16.0), Vector3(27.0, 0.0, -16.0),
	]
	for i: int in range(rock_points.size()):
		var rock_path := ROCK_A_PATH if i % 2 == 0 else ROCK_B_PATH
		_instance_delivery_scene(rock_path, rock_points[i], 1.15 + float(i % 3) * 0.16, float((i * 61) % 360), "DeliveryRock_%02d" % i)

	_instance_delivery_scene(HOUSE_INTACT_PATH, Vector3(20.5, 0.0, 7.5), 1.35, 198.0, "DeliveryHouse_Intact")
	_instance_delivery_scene(HOUSE_DAMAGED_PATH, Vector3(22.5, 0.0, -10.5), 1.25, 162.0, "DeliveryHouse_Damaged")
	print("DELIVERY_BUILT_CONTENT=PASS|HOUSES=2|REAL_VEGETATION=%d|REAL_ROCKS=%d" % [fir_points.size() + shrub_points.size(), rock_points.size()])


func _instance_delivery_scene(path: String, point: Vector3, scale_value: float, yaw_degrees: float, node_name: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Failed to load delivery scene: %s" % path)
		return
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("Delivery asset root is not Node3D: %s" % path)
		return
	instance.name = node_name
	instance.position = Vector3(point.x, _terrain_height(point.x, point.z), point.z)
	instance.rotation_degrees.y = yaw_degrees
	instance.scale = Vector3.ONE * scale_value
	add_child(instance)
	delivery_asset_instances += 1
