class_name Battle3DPresentation
extends Node3D

var _battle: Node
var _intel: BattleIntelTracker
var _visibility: BattleVisibilityField
var _war_flow: BattlePlayerWarFlow
var _command_area: BattleObjective
var _proxies: Dictionary = {}
var _last_known_markers: Dictionary = {}
var _scan_accumulator: float = 0.0
var _initialized: bool = false

var _blue_material: StandardMaterial3D
var _red_material: StandardMaterial3D
var _contact_material: StandardMaterial3D
var _destroyed_material: StandardMaterial3D
var _selection_material: StandardMaterial3D
var _last_known_material: StandardMaterial3D
var _objective_blue_material: StandardMaterial3D
var _objective_red_material: StandardMaterial3D
var _objective_contested_material: StandardMaterial3D
var _counterattack_material: StandardMaterial3D
var _objective_visual: MeshInstance3D
var _counterattack_ring: MeshInstance3D

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	_battle = get_parent().get_parent()
	_intel = _battle.get_node("IntelTracker") as BattleIntelTracker
	_visibility = _battle.get_node("VisibilityField") as BattleVisibilityField
	_war_flow = _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	_command_area = _battle.get_node("CommandArea") as BattleObjective
	_build_materials()
	_create_command_area_visual()
	if not _visibility.smoke_deployed.is_connected(_on_smoke_deployed):
		_visibility.smoke_deployed.connect(_on_smoke_deployed)
	_sync_formations()
	_initialized = true
	print("FRONTLINE_3D_PRESENTATION_READY bound=%d objectives=1" % _proxies.size())

func _process(delta: float) -> void:
	if not _initialized:
		return
	_scan_accumulator += delta
	if _scan_accumulator >= 0.20:
		_scan_accumulator = 0.0
		_sync_formations()
	_update_formation_proxies()
	_update_command_area()
	_update_last_known_markers()

func _build_materials() -> void:
	_blue_material = _make_material(Color(0.16, 0.48, 0.92), 0.30, 0.50)
	_red_material = _make_material(Color(0.82, 0.15, 0.12), 0.28, 0.52)
	_contact_material = _make_material(Color(0.96, 0.58, 0.12), 0.05, 0.70)
	_destroyed_material = _make_material(Color(0.12, 0.12, 0.12), 0.45, 0.82)
	_selection_material = _make_material(Color(0.25, 0.90, 1.0), 0.10, 0.42)
	_last_known_material = _make_material(Color(0.88, 0.65, 0.24), 0.05, 0.68)
	_objective_blue_material = _make_material(Color(0.12, 0.48, 0.92), 0.10, 0.62)
	_objective_red_material = _make_material(Color(0.78, 0.16, 0.12), 0.10, 0.62)
	_objective_contested_material = _make_material(Color(0.95, 0.52, 0.08), 0.08, 0.68)
	_counterattack_material = _make_transparent_material(Color(0.95, 0.25, 0.16, 0.28))

func _sync_formations() -> void:
	var discovered: Array[BattleFormation] = []
	_collect_formations(_battle, discovered)
	for formation: BattleFormation in discovered:
		if not _proxies.has(formation):
			_register_formation(formation)

func _collect_formations(node: Node, result: Array[BattleFormation]) -> void:
	for child: Node in node.get_children():
		if child is BattleFormation:
			result.append(child as BattleFormation)
		_collect_formations(child, result)

func _register_formation(formation: BattleFormation) -> void:
	formation.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var proxy := Node3D.new()
	proxy.name = "Proxy_%s" % formation.display_name.replace(" ", "_").replace("-", "_")
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = _mesh_for_role(formation.get_role())
	proxy.add_child(body)
	var ring := MeshInstance3D.new()
	ring.name = "Selection"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.38
	ring_mesh.outer_radius = 0.48
	ring_mesh.rings = 18
	ring_mesh.ring_segments = 8
	ring.mesh = ring_mesh
	ring.position.y = -0.16
	ring.material_override = _selection_material
	ring.visible = false
	proxy.add_child(ring)
	add_child(proxy)
	_proxies[formation] = proxy

func _mesh_for_role(role: String) -> PrimitiveMesh:
	if role == "INFANTRY":
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.20
		cylinder.bottom_radius = 0.20
		cylinder.height = 0.32
		return cylinder
	var box := BoxMesh.new()
	match role:
		"RECON": box.size = Vector3(0.52, 0.24, 0.34)
		"IFV": box.size = Vector3(0.72, 0.30, 0.42)
		"TANK", "ARMOR": box.size = Vector3(0.78, 0.32, 0.46)
		_: box.size = Vector3(0.58, 0.26, 0.38)
	return box

func _update_formation_proxies() -> void:
	for formation_variant: Variant in _proxies.keys():
		var formation := formation_variant as BattleFormation
		var proxy := _proxies[formation] as Node3D
		if formation == null or not is_instance_valid(formation):
			proxy.visible = false
			continue
		var body := proxy.get_node("Body") as MeshInstance3D
		var ring := proxy.get_node("Selection") as MeshInstance3D
		proxy.position = Battle3DAdapter.sim_to_world(formation.global_position, 0.18)
		var presentation_visible: bool = formation.visible
		if formation.faction == "RED":
			presentation_visible = presentation_visible and (
				formation.intel_state == BattleIntelTracker.CONTACT
				or formation.intel_state == BattleIntelTracker.CONFIRMED
			)
		proxy.visible = presentation_visible
		if not presentation_visible:
			continue
		if not formation.is_alive:
			body.material_override = _destroyed_material
		elif formation.faction == "BLUE":
			body.material_override = _blue_material
		elif formation.intel_state == BattleIntelTracker.CONTACT:
			body.material_override = _contact_material
		else:
			body.material_override = _red_material
		ring.visible = formation.is_selected and formation.is_alive

func _create_command_area_visual() -> void:
	_objective_visual = MeshInstance3D.new()
	_objective_visual.name = "Objective_RED_COMMAND_AREA"
	var objective_mesh := CylinderMesh.new()
	objective_mesh.top_radius = Battle3DAdapter.sim_length_to_world(_command_area.capture_radius)
	objective_mesh.bottom_radius = objective_mesh.top_radius
	objective_mesh.height = 0.035
	_objective_visual.mesh = objective_mesh
	_objective_visual.position = Battle3DAdapter.sim_to_world(_command_area.global_position, 0.055)
	add_child(_objective_visual)

	_counterattack_ring = MeshInstance3D.new()
	_counterattack_ring.name = "CommandAreaCounterattackZone"
	var zone_mesh := TorusMesh.new()
	var zone_radius: float = Battle3DAdapter.sim_length_to_world(_war_flow.get_counterattack_radius())
	zone_mesh.inner_radius = maxf(0.01, zone_radius - 0.035)
	zone_mesh.outer_radius = zone_radius + 0.035
	zone_mesh.rings = 40
	zone_mesh.ring_segments = 8
	_counterattack_ring.mesh = zone_mesh
	_counterattack_ring.position = Battle3DAdapter.sim_to_world(_command_area.global_position, 0.04)
	_counterattack_ring.material_override = _counterattack_material
	add_child(_counterattack_ring)

	_command_area.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _update_command_area() -> void:
	if _objective_visual == null or _command_area == null:
		return
	_objective_visual.position = Battle3DAdapter.sim_to_world(_command_area.global_position, 0.055)
	if _command_area.is_contested():
		_objective_visual.material_override = _objective_contested_material
	elif _command_area.get_control_owner() == BattleObjective.OWNER_PLAYER:
		_objective_visual.material_override = _objective_blue_material
	else:
		_objective_visual.material_override = _objective_red_material

func _update_last_known_markers() -> void:
	for formation_variant: Variant in _proxies.keys():
		var formation := formation_variant as BattleFormation
		if formation == null or formation.faction != "RED":
			continue
		var state := _intel.get_intel_state_for(formation)
		if state == BattleIntelTracker.LAST_KNOWN:
			if not _last_known_markers.has(formation):
				var marker := MeshInstance3D.new()
				var mesh := TorusMesh.new()
				mesh.inner_radius = 0.26
				mesh.outer_radius = 0.38
				mesh.rings = 16
				mesh.ring_segments = 8
				marker.mesh = mesh
				marker.material_override = _last_known_material
				add_child(marker)
				_last_known_markers[formation] = marker
			var last_marker := _last_known_markers[formation] as MeshInstance3D
			last_marker.visible = true
			last_marker.position = Battle3DAdapter.sim_to_world(_intel.get_last_known_position_for(formation), 0.045)
		elif _last_known_markers.has(formation):
			(_last_known_markers[formation] as MeshInstance3D).visible = false

func _on_smoke_deployed(center: Vector2, radius: float, duration: float) -> void:
	var smoke := MeshInstance3D.new()
	smoke.name = "Smoke3D"
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	smoke.mesh = mesh
	var world_radius := Battle3DAdapter.sim_length_to_world(radius)
	smoke.scale = Vector3(world_radius * 1.5, 0.75, world_radius * 1.5)
	smoke.position = Battle3DAdapter.sim_to_world(center, 0.65)
	smoke.material_override = _make_transparent_material(Color(0.60, 0.64, 0.66, 0.42))
	add_child(smoke)
	get_tree().create_timer(duration).timeout.connect(smoke.queue_free)

func show_command_marker(sim_position: Vector2) -> void:
	var marker := MeshInstance3D.new()
	marker.name = "CommandMarker3D"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.28
	mesh.outer_radius = 0.42
	mesh.rings = 18
	mesh.ring_segments = 8
	marker.mesh = mesh
	marker.position = Battle3DAdapter.sim_to_world(sim_position, 0.04)
	marker.material_override = _make_material(Color(0.30, 0.92, 1.0), 0.10, 0.52)
	marker.scale = Vector3(0.72, 0.72, 0.72)
	add_child(marker)
	get_tree().create_timer(1.2).timeout.connect(marker.queue_free)

func get_player_selectable_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	for formation_variant: Variant in _proxies.keys():
		var formation := formation_variant as BattleFormation
		if formation != null and is_instance_valid(formation) and formation.faction == "BLUE" and formation.selectable and formation.is_alive:
			result.append(formation)
	return result

func has_proxy(formation: BattleFormation) -> bool:
	return _proxies.has(formation)

func get_bound_count() -> int:
	return _proxies.size()

func get_world_position_for(formation: BattleFormation) -> Vector3:
	return Battle3DAdapter.sim_to_world(formation.global_position, 0.18)

func _make_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material

func _make_transparent_material(color: Color) -> StandardMaterial3D:
	var material := _make_material(color, 0.0, 0.96)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
