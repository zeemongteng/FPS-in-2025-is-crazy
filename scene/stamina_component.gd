extends Node
class_name Stamina

signal stamina_used(stamina: float)
signal dashed

@export var max_stamina := 100.0
@export var regen_rate := 10.0
@export var dash_cost := 30.0  
@export var dash_strength := 20.0  
@export var dash_duration := 0.2  

@onready var stamina := max_stamina
@onready var unit = get_owner() 

var is_dashing := false
var dash_timer := 0.0

func _process(delta: float) -> void:
	# Regenerate stamina if not dashing
	if stamina < max_stamina and not is_dashing:
		stamina += regen_rate * delta
		if stamina > max_stamina:
			stamina = max_stamina
		stamina_used.emit(stamina)

	# Handle dash duration
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

func try_dash(direction: Vector3) -> void:
	if stamina >= dash_cost and not is_dashing and direction != Vector3.ZERO:
		stamina -= dash_cost
		stamina_used.emit(stamina)

		unit.velocity += direction.normalized() * dash_strength
		is_dashing = true
		dash_timer = dash_duration
		dashed.emit()
