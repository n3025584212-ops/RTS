class_name FormationDefinition
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var role: String = ""
@export var move_speed: float = 100.0
@export var max_hp: int = 100
@export var can_attack: bool = true
@export var attack_damage: int = 0
@export var attack_range: float = 0.0
@export var fire_interval: float = 1.0
@export var ammo_capacity: int = 0
@export var detection_range: float = 250.0
@export var can_capture: bool = true
@export var indirect_fire: bool = false
@export var supply_capacity: int = 0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id.is_empty():
		errors.append("id is empty")
	if display_name.is_empty():
		errors.append("display_name is empty")
	if role.is_empty():
		errors.append("role is empty")
	if move_speed < 0.0:
		errors.append("move_speed < 0")
	if max_hp <= 0:
		errors.append("max_hp <= 0")
	if can_attack:
		if attack_damage <= 0:
			errors.append("attack_damage <= 0 for attacking formation")
		if attack_range <= 0.0:
			errors.append("attack_range <= 0 for attacking formation")
		if fire_interval <= 0.0:
			errors.append("fire_interval <= 0 for attacking formation")
		if ammo_capacity <= 0:
			errors.append("ammo_capacity <= 0 for attacking formation")
	return errors
