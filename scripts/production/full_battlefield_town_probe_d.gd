extends "res://scripts/production/full_battlefield_town_probe_c.gd"
## Probe D restores the original V7 destruction-fragment MultiMesh on top of the
## already-proven asymmetric layout, V7 house mix, and four parcel walls.
## If this passes, the full authored V7 town content is independently proven.

const PROBE_D_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	add_probe_d_rubble()
	print("FRONTLINE_TOWN_PROBE_D_READY layout=authored_asymmetric assets=v7_original walls=4 rubble=145")

func add_probe_d_rubble() -> void:
	var rubble_centers: Array[Vector2] = [
		Vector2(-72.0, -205.0), Vector2(-45.0, -222.0),
		Vector2(29.0, -211.0), Vector2(159.0, -207.0),
		Vector2(44.0, -174.0)
	]
	var rubble_mesh := fragment_mesh(771)
	var rubble_mat := surface("plastered_wall_02", Color(.46, .43, .38), .55)
	var transforms: Array[Transform3D] = []
	var rr := RandomNumberGenerator.new()
	rr.seed = 55891
	for i in range(145):
		var center: Vector2 = rubble_centers[i % rubble_centers.size()]
		var x := center.x + rr.randf_range(-9.0, 9.0)
		var z := center.y + rr.randf_range(-7.0, 7.0)
		var size3 := Vector3(rr.randf_range(.12, .46), rr.randf_range(.08, .27), rr.randf_range(.14, .52))
		var basis := Basis.from_euler(Vector3(rr.randf_range(-.45, .45), rr.randf() * TAU, rr.randf_range(-.35, .35))).scaled(size3)
		transforms.append(Transform3D(basis, Vector3(x, height_at(x, z) + .05, z)))

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rubble_mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])

	var rubble := MultiMeshInstance3D.new()
	rubble.name = "MID_ProbeD_AuthoredDamageClusters"
	rubble.multimesh = mm
	rubble.material_override = rubble_mat
	add_child(rubble)
	PROBE_D_BUDGET.apply_mid(rubble, false)
