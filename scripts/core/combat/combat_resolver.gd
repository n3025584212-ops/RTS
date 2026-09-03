class_name CombatResolver
extends RefCounted

static func resolve_damage(base_damage: int, multiplier: float = 1.0) -> int:
	if base_damage <= 0 or multiplier <= 0.0:
		return 0
	return maxi(1, int(round(float(base_damage) * multiplier)))

static func can_fire(attacker: FormationState, target: FormationState, hold_fire: bool = false) -> bool:
	return (
		attacker != null
		and target != null
		and attacker.is_alive
		and target.is_alive
		and not hold_fire
		and attacker.current_ammo > 0
	)

static func apply_attack(
	attacker: FormationState,
	target: FormationState,
	base_damage: int,
	multiplier: float = 1.0,
	hold_fire: bool = false
) -> int:
	if not can_fire(attacker, target, hold_fire):
		return 0
	var damage: int = resolve_damage(base_damage, multiplier)
	if damage <= 0 or not attacker.spend_ammo(1):
		return 0
	return target.apply_damage(damage)
