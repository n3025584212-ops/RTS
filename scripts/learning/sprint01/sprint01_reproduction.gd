extends Node3D

enum Phase {
	WAITING_SELECTION,
	WAITING_COMMAND,
	MOVING,
	COMBAT,
	COMPLETE
}

const SCENE_PATH := "res://scenes/learning/sprint01/Sprint01Reproduction.tscn"
const ABRAMS_PATH := "res://assets/golden_scene/vehicles/mbt_abrams.glb"
const IFV_PATH := "res://assets/golden_scene/vehicles/ifv.glb"
const PLAYER_NAME := "BLUE_ABRAMS_01"
const TARGET_NAME := "RED_IFV_01"
const PLAYER_START := Vector3(-18.0, 0.18, -2.0)
const COMMAND_TARGET := Vector3(8.0, 0.18, -2.0)
const TARGET_POSITION := Vector3(14.0, 0.18, -2.0)
const MOVE_SPEED := 8.0
const CONTACT_RANGE := 10.5
const SHOT_INTERVAL := 0.72
const SHOT_DAMAGE := 25
const STARTING_AMMO := 4
const STARTING_HP := 100

var phase: int = Phase.WAITING_SELECTION
var player_unit: Node3D
var target_unit: Node3D
var selection_ring: MeshInstance3D
var target_ring: MeshInstance3D
var effects_root: Node3D
var hud_status: Label
var hud_outcome: Label
var selected: bool = false
var command_issued: bool = false
var movement_started: bool = false
var contact_reached: bool = false
var combat_mutated: bool = false
var target_destroyed: bool = false
var visible_feedback_events: int = 0
var player_input_events: int = 0
var shot_index: int = 0
var ammo: int = STARTING_AMMO
var target_hp: int = STARTING_HP
var combat_timer: float = 0.0
var movement_start_position := PLAYER_START
var movement_end_position := PLAYER_START


func _ready() -> void:
	print("SPRINT01_REPRODUCTION_BOOT=YES")
	print("GODOT_VERSION=%s" % str(Engine.get_version_info().get("string", "unknown")))
	print("SCENE=%s" % SCENE_PATH)
	print("ASSET_PATHS=%s;%s" % [ABRAMS_PATH, IFV_PATH])
	if not _preflight_exact_assets():
		print("PLAYER_CHAIN_PASS=NO|FAILED_EDGE=EXACT_ASSET_BINDING")
		get_tree().quit(2)
		return
	_build_environment()
	_build_units()
	_build_hud()
	_update_hud()
	print("REUSED=Godot_4.7.1_toolchain;audited_real_asset_blobs;generic_capture_infrastructure")
	print("NEWLY_IMPLEMENTED=isolated_player_input;command_state;movement;contact;authoritative_combat;causal_3D_feedback;outcome")
	print("TESTED_EDGE=WAITING_FOR_PLAYER_INPUT")
	print("PLAYER_READY=YES|SELECT_KEY=1|COMMAND_KEY=M")


func _preflight_exact_assets() -> bool:
	var required_paths: Array[String] = [ABRAMS_PATH, IFV_PATH]
	for path: String in required_paths:
		if not ResourceLoader.exists(path):
			push_error("Sprint01 reproduction exact asset missing: %s" % path)
			print("ASSET_PRECHECK=FAIL|PATH=%s" % path)
			return false
		var resource := load(path)
		if not (resource is PackedScene):
			push_error("Sprint01 reproduction asset is not PackedScene: %s" % path)
			print("ASSET_PRECHECK=FAIL|PATH=%s|REASON=NOT_PACKED_SCENE" % path)
			return false
		print("ASSET_PRECHECK=PASS|PATH=%s|TYPE=PackedScene" % path)
	return true


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_1 or key_event.physical_keycode == KEY_1:
		player_input_events += 1
		print("INPUT_EVENT=KEY_1|CALLBACK=_unhandled_input|PRESSED=YES")
		_select_player()
	elif key_event.keycode == KEY_M or key_event.physical_keycode == KEY_M:
		player_input_events += 1
		print("INPUT_EVENT=KEY_M|CALLBACK=_unhandled_input|PRESSED=YES")
		_issue_attack_move()


func _select_player() -> void:
	if phase != Phase.WAITING_SELECTION:
		return
	selected = true
	selection_ring.visible = true
	phase = Phase.WAITING_COMMAND
	print("SELECTED_ENTITY=%s" % PLAYER_NAME)
	print("SELECTION_STATE_BEFORE=NONE")
	print("SELECTION_STATE_AFTER=%s" % PLAYER_NAME)
	_update_hud()


func _issue_attack_move() -> void:
	if phase != Phase.WAITING_COMMAND or not selected:
		print("COMMAND_REJECTED=ATTACK_MOVE|REASON=NO_VALID_SELECTION_OR_PHASE")
		return
	command_issued = true
	movement_start_position = player_unit.position
	phase = Phase.MOVING
	print("COMMAND=ATTACK_MOVE")
	print("COMMAND_TARGET=%s" % _fmt_vec(COMMAND_TARGET))
	print("COMMAND_STATE_BEFORE=WAITING_COMMAND")
	print("COMMAND_STATE_AFTER=MOVING")
	print("START_POSITION=%s" % _fmt_vec(movement_start_position))
	print("COMMAND_TARGET_POSITION=%s" % _fmt_vec(COMMAND_TARGET))
	_update_hud()


func _process(delta: float) -> void:
	match phase:
		Phase.MOVING:
			_tick_movement(delta)
		Phase.COMBAT:
			_tick_combat(delta)


func _tick_movement(delta: float) -> void:
	var before := player_unit.position
	var offset := COMMAND_TARGET - before
	offset.y = 0.0
	var remaining := offset.length()
	if remaining > 0.03:
		var step := minf(MOVE_SPEED * delta, remaining)
		player_unit.position += offset.normalized() * step
		if not movement_started and player_unit.position.distance_to(before) > 0.0001:
			movement_started = true
			print("MOVEMENT_STARTED=YES|FROM=%s" % _fmt_vec(before))
	if player_unit.position.distance_to(target_unit.position) <= CONTACT_RANGE:
		_begin_contact()
		return
	if remaining <= 0.03:
		movement_end_position = player_unit.position
		print("MOVEMENT_COMPLETED_OR_CONTACT=MOVEMENT_COMPLETED")
		print("END_POSITION=%s" % _fmt_vec(movement_end_position))
		print("FAILED_EDGE=CONTACT|REASON=COMMAND_TARGET_REACHED_WITHOUT_CONTACT")
		phase = Phase.COMPLETE
		_update_hud()


func _begin_contact() -> void:
	if contact_reached:
		return
	contact_reached = true
	movement_end_position = player_unit.position
	phase = Phase.COMBAT
	combat_timer = 0.32
	print("MOVEMENT_COMPLETED_OR_CONTACT=CONTACT")
	print("END_POSITION=%s" % _fmt_vec(movement_end_position))
	print("CONTACT=%s|RANGE=%.2f" % [TARGET_NAME, player_unit.position.distance_to(target_unit.position)])
	print("TARGET=%s" % TARGET_NAME)
	_update_hud()


func _tick_combat(delta: float) -> void:
	combat_timer -= delta
	if combat_timer > 0.0:
		return
	if target_hp <= 0 or ammo <= 0:
		return
	_fire_authoritative_shot()
	combat_timer = SHOT_INTERVAL


func _fire_authoritative_shot() -> void:
	shot_index += 1
	var ammo_before := ammo
	var hp_before := target_hp
	ammo -= 1
	target_hp = maxi(0, target_hp - SHOT_DAMAGE)
	combat_mutated = combat_mutated or (ammo != ammo_before and target_hp != hp_before)
	print("TARGET=%s" % TARGET_NAME)
	print("FIRE_EVENT=SHOT_%02d" % shot_index)
	print("AMMO_BEFORE=%d" % ammo_before)
	print("AMMO_AFTER=%d" % ammo)
	print("HP_BEFORE=%d" % hp_before)
	print("HP_AFTER=%d" % target_hp)
	_spawn_fire_feedback(shot_index)
	visible_feedback_events += 1
	print("VISIBLE_FEEDBACK_EVENT=SHOT_%02d|MUZZLE=YES|TRACER=YES|IMPACT=YES|CAUSED_BY=FIRE_EVENT" % shot_index)
	if target_hp <= 0:
		target_destroyed = true
		_apply_destroyed_feedback()
		print("DEATH_OR_SURVIVAL_OUTCOME=DESTROYED")
		print("OUTCOME=TARGET_DESTROYED")
		phase = Phase.COMPLETE
		_verify_player_chain()
	else:
		print("DEATH_OR_SURVIVAL_OUTCOME=SURVIVED|HP=%d" % target_hp)
	_update_hud()


func _verify_player_chain() -> void:
	var input_pass := player_input_events >= 2 and selected and command_issued
	var movement_pass := movement_started and contact_reached and movement_end_position.distance_to(movement_start_position) > 1.0
	var combat_pass := combat_mutated and shot_index >= 1 and ammo < STARTING_AMMO and target_hp < STARTING_HP
	var visible_pass := visible_feedback_events == shot_index and visible_feedback_events >= 1
	var outcome_pass := target_destroyed and target_hp == 0
	print("PLAYER_INPUT=%s|EVENTS=%d" % ["PASS" if input_pass else "FAIL", player_input_events])
	print("COMMAND_ROUTE=%s" % ("PASS" if command_issued else "FAIL"))
	print("MOVEMENT=%s|DELTA=%.2f" % ["PASS" if movement_pass else "FAIL", movement_end_position.distance_to(movement_start_position)])
	print("CONTACT=%s" % ("PASS" if contact_reached else "FAIL"))
	print("COMBAT=%s|SHOTS=%d|AMMO=%d|TARGET_HP=%d" % ["PASS" if combat_pass else "FAIL", shot_index, ammo, target_hp])
	print("VISIBLE_FEEDBACK=%s|EVENTS=%d" % ["PASS" if visible_pass else "FAIL", visible_feedback_events])
	print("OUTCOME=%s" % ("PASS|TARGET_DESTROYED" if outcome_pass else "FAIL"))
	if input_pass and movement_pass and combat_pass and visible_pass and outcome_pass:
		print("TESTED_EDGE=PLAYER_INPUT->COMMAND->MOVEMENT->CONTACT->COMBAT->VISIBLE_FEEDBACK->OUTCOME")
		print("FAILED_EDGE=NONE")
		print("UNKNOWN=NONE")
		print("PLAYER_CHAIN_PASS=YES")
	else:
		print("PLAYER_CHAIN_PASS=NO|FAILED_EDGE=RUNTIME_CHAIN_VALIDATION")


func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "LearningBattleEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.48, 0.58, 0.66)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.76, 0.72)
	environment.ambient_light_energy = 0.72
	world_env.environment = environment
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_energy = 1.25
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	var ground_mat := _material(Color(0.21, 0.27, 0.14), 0.94)
	var road_mat := _material(Color(0.28, 0.25, 0.19), 0.90)
	var berm_mat := _material(Color(0.24, 0.20, 0.12), 0.98)
	var concrete_mat := _material(Color(0.35, 0.36, 0.33), 0.88)
	var marker_mat := _emissive_material(Color(0.15, 0.52, 0.95))
	var hostile_mat := _emissive_material(Color(0.95, 0.12, 0.06))
	var ground := MeshInstance3D.new()
	ground.name = "BattlefieldGround"
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(70.0, 46.0)
	ground.mesh = ground_mesh
	ground.material_override = ground_mat
	add_child(ground)
	_add_box("ApproachRoad", Vector3(0.0, 0.04, -2.0), Vector3(58.0, 0.08, 9.0), road_mat)
	_add_box("NorthBermA", Vector3(-10.0, 0.55, -9.0), Vector3(22.0, 1.1, 2.2), berm_mat)
	_add_box("NorthBermB", Vector3(15.0, 0.55, -9.0), Vector3(20.0, 1.1, 2.2), berm_mat)
	_add_box("SouthBermA", Vector3(-12.0, 0.55, 5.0), Vector3(19.0, 1.1, 2.2), berm_mat)
	_add_box("SouthBermB", Vector3(13.0, 0.55, 5.0), Vector3(22.0, 1.1, 2.2), berm_mat)
	_add_box("DefensiveBarrierNorth", Vector3(10.5, 0.65, -6.1), Vector3(4.2, 1.3, 0.8), concrete_mat)
	_add_box("DefensiveBarrierSouth", Vector3(10.5, 0.65, 2.1), Vector3(4.2, 1.3, 0.8), concrete_mat)
	_add_box("EnemyRevetmentRear", Vector3(18.0, 0.75, -2.0), Vector3(1.0, 1.5, 7.0), concrete_mat)
	for x: float in [-12.0, -4.0, 4.0]:
		_add_box("RoadGuide_%s" % str(x), Vector3(x, 0.10, -2.0), Vector3(2.8, 0.03, 0.12), marker_mat)
	_add_world_ring(Vector3(COMMAND_TARGET.x, 0.12, COMMAND_TARGET.z), 1.2, marker_mat, "CommandTarget")
	_add_world_ring(Vector3(TARGET_POSITION.x, 0.12, TARGET_POSITION.z), 1.4, hostile_mat, "EnemyContactZone")
	_add_world_label(Vector3(-16.0, 3.8, -7.0), "BLUE APPROACH", Color(0.45, 0.78, 1.0))
	_add_world_label(Vector3(15.0, 4.2, -7.0), "RED DEFENSIVE POSITION", Color(1.0, 0.38, 0.28))
	var camera := Camera3D.new()
	camera.name = "ReproductionCamera"
	camera.position = Vector3(2.0, 26.0, 30.0)
	camera.fov = 52.0
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, -2.0), Vector3.UP)
	camera.current = true


func _build_units() -> void:
	effects_root = Node3D.new()
	effects_root.name = "CausalCombatFeedback"
	add_child(effects_root)
	player_unit = _spawn_real_model(ABRAMS_PATH, PLAYER_START, 7.8, 90.0, PLAYER_NAME)
	target_unit = _spawn_real_model(IFV_PATH, TARGET_POSITION, 6.7, -90.0, TARGET_NAME)
	selection_ring = _unit_ring(player_unit.position, Color(0.10, 0.55, 1.0), "PlayerSelectionRing")
	selection_ring.visible = false
	target_ring = _unit_ring(target_unit.position, Color(1.0, 0.10, 0.05), "TargetThreatRing")
	_add_world_label(player_unit.position + Vector3(0.0, 4.2, 0.0), "ABRAMS • PLAYER", Color(0.45, 0.80, 1.0))
	_add_world_label(target_unit.position + Vector3(0.0, 4.0, 0.0), "IFV • HOSTILE", Color(1.0, 0.42, 0.28))
	print("REAL_ASSET_INSTANCE=PASS|ENTITY=%s|PATH=%s" % [PLAYER_NAME, ABRAMS_PATH])
	print("REAL_ASSET_INSTANCE=PASS|ENTITY=%s|PATH=%s" % [TARGET_NAME, IFV_PATH])


func _spawn_real_model(path: String, position_value: Vector3, target_size: float, yaw: float, node_name: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Failed to load required real model: %s" % path)
		get_tree().quit(3)
		return Node3D.new()
	var root := packed.instantiate() as Node3D
	if root == null:
		push_error("Required real model root is not Node3D: %s" % path)
		get_tree().quit(4)
		return Node3D.new()
	root.name = node_name
	_fit_instance_to_size(root, target_size)
	root.position = position_value
	root.rotation_degrees.y = yaw
	add_child(root)
	return root


func _fit_instance_to_size(root: Node3D, target_max_dimension: float) -> float:
	var max_dim := 0.0
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	for node_variant: Node in meshes:
		var mesh_instance := node_variant as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var size := mesh_instance.mesh.get_aabb().size
		max_dim = maxf(max_dim, maxf(size.x, maxf(size.y, size.z)))
	if max_dim <= 0.0001:
		push_error("Real model has no measurable mesh: %s" % root.name)
		return 1.0
	var factor := target_max_dimension / max_dim
	root.scale = Vector3.ONE * factor
	return factor


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "PlayerEvidenceHUD"
	add_child(canvas)
	var panel := ColorRect.new()
	panel.position = Vector2(22.0, 20.0)
	panel.size = Vector2(585.0, 240.0)
	panel.color = Color(0.025, 0.035, 0.045, 0.84)
	canvas.add_child(panel)
	var title := Label.new()
	title.position = Vector2(42.0, 36.0)
	title.text = "SPRINT 01 • INDEPENDENT RTS REPRODUCTION"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.82, 0.92, 1.0))
	canvas.add_child(title)
	hud_status = Label.new()
	hud_status.position = Vector2(42.0, 76.0)
	hud_status.size = Vector2(540.0, 155.0)
	hud_status.add_theme_font_size_override("font_size", 18)
	hud_status.add_theme_color_override("font_color", Color(0.92, 0.94, 0.91))
	canvas.add_child(hud_status)
	hud_outcome = Label.new()
	hud_outcome.position = Vector2(1060.0, 44.0)
	hud_outcome.size = Vector2(500.0, 92.0)
	hud_outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_outcome.add_theme_font_size_override("font_size", 27)
	hud_outcome.add_theme_color_override("font_color", Color(1.0, 0.72, 0.25))
	canvas.add_child(hud_outcome)


func _update_hud() -> void:
	if hud_status == null:
		return
	hud_status.text = (
		"INPUT   [1] Select Abrams   [M] Attack-move\n"
		+ "STATE   %s\n" % _phase_name()
		+ "SELECT  %s\n" % (PLAYER_NAME if selected else "NONE")
		+ "COMMAND %s\n" % ("ATTACK_MOVE → (8, -2)" if command_issued else "WAITING")
		+ "COMBAT  Ammo %d/%d   Target HP %d/%d\n" % [ammo, STARTING_AMMO, target_hp, STARTING_HP]
		+ "FEEDBACK Muzzle + tracer + impact = %d event(s)" % visible_feedback_events
	)
	if target_destroyed:
		hud_outcome.text = "TARGET DESTROYED\nPLAYER CHAIN COMPLETE"
	elif phase == Phase.COMBAT:
		hud_outcome.text = "CONTACT • ENGAGING"
	else:
		hud_outcome.text = ""


func _phase_name() -> String:
	match phase:
		Phase.WAITING_SELECTION:
			return "WAITING PLAYER SELECTION"
		Phase.WAITING_COMMAND:
			return "SELECTED • WAITING COMMAND"
		Phase.MOVING:
			return "EXECUTING ATTACK-MOVE"
		Phase.COMBAT:
			return "CONTACT • COMBAT"
		Phase.COMPLETE:
			return "OUTCOME COMPLETE"
	return "UNKNOWN"


func _spawn_fire_feedback(index: int) -> void:
	var lateral_offset := (float(index) - 2.5) * 0.12
	var muzzle := player_unit.position + Vector3(3.0, 2.15, lateral_offset)
	var impact := target_unit.position + Vector3(-1.5, 1.55, lateral_offset)
	var flash_mat := _emissive_material(Color(1.0, 0.68, 0.12))
	var tracer_mat := _emissive_material(Color(1.0, 0.82, 0.28))
	var impact_mat := _emissive_material(Color(1.0, 0.18, 0.04))
	_add_sphere("MuzzleFlash_%02d" % index, muzzle, 0.62, flash_mat)
	_add_beam("Tracer_%02d" % index, muzzle, impact, 0.105, tracer_mat)
	_add_sphere("Impact_%02d" % index, impact, 0.48, impact_mat)
	var light := OmniLight3D.new()
	light.name = "ImpactLight_%02d" % index
	light.position = impact
	light.light_color = Color(1.0, 0.35, 0.08)
	light.light_energy = 4.5
	light.omni_range = 5.0
	effects_root.add_child(light)
	var marker := Label3D.new()
	marker.name = "ShotMarker_%02d" % index
	marker.text = "HIT %d" % index
	marker.position = impact + Vector3(0.0, 1.0 + float(index) * 0.20, 0.0)
	marker.font_size = 26
	marker.outline_size = 5
	marker.modulate = Color(1.0, 0.45, 0.20)
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.fixed_size = true
	marker.no_depth_test = true
	marker.pixel_size = 0.0025
	effects_root.add_child(marker)


func _apply_destroyed_feedback() -> void:
	var wreck_mat := _material(Color(0.055, 0.052, 0.045), 0.98)
	wreck_mat.metallic = 0.35
	_override_mesh_materials(target_unit, wreck_mat)
	target_unit.rotation_degrees.z = -12.0
	target_ring.scale = Vector3.ONE * 1.35
	var smoke_mat := _transparent_material(Color(0.08, 0.075, 0.065, 0.74))
	for i: int in range(4):
		var smoke_pos := target_unit.position + Vector3(-0.6 + float(i) * 0.42, 2.2 + float(i) * 0.62, 0.2 * float(i % 2))
		_add_sphere("DestructionSmoke_%02d" % i, smoke_pos, 0.65 + float(i) * 0.18, smoke_mat)
	_add_world_label(target_unit.position + Vector3(0.0, 5.1, 0.0), "TARGET DESTROYED", Color(1.0, 0.62, 0.20))
	print("VISIBLE_FEEDBACK_EVENT=DEATH|WRECK_MATERIAL=YES|TILT=YES|SMOKE=YES|WORLD_LABEL=YES")


func _override_mesh_materials(root: Node3D, material: Material) -> void:
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = material
	for child: Node in root.get_children():
		if child is Node3D:
			_override_mesh_materials(child as Node3D, material)


func _unit_ring(position_value: Vector3, color: Color, node_name: String) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = node_name
	var torus := TorusMesh.new()
	torus.inner_radius = 2.0
	torus.outer_radius = 2.25
	torus.rings = 32
	torus.ring_segments = 12
	ring.mesh = torus
	ring.position = Vector3(position_value.x, 0.22, position_value.z)
	ring.material_override = _emissive_material(color)
	add_child(ring)
	return ring


func _add_world_ring(position_value: Vector3, radius: float, material: Material, node_name: String) -> void:
	var ring := MeshInstance3D.new()
	ring.name = node_name
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(0.1, radius - 0.12)
	torus.outer_radius = radius
	torus.rings = 28
	torus.ring_segments = 10
	ring.mesh = torus
	ring.position = position_value
	ring.material_override = material
	add_child(ring)


func _add_world_label(position_value: Vector3, text_value: String, color: Color) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.position = position_value
	label.font_size = 28
	label.outline_size = 6
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0028
	add_child(label)


func _add_box(node_name: String, position_value: Vector3, size_value: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size_value
	instance.mesh = mesh
	instance.position = position_value
	instance.material_override = material
	add_child(instance)
	return instance


func _add_sphere(node_name: String, position_value: Vector3, radius: float, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	instance.mesh = mesh
	instance.position = position_value
	instance.material_override = material
	effects_root.add_child(instance)
	return instance


func _add_beam(node_name: String, a: Vector3, b: Vector3, thickness: float, material: Material) -> void:
	var direction := b - a
	var mesh := BoxMesh.new()
	mesh.size = Vector3(direction.length(), thickness, thickness)
	var beam := MeshInstance3D.new()
	beam.name = node_name
	beam.mesh = mesh
	var x_axis := direction.normalized()
	var z_axis := x_axis.cross(Vector3.UP)
	if z_axis.length_squared() < 0.0001:
		z_axis = Vector3.FORWARD
	z_axis = z_axis.normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	beam.transform = Transform3D(Basis(x_axis, y_axis, z_axis), (a + b) * 0.5)
	beam.material_override = material
	effects_root.add_child(beam)


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _emissive_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 3.0
	material.roughness = 0.35
	return material


func _transparent_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 1.0
	return material


func _fmt_vec(value: Vector3) -> String:
	return "(%.3f,%.3f,%.3f)" % [value.x, value.y, value.z]
