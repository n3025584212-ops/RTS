class_name RiverTownArmoredUnit
extends Node3D

## Gate B (MINIMUM_ARMORED_UNIT_INTEGRATION).
## Binds the validated BattleFormation control chain (selection -> issue_move ->
## NavigationService path -> movement) to the real Abrams PBR asset inside the
## River Town mother scene. The 2D BattleFormation runs the validated logic in
## sim space with its 2D visuals hidden; this node presents it by driving the
## real tank mesh. No box/cylinder proxies.

const TANK_DEFINITION_PATH := "res://resources/formations/tank.tres"
const RT_SIM_TO_WORLD := 0.1
const RT_SIM_ORIGIN_WORLD := Vector2(-25.0, -25.0)
const CLICK_TOLERANCE_WORLD := 3.2
const TURN_RATE := 5.0

var scene_root: Node3D
var tank: Node3D
var camera: Camera3D
var formation: BattleFormation
var navigation: RiverTownSimNavigation
var _selection_ring: MeshInstance3D
var _heading: float = 0.0
var _last_sim_position := Vector2.ZERO
var _last_order_issued := ""

func setup(root_node: Node3D, tank_node: Node3D) -> void:
	scene_root = root_node
	tank = tank_node

func _ready() -> void:
	if tank == null or scene_root == null:
		push_error("GATE_B armored unit misconfigured: tank or scene root missing")
		return
	camera = get_viewport().get_camera_3d()
	navigation = RiverTownSimNavigation.new()
	navigation.name = "GateBSimNavigation"
	add_child(navigation)
	formation = BattleFormation.new()
	formation.name = "GateBSimTank"
	formation.display_name = "ARMOR-01"
	formation.faction = "BLUE"
	var definition: FormationDefinition = load(TANK_DEFINITION_PATH) as FormationDefinition
	formation.definition = definition
	add_child(formation)
	formation.set_navigation(navigation)
	formation.global_position = world_to_sim(tank.global_position)
	formation.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_last_sim_position = formation.global_position
	_heading = tank.rotation.y
	_build_selection_ring()
	add_to_group("gate_b_armored_unit")
	print("FRONTLINE_GATE_B_ARMORED_UNIT_READY role=%s hp=%d speed=%d sim=%s world=%s" % [
		formation.get_role(), formation.max_hp, formation.move_speed,
		str(formation.global_position), str(tank.global_position)])

func _process(delta: float) -> void:
	if formation == null or tank == null:
		return
	var sim: Vector2 = formation.global_position
	var moved := sim - _last_sim_position
	if moved.length_squared() > 0.000001:
		var desired := atan2(-moved.x, -moved.y)
		_heading = lerp_angle(_heading, desired, minf(1.0, TURN_RATE * delta))
	var world := sim_to_world(sim)
	var ground_y: float = float(scene_root.call("height_at", world.x, world.y))
	tank.global_position = Vector3(world.x, ground_y + 0.03, world.y)
	tank.rotation.y = _heading
	_last_sim_position = sim
	if _selection_ring != null:
		_selection_ring.visible = formation.is_selected
		if formation.is_selected:
			_selection_ring.global_position = Vector3(world.x, ground_y + 0.08, world.y)

func _unhandled_input(event: InputEvent) -> void:
	if camera == null or tank == null or formation == null:
		return
	if event is InputEventMouseButton and event.is_pressed():
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			_handle_select(mouse.position)
		elif mouse.button_index == MOUSE_BUTTON_RIGHT:
			_handle_order(mouse.position)

func _handle_select(screen_position: Vector2) -> void:
	var ground: Variant = _ground_point_under(screen_position)
	if ground == null:
		formation.set_selected(false)
		return
	var point := ground as Vector3
	var near_tank := Vector2(point.x, point.z).distance_to(Vector2(tank.global_position.x, tank.global_position.z)) <= CLICK_TOLERANCE_WORLD
	formation.set_selected(near_tank)

func _handle_order(screen_position: Vector2) -> void:
	if not formation.is_selected:
		return
	var ground: Variant = _ground_point_under(screen_position)
	if ground == null:
		return
	var point := ground as Vector3
	issue_move_to(point)

func issue_move_to(world_target: Vector3) -> bool:
	formation.set_selected(true)
	var sim_target := world_to_sim(world_target)
	var accepted: bool = formation.issue_move(sim_target)
	_last_order_issued = "MOVE@" + str(world_target)
	if accepted:
		_spawn_command_marker(world_target)
	print("FRONTLINE_GATE_B_ORDER_ISSUED sim_from=%s sim_to=%s accepted=%s" % [
		str(formation.global_position), str(sim_target), str(accepted)])
	return accepted

func demo_issue_move(world_target: Vector3) -> bool:
	# Evidence-capture entry point: issues the order through the same validated
	# chain the mouse path uses (set_selected + issue_move).
	return issue_move_to(world_target)

func get_tank_position() -> Vector3:
	return tank.global_position if tank != null else Vector3.ZERO

func get_sim_position() -> Vector2:
	return formation.global_position if formation != null else Vector2.ZERO

func get_order() -> String:
	return formation.get_order() if formation != null else "UNBOUND"

func is_unit_selected() -> bool:
	return formation.is_selected if formation != null else false

func world_to_sim(world_position: Vector3) -> Vector2:
	return (Vector2(world_position.x, world_position.z) - RT_SIM_ORIGIN_WORLD) / RT_SIM_TO_WORLD

func sim_to_world(sim_position: Vector2) -> Vector2:
	return RT_SIM_ORIGIN_WORLD + sim_position * RT_SIM_TO_WORLD

func _ground_point_under(screen_position: Vector2):
	if camera == null:
		return null
	var origin := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.0001:
		return null
	var plane_y: float = tank.global_position.y
	var t := (plane_y - origin.y) / direction.y
	if t <= 0.0:
		return null
	return origin + direction * t

func _build_selection_ring() -> void:
	_selection_ring = MeshInstance3D.new()
	_selection_ring.name = "GateBSelectionRing"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 2.35
	mesh.outer_radius = 2.6
	mesh.rings = 32
	mesh.ring_segments = 8
	_selection_ring.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.9, 1.0)
	material.metallic = 0.1
	material.roughness = 0.42
	material.emission_enabled = true
	material.emission = Color(0.1, 0.45, 0.5)
	material.emission_energy_multiplier = 0.6
	_selection_ring.material_override = material
	_selection_ring.visible = false
	add_child(_selection_ring)

func _spawn_command_marker(world_target: Vector3) -> void:
	var marker := MeshInstance3D.new()
	marker.name = "GateBCommandMarker"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.85
	mesh.outer_radius = 1.1
	mesh.rings = 24
	mesh.ring_segments = 8
	marker.mesh = mesh
	var ground_y: float = float(scene_root.call("height_at", world_target.x, world_target.z))
	marker.position = Vector3(world_target.x, ground_y + 0.1, world_target.z)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.92, 1.0)
	material.metallic = 0.1
	material.roughness = 0.5
	marker.material_override = material
	add_child(marker)
	get_tree().create_timer(1.4).timeout.connect(marker.queue_free)
