extends CharacterBody3D
class_name BossMinosPrime

@export var HPnode: Health
@onready var hp = HPnode.health

var player: Player = null
var alive: bool = true

@export var speed: float = 10.0
@export var rush_speed: float = 5.0
@export var gravity: float = 25.0
@export var jump_force: float = 15.0

# Control
var attacking := false
var can_chain := false
var attack_timer := 0.0
@export var attack_cooldown := 0.8

# Distances
@export var close_range := 6.0
@export var far_range := 18.0

# Animation
@onready var anim = $"King Minos/AnimationPlayer"

# Intro / States
var intro_played := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		play_intro()

func _physics_process(delta: float) -> void:
	if not alive:
		death()
		return
	if not player or not player.alive:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if not intro_played:
		move_and_slide()
		return

	# Always face player
	look_at(player.global_transform.origin, Vector3.UP)

	if attacking:
		move_and_slide()
		return

	attack_timer -= delta
	if attack_timer <= 0:
		select_attack()
	else:
		chase_player(delta)

	move_and_slide()

# === MOVEMENT ===
func chase_player(_delta: float) -> void:
	var dir = (player.global_transform.origin - global_transform.origin)
	dir.y = 0
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	if not anim.is_playing() or anim.current_animation != "minos_prime_Veins_skeleton|Walk":
		anim.play("minos_prime_Veins_skeleton|Walk")

# === ATTACK SELECTION ===
func select_attack() -> void:
	var distance = global_transform.origin.distance_to(player.global_transform.origin)
	var roll = randi() % 100

	if distance > far_range:
		if roll < 40:
			rush_attack()
		else:
			ground_slam_attack()
	elif distance < close_range:
		if roll < 40:
			uppercut_attack()
		elif roll < 80:
			combo_attack()
	else:
		if roll < 50:
			rush_attack()
		else:
			combo_attack()

# === ATTACKS ===

func rush_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Boxing") # fast rush punch
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.x = dir.x * rush_speed
	velocity.z = dir.z * rush_speed
	await anim.animation_finished
	reset_attack()

func uppercut_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Uppercut")
	velocity.y = jump_force
	await anim.animation_finished
	# Jump slightly to emulate launcher motion
	await get_tree().create_timer(0.3).timeout
	reset_attack()

func ground_slam_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Jump")
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.y = jump_force * 2
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	await anim.animation_finished
	anim.play("minos_prime_Veins_skeleton|DownSwing") # slam impact animation
	await anim.animation_finished
	reset_attack()

func combo_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Combo")
	velocity = Vector3.ZERO
	await anim.animation_finished
	reset_attack()


# === INTRO / DEATH ===
func play_intro() -> void:
	anim.play("minos_prime_Veins_skeleton|Intro")
	await anim.animation_finished
	intro_played = true

func death() -> void:
	alive = false
	anim.play("minos_prime_Veins_skeleton|Outro")
	await anim.animation_finished
	queue_free()

# === UTILS ===
func reset_attack() -> void:
	attacking = false
	attack_timer = attack_cooldown
	velocity = Vector3.ZERO
