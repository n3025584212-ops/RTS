extends "res://scripts/production/full_battlefield_production_v2_lod.gd"
## Structural propagation pass grown on top of the verified V2 LOD scene.
## The inherited near layer is not rebuilt or reduced. This pass restores two
## battle-scale elements that were lost during the first LOD conversion:
## a wide strategic river/bridge and exact HF-house anchors at the town front.

const HERO_HOUSE_LOD := "res://scenes/production/RiverTownHeroHouseHF.tscn"
const BUDGET := preload("res://scripts/production/battlefield_visual_budget.gd")
const BRIDGE_X := 35.0
const BRIDGE_DECK_Y := 4.45
const BRIDGE_HALF_WIDTH := 6.6

func _ready() -> void:
	super._ready()
	create_wide_strategic_river_and_bridge()
	create_hf_townfront_anchors()

	# Keep the Run #5 foreground dominant while using parallax to clear the exact
	# inherited tree at (30,-62) that lies on the old camera-to-bridge sightline.
	# Moving the camera, not the tree, preserves the frozen Near composition.
	camera.position = Vector3(-5.0, 11.5, 35.0)
	camera.look_at(Vector3(28.0, 2.15, -108.0))
	camera.fov = 53.0
	camera.near = 0.25
	camera.far = 1250.0
	camera.current = true

	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V5_READY strategic_river=610x66 hf_townfront=3 mid_buildings=", mid_buildings)
	print("FRONTLINE_BRIDGE_VISUAL_PROOF world=", Vector3(BRIDGE_X, BRIDGE_DECK_Y, -100.0),
		" screen=", camera.unproject_position(Vector3(BRIDGE_X, BRIDGE_DECK_Y, -100.0)),
		" behind=", camera.is_position_behind(Vector3(BRIDGE_X, BRIDGE_DECK_Y, -100.0)))

func create_wide_strategic_river_and_bridge() -> void:
	# Expand the inherited River Town water language to the battlefield width.
	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	var river_mesh := PlaneMesh.new()
	river_mesh.size = Vector2(610.0, 66.0)
	var river := add_mesh(river_mesh, water, Vector3(0.0, 1.145, -100.0))
	river.name = "BattleRiverStrategicExpansion"
	BUDGET.apply_far_always_visible(river)

	# The earlier bridge was structurally present but visually collapsed into the
	# water band at the battle camera distance. Raise the deck and give it a dark,
	# continuous roadway plus tall side trusses so it remains a strategic landmark.
	var deck_surface := surface("asphalt_02", Color(.31, .30, .27), .52)
	deck_surface.roughness = .76
	var deck := block(Vector3(BRIDGE_X, BRIDGE_DECK_Y, -100.0), Vector3(BRIDGE_HALF_WIDTH * 2.0, .90, 70.0), "stone")
	deck.name = "StrategicBridgeDeckRaised"
	deck.material_override = deck_surface
	BUDGET.apply_mid(deck, true)

	# Stone edge beams provide a bright readable boundary against dark water/road.
	for x in [BRIDGE_X - BRIDGE_HALF_WIDTH + .35, BRIDGE_X + BRIDGE_HALF_WIDTH - .35]:
		var edge := block(Vector3(x, BRIDGE_DECK_Y + .48, -100.0), Vector3(.55, .95, 70.0), "stone")
		edge.name = "StrategicBridgeEdge"
		BUDGET.apply_mid(edge, true)

	# Piers and abutments are intentionally massive enough to read at RTS distance.
	for z in [-126.0, -113.0, -100.0, -87.0, -74.0]:
		for x in [BRIDGE_X - 4.2, BRIDGE_X + 4.2]:
			var pier := block(Vector3(x, 2.55, z), Vector3(1.45, 5.0, 2.1), "stone")
			BUDGET.apply_mid(pier, false)
	for z in [-136.0, -64.0]:
		var abutment := block(Vector3(BRIDGE_X, 2.75, z), Vector3(17.0, 5.5, 5.4), "stone")
		BUDGET.apply_mid(abutment, true)

	# Two continuous trusses. Their 3 m vertical silhouette prevents the crossing
	# from disappearing into the horizontal river plane in the acceptance camera.
	var left_x := BRIDGE_X - BRIDGE_HALF_WIDTH + .55
	var right_x := BRIDGE_X + BRIDGE_HALF_WIDTH - .55
	for x in [left_x, right_x]:
		add_budget_bridge_member(Vector3(x, BRIDGE_DECK_Y + .70, -135.0), Vector3(x, BRIDGE_DECK_Y + .70, -65.0), .12)
		add_budget_bridge_member(Vector3(x, BRIDGE_DECK_Y + 3.65, -135.0), Vector3(x, BRIDGE_DECK_Y + 3.65, -65.0), .15)
		for z in range(-134, -65, 6):
			var zf := float(z)
			add_budget_bridge_member(Vector3(x, BRIDGE_DECK_Y + .70, zf), Vector3(x, BRIDGE_DECK_Y + 3.65, zf), .095)
			if z + 6 <= -65:
				add_budget_bridge_member(Vector3(x, BRIDGE_DECK_Y + .82, zf), Vector3(x, BRIDGE_DECK_Y + 3.55, float(z + 6)), .085)
	# Portal frames make the crossing width legible instead of reading as two rails.
	for z in [-132.0, -100.0, -68.0]:
		add_budget_bridge_member(Vector3(left_x, BRIDGE_DECK_Y + 3.65, z), Vector3(right_x, BRIDGE_DECK_Y + 3.65, z), .14)

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
	# Ordinary MID houses remain the continuous urban mass. Three exact HF modules
	# sit on the front edge so the local material language survives into battlefield scale.
	add_hf_town_anchor(-96.0, -153.0, 8.0, .86, false)
	add_hf_town_anchor(15.0, -151.0, -4.0, .92, true)
	add_hf_town_anchor(116.0, -158.0, 5.0, .88, false)

func add_hf_town_anchor(x: float, z: float, yaw: float, scale3: float, keep_shadow: bool) -> Node3D:
	var house := spawn(HERO_HOUSE_LOD, Vector3(x, height_at(x, z) - .04, z), scale3, yaw, false)
	house.name = "HF_TownFrontAnchor_%02d" % (mid_buildings + 1)
	BUDGET.apply_mid(house, keep_shadow)
	mid_buildings += 1
	return house
