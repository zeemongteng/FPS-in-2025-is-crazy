extends Node
class_name Stamina

signal stamina_used(stamina: float)
signal stamind_gained(stamina: float)

@export var max_stamina := 100.0
@export var regen_rate := 10.0  # how much stamina per second to regenerate

@onready var stamina := max_stamina
@onready var unit = get_owner()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# regenerate stamina over time
	if stamina < max_stamina:
		stamina += regen_rate * delta
		if stamina > max_stamina:
			stamina = max_stamina
