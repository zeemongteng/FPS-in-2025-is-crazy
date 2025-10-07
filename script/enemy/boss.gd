extends CharacterBody3D
class_name BossMinosPrime

@export var HPnode: Health
@export var ground_slam : PackedScene
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
@onready var hpbar: Hpbar = $Hpbar

# Intro / States
var intro_played := false
var intro_playing := false

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
	
	if intro_playing and Input.is_action_just_pressed("skip"):
		skip_intro()
		return

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
	anim.play("minos_prime_Veins_skeleton|Boxing")
	teleport(1.4, 1.5, 5)
	await anim.animation_finished
	reset_attack()

func uppercut_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Uppercut")
	velocity.y = jump_force * 2
	await anim.animation_finished
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.3).timeout
	reset_attack()

func ground_slam_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Jump")

	# Jump towards player
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.y = jump_force * 2
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	await anim.animation_finished

	# Slam impact
	velocity = Vector3.ZERO
	anim.play("minos_prime_Veins_skeleton|DownSwing")

	# Wait until he hits the ground before spawning the shockwave
	await get_tree().create_timer(0.3).timeout  # tweak for timing

	if is_on_floor():
		spawn_ground_slam_effect()

	await anim.animation_finished
	reset_attack()


func combo_attack() -> void:
	attacking = true
	anim.play("minos_prime_Veins_skeleton|Combo")
	teleport(1.2, 1.5, 4)
	await anim.animation_finished
	reset_attack()

# === INTRO / DEATH ===
func play_intro() -> void:
	intro_playing = true
	anim.play("minos_prime_Veins_skeleton|Intro")
	await anim.animation_finished
	if not intro_played:  # If not skipped
		hpbar.show()
		intro_played = true
	intro_playing = false

func skip_intro() -> void:
	anim.stop()
	hpbar.show()
	intro_played = true
	intro_playing = false
	print("Intro skipped!")

func death() -> void:
	alive = false
	reset_attack()
	anim.play("minos_prime_Veins_skeleton|Outro")
	await anim.animation_finished
	queue_free()

# === UTILS ===
func reset_attack() -> void:
	attacking = false
	attack_timer = attack_cooldown
	velocity = Vector3.ZERO

func teleport(time, distance, n):
	velocity = Vector3.ZERO
	for i in range(n):
		if player and player.is_inside_tree():
			var target_pos = player.global_transform.origin
			var offset_dir = (global_transform.origin - target_pos).normalized()
			var warp_distance = distance
			global_transform.origin = target_pos + offset_dir * warp_distance
		await get_tree().create_timer(time).timeout
func spawn_ground_slam_effect():
	if not ground_slam:
		push_warning("No ground_slam scene assigned!")
		return

	var slam = ground_slam.instantiate()
	get_tree().current_scene.add_child(slam)
	
	# Place it at boss's feet
	slam.global_transform.origin = global_transform.origin
