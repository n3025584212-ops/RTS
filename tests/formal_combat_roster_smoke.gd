extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures.append(message)
	push_error("FORMAL_ROSTER_SMOKE_FAIL: " + message)

func _run() -> void:
	var packed: PackedScene = load("res://scenes/battle01/Battle01.tscn") as PackedScene
	_check(packed != null, "Battle01 scene loads")
	if packed == null:
		_finish()
		return

	var battle: Node = packed.instantiate()
	get_root().add_child(battle)
	await process_frame

	var roster: BattleFormalCombatRoster = battle.get_node_or_null("FormalCombatRoster") as BattleFormalCombatRoster
	_check(roster != null, "FormalCombatRoster exists")
	if roster == null:
		_finish()
		return

	var counts: Dictionary = roster.get_roster_counts()
	_check(counts.get("enemy_infantry", 0) == 2, "Enemy Infantry x2")
	_check(counts.get("enemy_armor", 0) == 1, "Enemy Armor x1")
	_check(counts.get("enemy_supply_truck", 0) == 1, "Enemy Supply Truck x1")
	_check(counts.get("reinforcement_infantry", 0) == 1, "Reinforcement Infantry x1")
	_check(counts.get("reinforcement_armor", 0) == 1, "Reinforcement Armor x1")

	var infantry: Array[BattleFormation] = roster.enemy_infantry
	var armor: BattleFormation = roster.enemy_armor[0]
	var truck: BattleFormation = roster.enemy_supply_trucks[0]
	var reinforcement_inf: BattleFormation = roster.reinforcement_infantry[0]
	var reinforcement_arm: BattleFormation = roster.reinforcement_armor[0]

	for unit: BattleFormation in infantry:
		_check(unit.max_hp == 100, "Infantry MAX_HP=100")
		_check(unit.attack_damage == 14, "Infantry damage=14")
		_check(is_equal_approx(unit.attack_range, 220.0), "Infantry range=220")
		_check(is_equal_approx(unit.fire_interval, 0.90), "Infantry fire interval=0.90")
		_check(unit.ammo_capacity == 36, "Infantry ammo=36")
		_check(is_equal_approx(unit.move_speed, 115.0), "Infantry speed=115")

	_check(armor.max_hp == 280, "Armor MAX_HP=280")
	_check(armor.attack_damage == 45, "Armor damage=45")
	_check(is_equal_approx(armor.attack_range, 300.0), "Armor range=300")
	_check(is_equal_approx(armor.fire_interval, 1.50), "Armor fire interval=1.50")
	_check(armor.ammo_capacity == 24, "Armor ammo=24")
	_check(is_equal_approx(armor.move_speed, 85.0), "Armor speed=85")

	_check(truck.max_hp == 120, "Supply Truck MAX_HP=120")
	_check(is_equal_approx(truck.move_speed, 100.0), "Supply Truck speed=100")
	_check(not truck.can_attack, "Supply Truck cannot attack")
	_check(not truck.can_capture, "Supply Truck cannot capture")
	_check(truck.supply_capacity == 2, "Supply Truck charges=2")

	_check(reinforcement_inf.process_mode == Node.PROCESS_MODE_DISABLED, "Reinforcement Infantry dormant")
	_check(reinforcement_arm.process_mode == Node.PROCESS_MODE_DISABLED, "Reinforcement Armor dormant")
	_check(not reinforcement_inf.visible, "Reinforcement Infantry hidden until Window 04 activation")
	_check(not reinforcement_arm.visible, "Reinforcement Armor hidden until Window 04 activation")

	_check(battle.get_node_or_null("Navigation") != null, "Navigation preserved")
	_check(battle.get_node_or_null("VisibilityField") != null, "Terrain/Smoke LOS preserved")
	_check(battle.get_node_or_null("BlueRecon") != null, "Recon preserved")
	_check(battle.get_node_or_null("SelectionController") != null, "Multi-Formation command preserved")

	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS")
		quit(0)
		return
	print("FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_FAIL count=%d" % failures.size())
	quit(1)
