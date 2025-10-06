extends CharacterBody3D
class_name Player

@export var speed: float = 6.0
@export var jump_force: float = 4.5
@export var mouse_sensitivity: float = 0.002

var alive : bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var damage = 10

@onready var cam: Camera3D = $Camera3D
@onready var health: Health = $HealthComponent

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate player (yaw  dwL:M 
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Rotate camera (pitch)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		# Clamp vertical rotation to avoid flipping
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if !alive:
		die()
	
	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
	if Input.is_action_pressed("ui_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else: 
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	move_and_slide()

func die():
	get_tree().reload_current_scene()
