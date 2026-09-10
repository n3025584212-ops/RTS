extends "res://scripts/production/full_battlefield_production_v2_lod_v5.gd"
## Battle-pressure pass on top of the visually accepted V5 composition.
## Near, camera, river, bridge and HF town-front anchors are inherited unchanged.
## This pass only adds bounded MID/FAR combat activity so the battlefield reads
## as an active operation rather than a quiet countryside showcase.

const INFANTRY_PRESSURE := "res://assets/golden_scene/infantry/soldier.glb"
const IFV_PRESSURE := "res://assets/golden_scene/vehicles/ifv.glb"
const PRESSURE_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

var pressure_infantry := 0
var pressure_vehicles := 0
var pressure_smoke := 0
var pressure_fire := 0

func _ready() -> void:
	super._ready()
	create_midfar_battle_pressure()
	print("FRONTLINE_BATTLE_PRESSURE_READY infantry=", pressure_infantry,
		" vehicles=", pressure_vehicles,
		" smoke=", pressure_smoke,
		" fire=", pressure_fire,
		" total_mid_units=", mid_units)

func create_midfar_battle_pressure() -> void:
	create_bridgehead_infantry_and_vehicles()
	create_pressure_smoke()
	create_pressure_fire_points()

func create_bridgehead_infantry_and_vehicles() -> void:
	# Correct imported soldier scale is inherited from the proven non-LOD V2 path.
	# All placements are beyond the strategic river on the MID town-front side,
	# so the frozen Run #5 Near composition is not edited or substituted.
	var infantry_specs: Array[Vector3] = [
		Vector3(18.0, -143.0, 168.0), Vector3(25.0, -147.0, 176.0),
		Vector3(32.0, -144.0, 183.0), Vector3(43.0, -146.0, 172.0),
		Vector3(51.0, -151.0, 181.0), Vector3(15.0, -156.0, 166.0),
		Vector3(59.0, -158.0, 187.0), Vector3(72.0, -165.0, 174.0),
		Vector3(88.0, -172.0, 182.0), Vector3(104.0, -179.0, 190.0)
	]
	for spec: Vector3 in infantry_specs:
		var x := spec.x
		var z := spec.y
		var soldier := spawn(INFANTRY_PRESSURE, Vector3(x, height_at(x, z) + .02, z), .085, spec.z, false)
		soldier.name = "MID_BridgeheadInfantry_%02d" % (pressure_infantry + 1)
		PRESSURE_BUDGET.apply_mid(soldier, false)
		pressure_infantry += 1
		mid_units += 1

	var vehicle_specs: Array[Vector3] = [
		Vector3(-6.0, -149.0, 176.0),
		Vector3(68.0, -146.0, 184.0)
	]
	for spec: Vector3 in vehicle_specs:
		var x := spec.x
		var z := spec.y
		var vehicle := spawn(IFV_PRESSURE, Vector3(x, height_at(x, z) + .035, z), .74, spec.z, false)
		vehicle.name = "MID_BridgeheadIFV_%02d" % (pressure_vehicles + 1)
		PRESSURE_BUDGET.apply_mid(vehicle, false)
		pressure_vehicles += 1
		mid_units += 1

func create_pressure_smoke() -> void:
	# Reuse the proven volumetric smoke shader with one shared, modest-resolution
	# noise volume. Plumes are offset from the bridge center so they add combat
	# depth without swallowing the crossing or the continuous town silhouette.
	var volume := NoiseTexture3D.new()
	volume.width = 48
	volume.height = 48
	volume.depth = 48
	volume.seamless = true
	var source := FastNoiseLite.new()
	source.seed = 1937
	source.frequency = .083
	source.fractal_octaves = 4
	volume.noise = source

	var smoke_sites: Array[Vector4] = [
		Vector4(58.0, -148.0, 32.0, 13.0),
		Vector4(122.0, -214.0, 46.0, 19.0),
		Vector4(-170.0, -390.0, 62.0, 25.0)
	]
	var opacities: Array[float] = [.15, .13, .09]
	for i in range(smoke_sites.size()):
		var site := smoke_sites[i]
		var size3 := Vector3(site.w, site.z, site.w)
		var fog := FogVolume.new()
		fog.name = "MIDFAR_CombatSmoke_%02d" % (i + 1)
		fog.size = size3
		var material := ShaderMaterial.new()
		material.shader = load("res://scripts/production/visual_slice_smoke.gdshader")
		material.set_shader_parameter("volume_noise", volume)
		material.set_shader_parameter("opacity", opacities[i])
		fog.material = material
		fog.position = Vector3(site.x, height_at(site.x, site.y) + size3.y * .44, site.y)
		add_child(fog)
		pressure_smoke += 1

func create_pressure_fire_points() -> void:
	# Small emissive debris fires provide readable contact points without adding
	# real-time OmniLight cost. They are MID-only visual evidence, not gameplay state.
	var fire_sites: Array[Vector2] = [
		Vector2(52.0, -145.0),
		Vector2(101.0, -180.0),
		Vector2(-61.0, -187.0)
	]
	for i in range(fire_sites.size()):
		var site := fire_sites[i]
		var y := height_at(site.x, site.y)

		var charred := StandardMaterial3D.new()
		charred.albedo_color = Color(.055, .045, .035)
		charred.roughness = .96
		var base_mesh := CylinderMesh.new()
		base_mesh.top_radius = 1.05
		base_mesh.bottom_radius = 1.20
		base_mesh.height = .28
		base_mesh.radial_segments = 10
		var base := add_mesh(base_mesh, charred, Vector3(site.x, y + .12, site.y))
		base.name = "MID_FireScorch_%02d" % (i + 1)
		PRESSURE_BUDGET.apply_mid(base, false)

		var outer_mat := StandardMaterial3D.new()
		outer_mat.albedo_color = Color(.72, .10, .015)
		outer_mat.roughness = .42
		outer_mat.emission_enabled = true
		outer_mat.emission = Color(1.0, .16, .015)
		outer_mat.emission_energy_multiplier = 3.4
		var outer_mesh := SphereMesh.new()
		outer_mesh.radius = .72
		outer_mesh.height = 1.85
		outer_mesh.radial_segments = 10
		outer_mesh.rings = 5
		var outer := add_mesh(outer_mesh, outer_mat, Vector3(site.x, y + 1.05, site.y), Vector3(.82, 1.35, .82))
		outer.name = "MID_FireOuter_%02d" % (i + 1)
		PRESSURE_BUDGET.apply_mid(outer, false)

		var inner_mat := StandardMaterial3D.new()
		inner_mat.albedo_color = Color(1.0, .48, .04)
		inner_mat.roughness = .30
		inner_mat.emission_enabled = true
		inner_mat.emission = Color(1.0, .42, .035)
		inner_mat.emission_energy_multiplier = 4.6
		var inner_mesh := SphereMesh.new()
		inner_mesh.radius = .38
		inner_mesh.height = 1.05
		inner_mesh.radial_segments = 8
		inner_mesh.rings = 4
		var inner := add_mesh(inner_mesh, inner_mat, Vector3(site.x, y + .85, site.y), Vector3(.70, 1.25, .70))
		inner.name = "MID_FireCore_%02d" % (i + 1)
		PRESSURE_BUDGET.apply_mid(inner, false)

		pressure_fire += 1
