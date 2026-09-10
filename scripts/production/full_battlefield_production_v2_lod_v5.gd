extends "res://scripts/production/full_battlefield_production_v2_lod.gd"
## Structural propagation pass grown on top of the verified V2 LOD scene.
## The inherited near layer is not rebuilt or reduced. This pass restores two
## battle-scale elements that were lost during the first LOD conversion:
## a wide strategic river/bridge and exact HF-house anchors at the town front.

const HERO_HOUSE_LOD := "res://scenes/production/RiverTownHeroHouseHF.tscn"
const BUDGET := preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	create_wide_strategic_river_and_bridge()
	create_hf_townfront_anchors()

	# Keep the Run #5-quality foreground readable while making the bridge a true
	# diagonal strategic structure instead of a thin horizontal map feature.
	camera.position = Vector3(66.0, 18.5, 42.0)
	camera.look_at(Vector3(2.0, 1.8, -96.0))
	camera.fov = 50.0
	camera.near = 0.25
	camera.far = 1250.0
	camera.current = true

	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V5_READY strategic_river=610x66 hf_townfront=3 mid_buildings=", mid_buildings)

func create_wide_strategic_river_and_bridge() -> void:
	# The base local scene already owns its 350x40 water/bridge. This lower plane
	# expands the same water language to battle scale without replacing Near.
	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	var river_mesh := PlaneMesh.new()
	river_mesh.size = Vector2(610.0, 66.0)
	var river := add_mesh(river_mesh, water, Vector3(0.0, 1.145, -100.0))
	river.name = "BattleRiverStrategicExpansion"
	BUDGET.apply_far_always_visible(river)

	# Enlarge the existing crossing in-place. The new deck sits a few centimetres
	# above the inherited local deck, avoiding z-fighting while preserving its detail.
	var deck := block(Vector3(35.0, 3.42, -100.0), Vector3(10.0, .80, 68.0), "stone")
	deck.name = "StrategicBridgeDeck"
	BUDGET.apply_mid(deck, true)

	for z in [-127.0, -113.0, -99.0, -85.0, -71.0]:
		for x in [31.5, 38.5]:
			var pier := block(Vector3(x, 1.40, z), Vector3(1.20, 3.20, 1.80), "stone")
			BUDGET.apply_mid(pier, false)

	for z in [-133.0, -67.0]:
		var abutment := block(Vector3(35.0, 2.15, z), Vector3(14.0, 4.3, 4.6), "stone")
		BUDGET.apply_mid(abutment, true)

	for x in [30.15, 39.85]:
		add_budget_bridge_member(Vector3(x, 4.75, -134.0), Vector3(x, 4.75, -66.0), .10)
		add_budget_bridge_member(Vector3(x, 4.02, -134.0), Vector3(x, 4.02, -66.0), .075)
		for z in range(-132, -67, 4):
			add_budget_bridge_member(Vector3(x, 3.62, float(z)), Vector3(x, 4.75, float(z)), .065)
			if z + 4 <= -68:
				add_budget_bridge_member(Vector3(x, 4.05, float(z)), Vector3(x, 4.72, float(z + 4)), .060)

func add_budget_bridge_member(a: Vector3, b: Vector3, radius: float) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = a.distance_to(b)
	mesh.radial_segments = 8
	var member := add_mesh(mesh, mats["metal"], (a + b) * .5)
	member.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
	BUDGET.apply_mid(member, false)
	return member

func create_hf_townfront_anchors() -> void:
	# The ordinary MID houses remain the continuous urban mass. Three exact HF
	# modules sit on that mass's front edge so the local material/structure language
	# survives the transition into the battlefield instead of stopping at foreground.
	add_hf_town_anchor(-96.0, -153.0, 8.0, .86, false)
	add_hf_town_anchor(15.0, -151.0, -4.0, .92, true)
	add_hf_town_anchor(116.0, -158.0, 5.0, .88, false)

func add_hf_town_anchor(x: float, z: float, yaw: float, scale3: float, keep_shadow: bool) -> Node3D:
	var house := spawn(HERO_HOUSE_LOD, Vector3(x, height_at(x, z) - .04, z), scale3, yaw, false)
	house.name = "HF_TownFrontAnchor_%02d" % (mid_buildings + 1)
	BUDGET.apply_mid(house, keep_shadow)
	mid_buildings += 1
	return house
