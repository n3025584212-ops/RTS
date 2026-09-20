# Gate D1 evidence driver — MINIMUM_COMBAT_CHAIN.
# Drives the validated combat cycle in the River Town mother scene: attack
# order -> range/cooldown/ammo fire loop -> validated damage matrix on the RED
# target -> progressive paint charring -> destruction. Captures fresh
# 1920x1080 media at before / engaging / destroyed stages (state-driven).
#
# Invocation:
#   godot --path . --rendering-method forward_plus --audio-driver Dummy --resolution 1920x1080 --script tools/gate_d1_capture.gd -- --view=gate_b

extends SceneTree

var frames := 0
var stage := 0
var unit: Node
var target: Node
var start_ammo := 0
var out_dir := "D:/Agent/rts_captures/gate_d1"

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/production/RiverTownVisualSlice.tscn")
	if packed == null:
		print("GATE_D1_EVIDENCE_FAIL scene_load")
		quit(1)
		return
	var node := packed.instantiate()
	root.add_child(node)
	process_frame.connect(_tick)

func _tick() -> void:
	frames += 1
	if frames > 4000:
		print("GATE_D1_EVIDENCE_FAIL timeout stage=%d" % stage)
		quit(1)
		return
	if stage == 0 and frames >= 50:
		unit = root.find_child("GateBArmoredUnit", true, false)
		target = root.find_child("GateBHostileTarget", true, false)
		if unit == null or target == null:
			if frames > 400:
				print("GATE_D1_EVIDENCE_FAIL nodes_missing")
				quit(1)
			return
		start_ammo = int(unit.call("get_ammo"))
		_snap("gate_d1_before_engagement")
		print("GATE_D1_EVIDENCE_BEFORE frame=%d blue_ammo=%d target_hp=%d" % [
			frames, start_ammo, int(target.call("get_hp"))])
		var accepted: bool = unit.call("demo_issue_attack")
		if not accepted:
			print("GATE_D1_EVIDENCE_FAIL attack_rejected")
			quit(1)
			return
		stage = 1
	elif stage == 1:
		var hp := int(target.call("get_hp"))
		if hp <= int(target.call("get_max_hp")) * 6 / 10:
			_snap("gate_d1_engaging")
			print("GATE_D1_EVIDENCE_ENGAGING frame=%d target_hp=%d blue_ammo=%d" % [
				frames, hp, int(unit.call("get_ammo"))])
			stage = 2
	elif stage == 2:
		if bool(target.call("is_destroyed")):
			_snap("gate_d1_target_destroyed")
			var final_ammo := int(unit.call("get_ammo"))
			var data := {
				"gate": "MINIMUM_COMBAT_CHAIN",
				"evidence": "FIRE_CYCLE_DAMAGE_DESTRUCTION_DEMONSTRATED",
				"capture_view": "gate_b",
				"shots_fired": start_ammo - final_ammo,
				"blue_ammo_start": start_ammo,
				"blue_ammo_end": final_ammo,
				"target_hp_start": int(target.call("get_max_hp")),
				"target_hp_end": int(target.call("get_hp")),
				"target_destroyed": true,
				"target_world_end": str(target.call("get_tank_position")),
				"capture_frames": ["gate_d1_before_engagement.png", "gate_d1_engaging.png", "gate_d1_target_destroyed.png"],
			}
			DirAccess.make_dir_recursive_absolute(out_dir)
			var f := FileAccess.open(out_dir + "/gate_d1_evidence.json", FileAccess.WRITE)
			f.store_string(JSON.stringify(data, "  ") + "\n")
			print("GATE_D1_EVIDENCE_COMPLETE shots=%d hp_end=%d ammo_end=%d" % [
				start_ammo - final_ammo, int(target.call("get_hp")), final_ammo])
			quit()

func _snap(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	var img := root.get_texture().get_image()
	img.save_png(out_dir + "/" + file_name + ".png")
	print("GATE_D1_SNAP " + file_name)
