extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_PRIMARY_IFV_MOVE_ADVANCE_INTEGRATION_SMOKE_BEGIN")
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var ifv: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var primary_red: BattleFormation = battle.get_node("RedFormation") as BattleFormation
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var intel: BattleIntelTracker = battle.get_node("IntelTracker") as BattleIntelTracker

	if ifv == null or primary_red == null or selection == null or intel == null:
		_failures.append("SETUP_INCOMPLETE")
		push_error("Primary IFV MOVE/ADVANCE integration smoke setup incomplete.")
		_finish(battle)
		return

	# Use the actual scene primary pair wired by battle01.gd: BLUE IFV-01 and the
	# primary RedFormation owned by IntelTracker.configure(). The positions are
	# deliberately clear-LOS and in IFV range so command semantics are the only gate.
	ifv.global_position = Vector2(600.0, 700.0)
	primary_red.global_position = Vector2(740.0, 700.0)
	ifv.stop()
	primary_red.stop()
	ifv.clear_combat_target()
	selection.select_only(ifv)

	# CONFIRMED must still traverse the real primary intel_state_changed callback,
	# but normal runtime must not auto-target the IFV. Plain MOVE is movement-only.
	_force_primary_intel(intel, primary_red, BattleIntelTracker.CONFIRMED)
	var move_ammo_before: int = ifv.current_ammo
	var move_fire_before: int = ifv.get_fire_serial()
	var move_hp_before: int = primary_red.current_hp
	var move_issued: int = selection.issue_move(Vector2(900.0, 700.0), 0.0)
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	var plain_move_no_fire: bool = (
		move_issued == 1
		and ifv.get_order() == "MOVE"
		and ifv.current_ammo == move_ammo_before
		and ifv.get_fire_serial() == move_fire_before
		and primary_red.current_hp == move_hp_before
	)
	_require(plain_move_no_fire, "PRIMARY_IFV_PLAIN_MOVE_NO_AUTO_FIRE_PASS")

	# The same real primary target, still CONFIRMED, must be legally acquired only
	# by ADVANCE and may then receive opportunity fire without changing destination.
	ifv.stop()
	ifv.global_position = Vector2(600.0, 700.0)
	selection.select_only(ifv)
	var advance_issued: int = selection.issue_advance(Vector2(900.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	var advance_destination: Vector2 = selection.get_advance_destination_for_test(ifv)
	var advance_ammo_before: int = ifv.current_ammo
	var advance_fire_before: int = ifv.get_fire_serial()
	var advance_hp_before: int = primary_red.current_hp
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	var advance_fired: bool = (
		advance_issued == 1
		and selection.is_advancing(ifv)
		and advance_destination.is_equal_approx(Vector2(900.0, 700.0))
		and ifv.current_ammo == advance_ammo_before - 1
		and ifv.get_fire_serial() == advance_fire_before + 1
		and primary_red.current_hp == advance_hp_before - ifv.calculate_attack_damage(primary_red)
	)
	_require(advance_fired, "PRIMARY_IFV_ADVANCE_OPPORTUNISTIC_FIRE_PASS")
	_require(plain_move_no_fire and advance_fired, "PRIMARY_IFV_MOVE_ADVANCE_DISTINCTION_PASS")

	# A reconfirm callback while plain MOVE is already active must not resurrect
	# the old player-side auto target. This is the exact QA blocker regression.
	ifv.stop()
	ifv.global_position = Vector2(600.0, 700.0)
	ifv.clear_combat_target()
	selection.select_only(ifv)
	var reconfirm_move_issued: int = selection.issue_move(Vector2(900.0, 700.0), 0.0)
	_force_primary_intel(intel, primary_red, BattleIntelTracker.LAST_KNOWN)
	_force_primary_intel(intel, primary_red, BattleIntelTracker.CONFIRMED)
	var reconfirm_move_ammo: int = ifv.current_ammo
	var reconfirm_move_fire: int = ifv.get_fire_serial()
	var reconfirm_move_hp: int = primary_red.current_hp
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	var reconfirm_move_no_fire: bool = (
		reconfirm_move_issued == 1
		and ifv.get_order() == "MOVE"
		and ifv.current_ammo == reconfirm_move_ammo
		and ifv.get_fire_serial() == reconfirm_move_fire
		and primary_red.current_hp == reconfirm_move_hp
	)
	_require(reconfirm_move_no_fire, "PRIMARY_IFV_MOVE_RECONFIRM_NO_AUTO_FIRE_PASS")

	# Reconfirm remains useful to ADVANCE: once ADVANCE is issued, the existing
	# SelectionController CONFIRMED/range/LOS gate may acquire and fire normally.
	ifv.stop()
	ifv.global_position = Vector2(600.0, 700.0)
	selection.select_only(ifv)
	var reconfirm_advance_issued: int = selection.issue_advance(Vector2(900.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	var reconfirm_advance_ammo: int = ifv.current_ammo
	var reconfirm_advance_fire: int = ifv.get_fire_serial()
	var reconfirm_advance_hp: int = primary_red.current_hp
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	var reconfirm_advance_fire_ok: bool = (
		reconfirm_advance_issued == 1
		and selection.is_advancing(ifv)
		and ifv.current_ammo == reconfirm_advance_ammo - 1
		and ifv.get_fire_serial() == reconfirm_advance_fire + 1
		and primary_red.current_hp == reconfirm_advance_hp - ifv.calculate_attack_damage(primary_red)
	)
	_require(reconfirm_advance_fire_ok, "PRIMARY_IFV_ADVANCE_RECONFIRM_FIRE_PASS")

	# MOVE is also the cleanup boundary from an existing ADVANCE fire state. Once
	# player MOVE overrides ADVANCE, the stale target/intent must not fire again.
	ifv.stop()
	ifv.global_position = Vector2(600.0, 700.0)
	selection.select_only(ifv)
	selection.issue_advance(Vector2(1000.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	var move_override_issued: int = selection.issue_move(Vector2(820.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	var clean_ammo: int = ifv.current_ammo
	var clean_fire: int = ifv.get_fire_serial()
	var clean_hp: int = primary_red.current_hp
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	var clean_state: bool = (
		move_override_issued == 1
		and ifv.get_order() == "MOVE"
		and not selection.is_advancing(ifv)
		and selection.get_advance_destination_for_test(ifv) == Vector2.ZERO
		and ifv.current_ammo == clean_ammo
		and ifv.get_fire_serial() == clean_fire
		and primary_red.current_hp == clean_hp
	)
	_require(clean_state, "ADVANCE_TO_MOVE_FIRE_STATE_CLEAN_PASS")

	_finish(battle)

func _force_primary_intel(intel: BattleIntelTracker, target: BattleFormation, state: String) -> void:
	if intel.get_intel_state_for(target) == state:
		var alternate: String = BattleIntelTracker.CONTACT if state != BattleIntelTracker.CONTACT else BattleIntelTracker.UNSEEN
		intel._set_target_state(target, alternate)
	intel._set_target_state(target, state)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)

func _finish(battle: Node) -> void:
	if _failures.is_empty():
		print("FRONTLINE_PRIMARY_IFV_MOVE_ADVANCE_INTEGRATION_SMOKE_PASS")
		if battle != null and is_instance_valid(battle):
			battle.queue_free()
		quit(0)
		return
	for failure: String in _failures:
		push_error("PRIMARY_IFV_MOVE_ADVANCE_SMOKE_FAILURE %s" % failure)
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	quit(1)
