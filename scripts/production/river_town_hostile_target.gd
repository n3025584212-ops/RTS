class_name RiverTownHostileTarget
extends Node3D

## Gate D1 (MINIMUM_COMBAT_CHAIN).
## Static RED armored target for the validated combat chain: a second real
## Abrams GLB with the same armor-shader treatment as the player vehicle,
## red-shifted via the shader's paint_color to read as hostile. Backed by a
## hidden RED BattleFormation so damage uses the validated matrix (TANK vs
## TANK 1.0, 45 dmg/shot, 1.5 s reload, 16 rnd). Paint char progresively with
## damage; no proxy at any point.

const TANK_DEFINITION_PATH := "res://resources/formations/tank.tres"
const TANK_MODEL_PATH := "res://assets/visual_slice/abrams.glb"
const RT_SIM_TO_WORLD := 0.1
const RT_SIM_ORIGIN_WORLD := Vector2(-25.0, -25.0)
const HOSTILE_TINT := Color(1.0, 0.42, 0.38)
const CHARRED_COLOR := Color(0.09, 0.08, 0.072)

var scene_root: Node3D
var tank: Node3D
var formation: BattleFormation
var _base_tints: Array[Color] = []
var _materials: Array[ShaderMaterial] = []

func setup(root_node: Node3D, world_position: Vector3, yaw_degrees: float) -> void:
	scene_root = root_node
	var ground_y: float = float(scene_root.call("height_at", world_position.x, world_position.z))
	tank = scene_root.call("spawn", TANK_MODEL_PATH, Vector3(world_position.x, ground_y + 0.03, world_position.z), 1.0, yaw_degrees)
	tank.name = "M1A2_SEPv3_dannzjs_CC_BY_4_hostile"
	_apply_armor_shader()

func _apply_armor_shader() -> void:
	for child: Node in tank.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		for i in range(mi.mesh.get_surface_count()):
			var original := mi.get_active_material(i) as StandardMaterial3D
			if original == null:
				continue
			var material := ShaderMaterial.new()
			material.shader = load("res://scripts/production/visual_slice_armor.gdshader")
			var tint := original.albedo_color * HOSTILE_TINT
			material.set_shader_parameter("paint_texture", original.albedo_texture)
			material.set_shader_parameter("paint_color", tint)
			material.set_shader_parameter("normal_texture", original.normal_texture)
			material.set_shader_parameter("has_normal", original.normal_enabled)
			material.set_shader_parameter("rough_texture", original.roughness_texture)
			material.set_shader_parameter("roughness_factor", original.roughness)
			material.set_shader_parameter("ground_y", tank.position.y)
			material.set_shader_parameter("authored_metallic", original.metallic)
			material.set_shader_parameter("authored_specular", original.metallic_specular)
			material.set_shader_parameter("metal_texture", original.metallic_texture)
			material.set_shader_parameter("has_metal_texture", original.metallic_texture != null)
			material.set_shader_parameter("ao_texture", original.ao_texture)
			material.set_shader_parameter("has_ao", original.ao_enabled)
			material.set_shader_parameter("vehicle_inverse", tank.global_transform.affine_inverse())
			var material_name := original.resource_name.to_lower()
			var role := 0.0
			if "rubber" in material_name:
				role = 1.0
			elif "gear" in material_name or "radiator" in material_name or "screw" in material_name:
				role = 2.0
			elif material_name == "light":
				role = 3.0
			material.set_shader_parameter("surface_role", role)
			var channels: Array[Vector4] = [Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(0, 0, 0, 1), Vector4(.333, .333, .333, 0)]
			material.set_shader_parameter("rough_channel", channels[original.roughness_texture_channel])
			material.set_shader_parameter("metal_channel", channels[original.metallic_texture_channel])
			material.set_shader_parameter("ao_channel", channels[original.ao_texture_channel])
			mi.set_surface_override_material(i, material)
			_base_tints.append(tint)
			_materials.append(material)

func _ready() -> void:
	formation = BattleFormation.new()
	formation.name = "GateBSimHostile"
	formation.display_name = "RED-ARMOR-01"
	formation.faction = "RED"
	var definition: FormationDefinition = load(TANK_DEFINITION_PATH) as FormationDefinition
	formation.definition = definition
	add_child(formation)
	formation.global_position = world_to_sim(tank.global_position)
	formation.modulate = Color(1.0, 1.0, 1.0, 0.0)
	formation.health_changed.connect(_on_health_changed)
	formation.died.connect(_on_died)
	print("FRONTLINE_GATE_D1_TARGET_READY role=%s hp=%d sim=%s world=%s" % [
		formation.get_role(), formation.max_hp, str(formation.global_position), str(tank.global_position)])

func _on_health_changed(current_hp: int, max_hp_value: int) -> void:
	var fraction := float(current_hp) / float(maxf(1, max_hp_value))
	var charred := 1.0 - fraction
	for index in range(_materials.size()):
		_materials[index].set_shader_parameter("paint_color", _base_tints[index].lerp(CHARRED_COLOR, charred))

func _on_died() -> void:
	for index in range(_materials.size()):
		_materials[index].set_shader_parameter("paint_color", CHARRED_COLOR)
	print("FRONTLINE_GATE_D1_TARGET_DESTROYED")

func get_tank_position() -> Vector3:
	return tank.global_position if tank != null else Vector3.ZERO

func get_hp() -> int:
	return formation.current_hp if formation != null else 0

func get_max_hp() -> int:
	return formation.max_hp if formation != null else 0

func is_destroyed() -> bool:
	return formation != null and not formation.is_alive

func world_to_sim(world_position: Vector3) -> Vector2:
	return (Vector2(world_position.x, world_position.z) - RT_SIM_ORIGIN_WORLD) / RT_SIM_TO_WORLD
