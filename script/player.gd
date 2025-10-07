extends CharacterBody3D
class_name Player

@export var speed: float = 15.0
@export var jump_force: float = 4.5
@export var mouse_sensitivity: float = 0.002

var alive : bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var damage = 10
var default_cam_y: float
var target_cam_y: float
var was_on_floor: bool = true  # to track landing/footstep state

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
			if $Jump:
				$Jump.play()

	# Dash
	if Input.is_action_just_pressed("dash"):
		stamina.try_dash(direction)
	
	# Slide
	if Input.is_action_pressed("slide"):
		stamina.start_slide()
	else:
		stamina.stop_slide()
	
	move_and_slide()
	
	# Smooth camera height for slide
	cam.position.y = lerp(cam.position.y, target_cam_y, 8 * delta)
	
	# Footstep sound when walking
	if is_on_floor() and direction.length() > 0:
		if !$Footstep.playing:
			$Footstep.play()
			$Footstep.pitch_scale = randf_range(0.95, 1.05)
	else:
		if $Footstep.playing:
			$Footstep.stop()

	# Landing sound (optional): detect when player lands after a jump/fall
	if !was_on_floor and is_on_floor():
		if $Footstep:
			$Footstep.play()

	was_on_floor = is_on_floor()

func die():
	$Landing.play()
	DeathScene.active = true
	DeathScene.show()
	queue_free()

func _on_slide_started() -> void:
	target_cam_y = default_cam_y - 0.7

func _on_slide_ended() -> void:
	target_cam_y = default_cam_y

func hit(_attack: Attack):
	cam.shake(0.1, _attack.damage * 1.5)
	%Flash.flash(0.1, Color.RED,0.3)
	$hit.play()
