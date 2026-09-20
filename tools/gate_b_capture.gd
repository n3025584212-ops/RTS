# Gate B evidence driver — the committed provenance for the 2026-09-20 evidence run.
# Invocation used for docs/visual_baseline/gate_b_20260920/ (original log: gate_b_run.log):
#   godot --path . --rendering-method forward_plus --audio-driver Dummy --resolution 1920x1080 --script tools/gate_b_capture.gd -- --view=gate_b
# Calls demo_issue_move through the validated chain (set_selected + issue_move);
# frame thresholds are progress-based. Note: at this scene weight (~7fps) the
# 8m traversal completes in ~3 frames, so mid_move snaps can land post-arrival
# (recorded as a non-blocking audit observation). Adjust thresholds or distance
# for finer traversal coverage.
extends SceneTree

# Gate B evidence capture: drives the integrated armored unit through the
# validated control chain (select -> issue_move -> NavigationService path ->
# movement) inside the River Town mother scene and captures fresh 1920x1080
# runtime media at before / mid / arrived stages. Frame thresholds are
# state-driven, not time-driven, so the capture works at any frame rate.

var frames := 0
var stage := 0
var unit: Node
var start_pos := Vector3.ZERO
var out_dir := "D:/Agent/rts_captures/gate_b"
var move_target := Vector3(5.0, 0.0, -1.0)

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/production/RiverTownVisualSlice.tscn")
	if packed == null:
		print("GATE_B_EVIDENCE_FAIL scene_load")
		quit(1)
		return
	var node := packed.instantiate()
	root.add_child(node)
	process_frame.connect(_tick)

func _tick() -> void:
	frames += 1
	if frames > 3000:
		print("GATE_B_EVIDENCE_FAIL timeout stage=%d" % stage)
		quit(1)
		return
	if stage == 0 and frames >= 50:
		unit = root.find_child("GateBArmoredUnit", true, false)
		if unit == null:
			if frames > 400:
				print("GATE_B_EVIDENCE_FAIL unit_missing_after_400_frames")
				quit(1)
			return
		start_pos = unit.call("get_tank_position")
		_snap("gate_b_before_order")
		print("GATE_B_EVIDENCE_BEFORE frame=%d pos=%s sim=%s order=%s selected=%s" % [
			frames, str(unit.call("get_tank_position")), str(unit.call("get_sim_position")),
			str(unit.call("get_order")), str(unit.call("is_unit_selected"))])
		var accepted: bool = unit.call("demo_issue_move", move_target)
		if not accepted:
			print("GATE_B_EVIDENCE_FAIL order_rejected")
			quit(1)
			return
		print("GATE_B_EVIDENCE_ORDER_ISSUED frame=%d target=%s" % [frames, str(move_target)])
		stage = 1
	elif stage == 1 or stage == 2:
		var pos: Vector3 = unit.call("get_tank_position")
		var total := Vector2(move_target.x, move_target.z).distance_to(Vector2(start_pos.x, start_pos.z))
		var done := Vector2(pos.x, pos.z).distance_to(Vector2(start_pos.x, start_pos.z))
		var threshold := 0.35 if stage == 1 else 0.7
		if total > 0.0 and done >= total * threshold:
			_snap("gate_b_mid_move_%d" % stage)
			print("GATE_B_EVIDENCE_MID frame=%d pos=%s progress=%.2f" % [frames, str(pos), done / total])
			stage += 1
	elif stage == 3:
		var order := str(unit.call("get_order"))
		if order == "HOLD":
			var pos: Vector3 = unit.call("get_tank_position")
			_snap("gate_b_arrived")
			print("GATE_B_EVIDENCE_ARRIVED frame=%d pos=%s order=%s selected=%s" % [
				frames, str(pos), order, str(unit.call("is_unit_selected"))])
			var data := {
				"gate": "MINIMUM_ARMORED_UNIT_INTEGRATION",
				"evidence": "CONTROL_CHAIN_DEMONSTRATED",
				"capture_view": "gate_b",
				"before_world": str(start_pos),
				"order_target_world": str(move_target),
				"arrived_world": str(pos),
				"final_order": order,
				"selected": str(unit.call("is_unit_selected")),
				"capture_frames": ["gate_b_before_order.png", "gate_b_mid_move_1.png", "gate_b_mid_move_2.png", "gate_b_arrived.png"],
			}
			DirAccess.make_dir_recursive_absolute(out_dir)
			var f := FileAccess.open(out_dir + "/gate_b_evidence.json", FileAccess.WRITE)
			f.store_string(JSON.stringify(data, "  ") + "\n")
			print("GATE_B_EVIDENCE_COMPLETE before=%s arrived=%s" % [str(start_pos), str(pos)])
			quit()

func _snap(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	var img := root.get_texture().get_image()
	img.save_png(out_dir + "/" + file_name + ".png")
	print("GATE_B_SNAP " + file_name)
