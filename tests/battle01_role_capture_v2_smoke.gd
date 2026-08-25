extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_ROLE_CAPTURE_V2_SMOKE_BEGIN")
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var recon: BattleFormation = battle.get_node("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var ifv: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var red_infantry: BattleFormation = roster.enemy_infantry[0]
	var red_armor: BattleFormation = roster.enemy_armor[0]

	_require(recon.ammo_capacity == 18, "RECON_AMMO_18_PASS")
	_require(infantry.ammo_capacity == 24, "INFANTRY_AMMO_24_PASS")
	_require(ifv.ammo_capacity == 28, "IFV_AMMO_28_PASS")
	_require(red_armor.ammo_capacity == 16, "ARMOR_AMMO_16_PASS")

	_require(not recon.can_capture and not recon.can_contest, "RECON_NO_CAPTURE_NO_CONTEST_PASS")
	_require(infantry.can_capture and infantry.can_contest, "INFANTRY_CAPTURE_CONTEST_PASS")
	_require(ifv.can_capture and ifv.can_contest, "IFV_CAPTURE_CONTEST_PASS")
	_require(not red_armor.can_capture and red_armor.can_contest, "ARMOR_CONTEST_ONLY_PASS")
	_require(not supply.can_capture and not supply.can_contest, "LOGISTICS_NO_CAPTURE_NO_CONTEST_PASS")

	_require(recon.calculate_attack_damage(red_armor) == 2, "RECON_VS_HEAVY_DAMAGE_PASS")
	_require(infantry.calculate_attack_damage(red_armor) == 5, "INFANTRY_VS_HEAVY_DAMAGE_PASS")
	_require(ifv.calculate_attack_damage(red_infantry) == 30, "IFV_VS_SOFT_DAMAGE_PASS")
	_require(ifv.calculate_attack_damage(red_armor) == 13, "IFV_VS_HEAVY_DAMAGE_PASS")
	_require(red_armor.calculate_attack_damage(ifv) == 61, "ARMOR_VS_LIGHT_DAMAGE_PASS")

	ifv.set_visibility_field(null)
	red_armor.set_visibility_field(null)
	ifv.global_position = Vector2(1000.0, 1000.0)
	red_armor.global_position = Vector2(1100.0, 1000.0)
	var hp_before: int = red_armor.current_hp
	var ammo_before: int = ifv.current_ammo
	ifv.set_combat_target(red_armor)
	ifv._update_combat()
	_require(red_armor.current_hp == hp_before - 13, "LIVE_ROLE_DAMAGE_APPLIED_PASS")
	_require(ifv.current_ammo == ammo_before - 1, "LIVE_ROLE_DAMAGE_AMMO_COST_PASS")
	ifv.clear_combat_target()

	_move_all_away(battle, roster)
	central.force_owner_for_test(BattleObjective.OWNER_AI)
	recon.global_position = central.global_position
	central._process(5.0)
	_require(central.get_control_owner() == BattleObjective.OWNER_AI and central.progress == 0.0 and not central.is_contested(), "RECON_CANNOT_STEAL_OBJECTIVE_PASS")

	_move_all_away(battle, roster)
	central.force_owner_for_test(BattleObjective.OWNER_AI)
	infantry.global_position = central.global_position
	central._process(15.1)
	_require(central.get_control_owner() == BattleObjective.OWNER_PLAYER, "INFANTRY_CAPTURE_OWNERSHIP_PASS")
	_require(bool(flow.get_reserve_status()["unlocked"]), "GROUND_CONTROL_RESERVE_UNLOCK_PASS")

	_move_all_away(battle, roster)
	central.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	red_armor.global_position = central.global_position
	central._process(15.1)
	_require(central.get_control_owner() == BattleObjective.OWNER_PLAYER and central.progress == 0.0, "ARMOR_CANNOT_CAPTURE_OWNERSHIP_PASS")

	_move_all_away(battle, roster)
	central.force_owner_for_test(BattleObjective.OWNER_AI)
	infantry.global_position = central.global_position
	red_armor.global_position = central.global_position
	central._process(1.0)
	_require(central.is_contested() and central.progress == 0.0 and central.get_control_owner() == BattleObjective.OWNER_AI, "ARMOR_DENIES_ENEMY_CAPTURE_PASS")

	# Losing all current ground-control formations is still recoverable while the
	# unlocked reserve can be committed to Infantry.
	infantry.take_damage(infantry.max_hp + 1)
	ifv.take_damage(ifv.max_hp + 1)
	flow.force_evaluate_match_state()
	_require(not flow.is_match_finished() and bool(flow.get_reserve_status()["deployable"]), "UNUSED_INFANTRY_OPTION_PREVENTS_GROUND_CONTROL_DEFEAT_PASS")

	# If the one reserve choice is instead spent on Armor, Recon/Armor/Logistics can
	# still fight or contest but cannot establish the ownership needed for Victory.
	var reserve_armor: BattleFormation = flow.deploy_reserve("ARMOR")
	flow.force_evaluate_match_state()
	_require(reserve_armor != null and not reserve_armor.can_capture and reserve_armor.can_contest, "RESERVE_ARMOR_CONTEST_ONLY_PASS")
	_require(flow.is_match_finished() and not flow.is_victory(), "NO_GROUND_CONTROL_SOFTLOCK_DEFEAT_PASS")

	if _failures.is_empty():
		print("FRONTLINE_ROLE_CAPTURE_V2_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("ROLE_CAPTURE_V2_SMOKE_FAILURE %s" % failure)
		quit(1)

func _move_all_away(battle: Node2D, roster: BattleFormalCombatRoster) -> void:
	var all_formations: Array[BattleFormation] = [
		battle.get_node("BlueRecon") as BattleFormation,
		battle.get_node("BlueInfantry") as BattleFormation,
		battle.get_node("BlueFormation") as BattleFormation,
		battle.get_node("BlueSupply") as BattleFormation,
	]
	all_formations.append_array(roster.get_initial_enemy_combat_formations())
	all_formations.append_array(roster.get_initial_supply_trucks())
	all_formations.append_array(roster.get_reinforcement_formations())
	var index: int = 0
	for formation: BattleFormation in all_formations:
		if formation == null:
			continue
		formation.global_position = Vector2(300.0 + float(index * 20), 300.0)
		index += 1

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
