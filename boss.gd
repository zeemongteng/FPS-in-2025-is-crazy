extends CharacterBody3D
class_name Boss

@export var HPnode: Health
@onready var hp = HPnode.health

var player: Player = null
var alive: bool = true

@export var speed: float = 6.0
@export var gravity: float = 20.0

# Jump values
@export var min_jump_force: float = 8.0
@export var max_jump_force: float = 16.0

# Attack control
@export var attack_cooldown: float = 2.0
var attack_timer: float = 0.0

# Animation control
@onready var anim = $"King Minos/AnimationPlayer"

# Distance thresholds
@export var close_range: float = 6.0
@export var far_range: float = 15.0

var intro_played: bool = false
var attacking: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return
	play_intro()

func _physics_process(delta: float) -> void:
	if not alive:
		death()
		return
	if not player or not player.alive:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not intro_played or attacking:
		move_and_slide()
		return

	# Update attack timer
	attack_timer -= delta

	var distance = global_transform.origin.distance_to(player.global_transform.origin)

	if attack_timer <= 0:
		if distance > far_range:
			random_far_attack()
		elif distance < close_range:
			random_close_attack()
		else:
			walk_toward_player(delta)
	else:
		walk_toward_player(delta)

	move_and_slide()

func walk_toward_player(_delta: float) -> void:
	if not player:
		return

	var dir = player.global_transform.origin - global_transform.origin
	dir.y = 0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed

		# Rotate toward player
		look_at(player.global_transform.origin, Vector3.UP)

		# Play walk animation if not already playing
		if not anim.is_playing() or anim.current_animation != "minos_prime_Veins_skeleton|Walk":
			anim.play("minos_prime_Veins_skeleton|Walk")
	else:
		velocity.x = 0
		velocity.z = 0
		if anim.current_animation == "minos_prime_Veins_skeleton|Walk":
			anim.stop()

# === ATTACK SELECTION ===
func random_far_attack() -> void:
	var rand = randi() % 2
	if rand == 0:
		rush_attack()
	else:
		jump_attack()

func random_close_attack() -> void:
	var rand = randi() % 2
	if rand == 0:
		uppercut_attack()
	else:
		normal_attack()

# === ATTACK FUNCTIONS ===
func rush_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Boxing")
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(player.global_transform.origin, Vector3.UP)
	velocity.x = dir.x * speed * 1.5
	velocity.z = dir.z * speed * 1.5
	await anim.animation_finished
	reset_attack()

func jump_attack() -> void:
	attacking = true
	# Boss moves toward player while jumping
	anim.play("minos_prime_Veins_skeleton|Jump")
	var jump_force = randf_range(min_jump_force, max_jump_force)
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(player.global_transform.origin, Vector3.UP)
	velocity.y = jump_force
	velocity.x = dir.x * speed * 1.5
	velocity.z = dir.z * speed * 1.5
	await anim.animation_finished
	reset_attack()

func uppercut_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Uppercut")
	velocity = Vector3.ZERO
	await anim.animation_finished
	reset_attack()

func normal_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Combo")
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(player.global_transform.origin, Vector3.UP)
	velocity = Vector3.ZERO
	await anim.animation_finished
	reset_attack()

# === INTRO ===
func play_intro() -> void:
	anim.play("minos_prime_Veins_skeleton|Intro")
	await anim.animation_finished
	intro_played = true

# === HELPERS ===
func reset_attack() -> void:
	attacking = false
	attack_timer = attack_cooldown
	velocity = Vector3.ZERO

func death():
	anim.play("minos_prime_Veins_skeleton|Outro")
	await anim.animation_finished
	queue_free()
