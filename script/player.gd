extends CharacterBody3D
class_name Player

@export var speed: float = 15.0
@export var jump_force: float = 4.5
@export var mouse_sensitivity: float = 0.002

var alive : bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var damage = 10
var default_cam_y: float                # store original camera height
var target_cam_y: float


@onready var cam: Camera3D = $Pivot/Camera3D
@onready var health: Health = $HealthComponent
@onready var stamina: Stamina = $StaminaComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var pivot: Node3D = $Pivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	default_cam_y = cam.position.y
	target_cam_y = default_cam_y
	
	hurtbox.damaged.connect(hit)
	stamina.slide_started.connect(_on_slide_started)
	stamina.slide_ended.connect(_on_slide_ended)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Rotate camera (pitch)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	pass

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if !alive:
		%Flash.fade_to_black(2.0, 3.0, Color.BLACK, 3.6)
		await get_tree().create_timer(5).timeout
		die()
		return
	
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
		if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
			if stamina.is_sliding:
				var extra_jump = clampf(stamina.slide_momentum.length() * 0.5, 0, 100)
				velocity.y = jump_force + extra_jump
			else:
				velocity.y = jump_force
	
	if Input.is_action_just_pressed("dash"):
		stamina.try_dash(direction)
	
	if Input.is_action_pressed("slide"):
		stamina.start_slide()
	else:
		stamina.stop_slide()
	
	move_and_slide()
	
	cam.position.y = lerp(cam.position.y, target_cam_y, 8 * delta)

func die():
	DeathScene.active = true
	DeathScene.show()
	queue_free()

func _on_slide_started() -> void:
	target_cam_y = default_cam_y - 0.7

func _on_slide_ended() -> void:
	target_cam_y = default_cam_y

func hit(_attack: Attack):
	cam.shake(0.1,_attack.damage * 1.5)
