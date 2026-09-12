extends "res://scripts/production/river_town_visual_slice.gd"
## Proof scene for reusable infrastructure resources.
## V2 replaces the old Run #5 primitive bridge with reusable terrain-integrated modules.

const PROOF_OUT := "res://artifacts/infrastructure_family"
const INFRA := "res://scenes/production/infrastructure/"

var module_instance_count: int = 0
var resource_instance_counts: Dictionary = {}
var proof_resources: Array[String] = [
	INFRA + "BridgeDeckSmall.tscn",
	INFRA + "BridgeAbutmentConcrete.tscn",
	INFRA + "BridgePierConcrete.tscn",
	INFRA + "BridgeRailSteel.tscn",
	INFRA + "RetainingWallConcrete.tscn",
	INFRA + "CulvertSmall.tscn",
	INFRA + "RoadGuardrailSteel.tscn",
	INFRA + "RiverBankRiprap.tscn",
]

func _ready() -> void:
	super._ready()
	camera.position = Vector3(77.0, 24.0, -48.0)
	camera.look_at(Vector3(34.0, 2.4, -99.0))
	camera.fov = 50.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true
	print("FRONTLINE_INFRASTRUCTURE_PROOF_READY module_instances=", module_instance_count,
		" resources=", proof_resources.size(), " original_run5_abrams=YES old_primitive_bridge=NO terrain_integrated=YES renderer=", RenderingServer.get_current_rendering_method())

func create_architecture() -> void:
	pass

func create_background() -> void:
	create_distant_forest()

func create_water() -> void:
	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	var plane := PlaneMesh.new()
	plane.size = Vector2(350, 40)
	add_mesh(plane, water, Vector3(0, 1.15, -100))

	var puddle_water := ShaderMaterial.new()
	puddle_water.shader = load("res://scripts/production/visual_slice_puddle.gdshader")
	for site in puddle_sites:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var points: Array[Vector3] = []
		for j in range(40):
			var angle := TAU * j / 40.0
			points.append(Vector3(cos(angle) * site.width * 1.4, 0, sin(angle) * site.length * 1.4))
		for j in range(40):
			for v in [Vector3.ZERO, points[j], points[(j + 1) % 40]]:
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(v.x, v.z))
				st.add_vertex(v)
		st.generate_tangents()
		var puddle := add_mesh(st.commit(), puddle_water, Vector3(site.x, site.level, site.z))
		puddle.name = "WaterInSculptedRut"
		puddle.layers = 2
		puddle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_place_infrastructure()

func _place_infrastructure() -> void:
	for z in [-118.0, -106.0, -94.0, -82.0]:
		_place(INFRA + "BridgeDeckSmall.tscn", Vector3(35.0, 3.35, z), 0.0, "BridgeDeck")
		_place(INFRA + "BridgeRailSteel.tscn", Vector3(31.12, 3.77, z), 0.0, "BridgeRailLeft")
		_place(INFRA + "BridgeRailSteel.tscn", Vector3(38.88, 3.77, z), 0.0, "BridgeRailRight")

	_place(INFRA + "BridgeAbutmentConcrete.tscn", Vector3(35.0, 0.62, -124.3), 0.0, "SouthAbutment")
	_place(INFRA + "BridgeAbutmentConcrete.tscn", Vector3(35.0, 0.62, -75.7), PI, "NorthAbutment")
	for z in [-112.0, -100.0, -88.0]:
		_place(INFRA + "BridgePierConcrete.tscn", Vector3(35.0, 0.32, z), 0.0, "BridgePier")

	# Bridge approaches: independent roadside guardrails continue beyond the bridge parapets.
	for x in [31.10, 38.90]:
		_place(INFRA + "RoadGuardrailSteel.tscn", Vector3(x, height_at(x, -130.5) + 0.30, -130.5), 0.0, "SouthApproachGuardrail")
		_place(INFRA + "RoadGuardrailSteel.tscn", Vector3(x, height_at(x, -69.5) + 0.30, -69.5), 0.0, "NorthApproachGuardrail")

	# Terrain integration: riprap is buried into both river shoulders rather than displayed as a loose asset pile.
	_place(INFRA + "RiverBankRiprap.tscn", Vector3(24.5, 1.30, -101.0), PI * 0.5, "WestRiverRiprap")
	_place(INFRA + "RiverBankRiprap.tscn", Vector3(45.5, 1.30, -99.0), -PI * 0.5, "EastRiverRiprap")

	var retaining_y := height_at(17.0, -72.0) - 1.05
	_place(INFRA + "RetainingWallConcrete.tscn", Vector3(17.0, retaining_y, -72.0), 0.18, "RoadEdgeRetainingWall")
	var culvert_y := height_at(53.0, -73.0) - 0.08
	_place(INFRA + "CulvertSmall.tscn", Vector3(53.0, culvert_y, -73.0), -0.18, "RoadsideCulvert")

func _place(path: String, position3: Vector3, yaw: float, label: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Infrastructure proof failed to load resource: " + path)
		return null
	var node := packed.instantiate() as Node3D
	node.name = label + "_%02d" % module_instance_count
	node.position = position3
	node.rotation.y = yaw
	add_child(node)
	module_instance_count += 1
	resource_instance_counts[path] = int(resource_instance_counts.get(path, 0)) + 1
	return node

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(PROOF_OUT)
	var image := get_viewport().get_texture().get_image()
	var png_path := PROOF_OUT + "/infrastructure_family_actual_1920x1080.png"
	var err := image.save_png(png_path)
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"module_instance_count": module_instance_count,
		"resource_count": proof_resources.size(),
		"resources": proof_resources,
		"resource_instance_counts": resource_instance_counts,
		"old_run5_primitive_bridge_removed": true,
		"run5_river_water_retained": true,
		"run5_puddle_water_retained": true,
		"original_run5_abrams_retained": true,
		"terrain_integration_v2": true,
		"road_guardrails_added": true,
		"riverbank_riprap_added": true,
		"extra_vehicle_count": 0,
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
	}
	FileAccess.open(PROOF_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_INFRASTRUCTURE_CAPTURED ", png_path, " ", image.get_size(), " modules=", module_instance_count)
	get_tree().quit(err)
