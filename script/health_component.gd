
extends Node
class_name Health

signal health_changed(health: float)

@export var max_health := 100.0
@export var hurtbox : Hurtbox

@onready var health := max_health
@onready var unit = get_owner()

func _ready() -> void:
	if hurtbox:
		hurtbox.damaged.connect(on_damaged)

func on_damaged(attack: Attack):
	if not unit.alive:
		return
	
	health -= attack.damage
	print("health = %d " %health , unit)
	health_changed.emit(health)
	if health <= 0:
		health = 0
		unit.alive = false

func increase_max_health(amount: float) -> void:
	max_health += amount
	health += amount
	health_changed.emit(health)

func heal(amount: float) -> void:
	if not unit.alive:
		return
	health = min(health + amount, max_health)
	health_changed.emit(health)
