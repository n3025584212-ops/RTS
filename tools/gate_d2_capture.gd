# Gate D2 evidence driver — MULTI_FORMATION_SELECTION.
# Drives the armour platoon through the same entry points the mouse path uses:
# single-click select -> drag marquee (begin) -> release (box select) -> group
# order with formation-preserving lateral spread. Captures fresh 1920x1080 media
# at each stage; every stage asserts before it advances, so a broken selection or
# a scrambled formation fails the run instead of producing pretty evidence.
#
# Output goes to user:// (per the Gate D1 audit suggestion); OS.get_user_data_dir()
# is printed so the frames can be copied into docs/visual_baseline/.
#
# Invocation:
#   godot --path . --rendering-method forward_plus --audio-driver Dummy --resolution 1920x1080 --script tools/gate_d2_capture.gd -- --view=gate_d2
extends SceneTree

const SELECT_INDICES: Array[int] = [0, 1, 2, 3]
const GROUP_BASE := Vector3(11.5, 0.0, -6.0)
const MIN_ADVANCE_WORLD := 8.0
const FRONTAGE_TOLERANCE := 0.5
## The platoon spawns at a 6.0 m frontage and the platoon's declared order pitch
## is 8.0 m, so a group order must open the line out to 8.0 m.
const EXPECTED_FRONTAGE := 8.0

var frames := 0
var stage := 0
var platoon: Node
var start_positions := {}
var click_selected := 0
var marquee_rect := Rect2()
var out_dir := "user://gate_d2"

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/production/RiverTownVisualSlice.tscn")
	if packed == null:
		print("GATE_D2_EVIDENCE_FAIL scene_load")
		quit(1)
		return
	root.add_child(packed.instantiate())
	process_frame.connect(_tick)

func _tick() -> void:
	frames += 1
	if frames > 4000:
		print("GATE_D2_EVIDENCE_FAIL timeout stage=%d" % stage)
		quit(1)
		return
	if stage == 0 and frames >= 50:
		platoon = root.find_child("GateD2ArmorPlatoon", true, false)
		if platoon == null:
			if frames > 400:
				print("GATE_D2_EVIDENCE_FAIL platoon_missing")
				quit(1)
			return
		print("GATE_D2_EVIDENCE user_data_dir=", OS.get_user_data_dir())
		var unit_count := int(platoon.call("get_unit_count"))
		if unit_count != SELECT_INDICES.size():
			print("GATE_D2_EVIDENCE_FAIL platoon_size count=%d" % unit_count)
			quit(1)
			return
		_snap("gate_d2_before_selection")
		print("GATE_D2_EVIDENCE_BEFORE frame=%d platoon_units=%d selected=%d" % [
			frames, unit_count, int(platoon.call("selected_count"))])
		stage = 1
	elif stage == 1 and frames >= 53:
		# Single-click path: one click selects exactly one vehicle.
		if not bool(platoon.call("demo_click_select", 0)):
			print("GATE_D2_EVIDENCE_FAIL click_select_rejected")
			quit(1)
			return
		click_selected = int(platoon.call("selected_count"))
		if click_selected != 1:
			print("GATE_D2_EVIDENCE_FAIL click_select_count count=%d" % click_selected)
			quit(1)
			return
		stage = 2
	elif stage == 2 and frames >= 56:
		# Snapped three frames after the click: the viewport texture returned by a
		# snapshot is the last rendered frame, so a state change and its snapshot
		# must not share a frame or the evidence shows the previous state.
		_snap("gate_d2_click_selected")
		print("GATE_D2_EVIDENCE_CLICK frame=%d selected=%d" % [frames, click_selected])
		# Drag-box phase 1: the marquee the sweep draws is on screen; the
		# selection itself is still the pre-drag one (unit 0 from the click).
		marquee_rect = platoon.call("demo_drag_begin", SELECT_INDICES)
		if not bool(platoon.call("is_marquee_active")):
			print("GATE_D2_EVIDENCE_FAIL marquee_not_active")
			quit(1)
			return
		stage = 3
	elif stage == 3 and frames >= 59:
		_snap("gate_d2_drag_marquee")
		print("GATE_D2_EVIDENCE_MARQUEE frame=%d rect=%s selected_mid_drag=%d" % [
			frames, str(marquee_rect), int(platoon.call("selected_count"))])
		# Drag-box phase 2: release applies the box selection.
		platoon.call("demo_drag_release")
		if bool(platoon.call("is_marquee_active")):
			print("GATE_D2_EVIDENCE_FAIL marquee_still_active_after_release")
			quit(1)
			return
		stage = 4
	elif stage == 4 and frames >= 62:
		var count := int(platoon.call("selected_count"))
		if count != SELECT_INDICES.size():
			print("GATE_D2_EVIDENCE_FAIL box_select_count count=%d" % count)
			quit(1)
			return
		_snap("gate_d2_box_selected")
		print("GATE_D2_EVIDENCE_SELECTED frame=%d count=%d" % [frames, count])
		start_positions = platoon.call("get_selected_start_positions")
		platoon.call("demo_group_move", GROUP_BASE)
		stage = 5
	elif stage == 5:
		if not start_positions.is_empty() and _formation_settled():
			_snap("gate_d2_group_moved")
			var ok := _write_evidence(_current_positions())
			quit(0 if ok else 1)

# --- assertions -----------------------------------------------------------

func _current_positions() -> Dictionary:
	var result := {}
	for key: String in start_positions.keys():
		var unit_node: Node = platoon.call("get_unit_by_name", key)
		result[key] = unit_node.call("get_tank_position")
	return result

func _formation_settled() -> bool:
	for key: String in start_positions.keys():
		var unit_node: Node = platoon.call("get_unit_by_name", key)
		if unit_node == null:
			return false
		if str(unit_node.call("get_order")) != "HOLD":
			return false
		var start: Vector3 = start_positions[key]
		var current: Vector3 = unit_node.call("get_tank_position")
		if Vector2(current.x, current.z).distance_to(Vector2(start.x, start.z)) < MIN_ADVANCE_WORLD:
			return false
	return true

func _mean_frontage(positions: Dictionary, names: Array) -> float:
	var sorted_x: Array[float] = []
	for key: String in names:
		var position3: Vector3 = positions[key]
		sorted_x.append(position3.x)
	sorted_x.sort()
	if sorted_x.size() < 2:
		return 0.0
	return (sorted_x[sorted_x.size() - 1] - sorted_x[0]) / float(sorted_x.size() - 1)

func _order_preserved(names: Array, moved: Dictionary) -> bool:
	# The left-to-right order of the platoon must survive the group order; a
	# group order that crosses paths would flip this.
	for i in range(names.size()):
		for j in range(i + 1, names.size()):
			var start_i: Vector3 = start_positions[names[i]]
			var start_j: Vector3 = start_positions[names[j]]
			var end_i: Vector3 = moved[names[i]]
			var end_j: Vector3 = moved[names[j]]
			if signf(start_i.x - start_j.x) != signf(end_i.x - end_j.x):
				return false
	return true

func _write_evidence(moved: Dictionary) -> bool:
	var names: Array = start_positions.keys()
	var minimum_advance := INF
	var maximum_advance := 0.0
	for key: String in names:
		var end: Vector3 = moved[key]
		var start: Vector3 = start_positions[key]
		var distance := Vector2(end.x, end.z).distance_to(Vector2(start.x, start.z))
		minimum_advance = minf(minimum_advance, distance)
		maximum_advance = maxf(maximum_advance, distance)
	var frontage_start := _mean_frontage(start_positions, names)
	var frontage_end := _mean_frontage(moved, names)
	var order_ok := _order_preserved(names, moved)
	# The algorithm's invariant: the settled frontage is max(declared pitch,
	# spawn frontage) — a bunched group opens out, a wider one keeps its width.
	var expected := maxf(EXPECTED_FRONTAGE, frontage_start)
	var frontage_ok := absf(frontage_end - expected) <= FRONTAGE_TOLERANCE
	if not order_ok:
		print("GATE_D2_EVIDENCE_FAIL lateral_order_scrambled")
	if not frontage_ok:
		print("GATE_D2_EVIDENCE_FAIL frontage_expected=%.3f measured=%.3f" % [expected, frontage_end])
	var data := {
		"gate": "MULTI_FORMATION_SELECTION",
		"evidence": "CLICK_SELECT_DRAG_BOX_SELECT_AND_GROUP_MOVE_DEMONSTRATED",
		"capture_view": "gate_d2",
		"platoon_units": names.size(),
		"click_select_index": 0,
		"click_selected_count": click_selected,
		"marquee_rect_px": str(marquee_rect),
		"selected_unit_names": names,
		"start_positions": start_positions,
		"end_positions": moved,
		"group_base_destination": str(GROUP_BASE),
		"minimum_advance_world": snappedf(minimum_advance, 0.001),
		"maximum_advance_world": snappedf(maximum_advance, 0.001),
		"frontage_start_world": snappedf(frontage_start, 0.001),
		"frontage_end_world": snappedf(frontage_end, 0.001),
		"expected_frontage_world": snappedf(expected, 0.001),
		"lateral_order_preserved": order_ok,
		"frontage_preserved": frontage_ok,
		"capture_frames": [
			"gate_d2_before_selection.png", "gate_d2_click_selected.png",
			"gate_d2_drag_marquee.png", "gate_d2_box_selected.png",
			"gate_d2_group_moved.png",
		],
	}
	DirAccess.make_dir_recursive_absolute(out_dir)
	var f := FileAccess.open(out_dir + "/gate_d2_evidence.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "  ") + "\n")
	print("GATE_D2_EVIDENCE_ASSERT minimum_advance=%.3f frontage_start=%.3f frontage_end=%.3f expected=%.3f order_preserved=%s frontage_preserved=%s" % [
		minimum_advance, frontage_start, frontage_end, expected, str(order_ok), str(frontage_ok)])
	print("GATE_D2_EVIDENCE_COMPLETE moved=%s" % str(moved))
	return order_ok and frontage_ok

func _snap(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	var img := root.get_texture().get_image()
	img.save_png(out_dir + "/" + file_name + ".png")
	print("GATE_D2_SNAP " + file_name)
