extends Node
class_name Stamina

signal stamina_used(stamina: float)
signal dashed
signal slide_started
signal slide_ended

@export_group("Dashing")
@export var max_stamina := 100.0
@export var regen_rate := 10.0
@export var dash_cost := 30.0  
@export var dash_strength := 50  
@export var dash_duration := 0.7

@export_group("Sliding")
@export var slide_drain_rate := 20.0  
@export var slide_friction := 0.96 

@onready var stamina := max_stamina
@onready var unit = get_owner() 

var is_dashing := false
var dash_timer := 0.0

var is_sliding := false
var slide_momentum := Vector3.ZERO

func _process(delta: float) -> void:
	# Regenerate stamina when not sliding or dashing
	if stamina < max_stamina and not is_dashing and not is_sliding:
		stamina += regen_rate * delta
		if stamina > max_stamina:
			stamina = max_stamina
		stamina_used.emit(stamina)

	# Dash handling
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	if is_sliding:
		stamina -= slide_drain_rate * delta
		if stamina <= 0:
			stamina = 0
			stop_slide()
		else:
			stamina_used.emit(stamina)

		unit.velocity.x = slide_momentum.x
		unit.velocity.z = slide_momentum.z
		slide_momentum *= slide_friction

		# auto-stop if we lose too much speed
		if slide_momentum.length() < 0.5:
			stop_slide()

func try_dash(direction: Vector3) -> void:
	if stamina >= dash_cost and not is_dashing and direction != Vector3.ZERO:
		stamina -= dash_cost
		stamina_used.emit(stamina)
		unit.velocity += direction.normalized() * dash_strength
		is_dashing = true
		dash_timer = dash_duration
		dashed.emit()

func start_slide() -> void:
	if not is_sliding and stamina > 0 and unit.is_on_floor():
		is_sliding = true
		slide_momentum = Vector3(unit.velocity.x, 0, unit.velocity.z)
		slide_started.emit()

func stop_slide() -> void:
	if is_sliding:
		is_sliding = false
		slide_ended.emit()
