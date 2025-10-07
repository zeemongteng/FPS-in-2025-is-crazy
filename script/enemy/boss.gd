extends CharacterBody3D
class_name BossMinosPrime

@export var HPnode: Health
@export var ground_slam: PackedScene
@export var fireball_scene: PackedScene
@onready var hp = HPnode.health
@onready var canvas_layer: Control = $CanvasLayer
@onready var intro: AudioStreamPlayer = $intro
@onready var prepare: AudioStreamPlayer = $prepare
@onready var thyend: AudioStreamPlayer = $thyend
@onready var die: AudioStreamPlayer = $die
@onready var deathscream: AudioStreamPlayer = $deathscream
@onready var crush: AudioStreamPlayer = $crush
@onready var hpbar: Hpbar = $Hpbar
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var anim = $"King Minos/AnimationPlayer"

var player: Player = null
var alive: bool = true
var dead := false
var last_attack := ""
@export var speed: float = 10.0
@export var gravity: float = 25.0
@export var jump_force: float = 15.0
@export var fireball_speed: float = 200.0

# Control
var attacking := false
var attack_timer := 0.0
@export var attack_cooldown := 0.8

# Distances
@export var close_range := 6.0
@export var far_range := 18.0

# Intro / States
var intro_played := false
var intro_playing := false

# === SOUND LIST ===
var attack_sounds: Array[AudioStreamPlayer]
var death_sounds: Array[AudioStreamPlayer]

# === READY ===
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	attack_sounds = [prepare, thyend, crush ,die]  # random attack sound pool
	death_sounds = [deathscream]         # random death sound pool
	if player:
		play_intro()
	audio_stream_player.play()

# === MAIN LOOP ===
func _physics_process(delta: float) -> void:
	if dead:
		return
	if not alive and not dead:
		death()
		return
	if not player or not player.alive:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if intro_playing and Input.is_action_just_pressed("skip"):
		skip_intro()
		canvas_layer.hide()
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
	if not player:
		return

	var attack_weights = {
		"fireball_attack": 20,
		"ground_slam_attack": 20,
		"jump_kick_attack": 15,
		"combo_attack": 20,
		"uppercut_attack": 15,
		"rush_attack": 10
	}

	if last_attack in attack_weights:
		attack_weights[last_attack] = max(attack_weights[last_attack] - 10, 5)

	var total_weight = 0
	for w in attack_weights.values():
		total_weight += w

	var pick = randi() % total_weight
	var sum = 0
	var selected_attack = ""
	for attack_name in attack_weights.keys():
		sum += attack_weights[attack_name]
		if pick < sum:
			selected_attack = attack_name
			break

	match selected_attack:
		"fireball_attack":
			fireball_attack()
		"ground_slam_attack":
			ground_slam_attack()
		"jump_kick_attack":
			jump_kick_attack()
		"combo_attack":
			combo_attack()
		"uppercut_attack":
			uppercut_attack()
		"rush_attack":
			rush_attack()

	last_attack = selected_attack

# === ATTACKS ===
func fireball_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	velocity = Vector3.ZERO
	anim.play("minos_prime_Veins_skeleton|ProjectilePunch")
	await get_tree().create_timer(0.7).timeout

	if fireball_scene and player:
		var fireball_instance = fireball_scene.instantiate()
		if fireball_instance:
			get_tree().current_scene.add_child(fireball_instance)
			fireball_instance.scale *= 2.0
			if fireball_instance is Fireball:
				fireball_instance.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
				fireball_instance.direction = (player.global_transform.origin - fireball_instance.global_transform.origin).normalized()
				fireball_instance.speed = fireball_speed

	await anim.animation_finished
	await get_tree().create_timer(0.5).timeout
	reset_attack()

func jump_kick_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	anim.play("minos_prime_Veins_skeleton|Riderkick")
	velocity.y = jump_force * 1.5
	await get_tree().create_timer(0.3).timeout

	if player:
		var dir = (player.global_transform.origin - global_transform.origin).normalized()
		velocity.x = dir.x * (speed * 4)
		velocity.z = dir.z * (speed * 4)

	await anim.animation_finished
	if is_on_floor():
		spawn_ground_slam_effect()
	reset_attack()

func rush_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	anim.play("minos_prime_Veins_skeleton|Boxing")
	teleport(0.7, 2, 7)
	await anim.animation_finished
	reset_attack()

func uppercut_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	anim.play("minos_prime_Veins_skeleton|Uppercut")
	velocity.y = jump_force * 2
	await anim.animation_finished
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.3).timeout
	reset_attack()

func ground_slam_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	anim.play("minos_prime_Veins_skeleton|Jump")
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.y = jump_force * 2
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	await anim.animation_finished
	anim.play("minos_prime_Veins_skeleton|DownSwing")
	var original_gravity = gravity
	gravity *= 3.0
	while not is_on_floor():
		await get_tree().process_frame
	gravity = original_gravity
	if is_on_floor():
		spawn_ground_slam_effect()
	await anim.animation_finished
	reset_attack()

func combo_attack() -> void:
	attacking = true
	play_random_sound(attack_sounds)
	anim.play("minos_prime_Veins_skeleton|Combo")
	teleport(0.6, 2, 4)
	await anim.animation_finished
	reset_attack()

# === INTRO / DEATH ===
func play_intro() -> void:
	intro.play()
	intro_playing = true
	anim.speed_scale = 1.0
	anim.play("minos_prime_Veins_skeleton|Intro")
	await anim.animation_finished
	await get_tree().create_timer(21).timeout
	canvas_layer.queue_free()
	if not intro_played:
		hpbar.show()
		intro_played = true
	intro_playing = false
	anim.speed_scale = 2.0

func skip_intro() -> void:
	canvas_layer.hide()
	intro.stop()
	anim.stop()
	hpbar.show()
	intro_played = true
	intro_playing = false
	print("Intro skipped!")

func death() -> void:
	anim.speed_scale = 1.0
	if dead:
		return
	dead = true
	alive = false
	reset_attack()
	play_random_sound(death_sounds)
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
	slam.global_transform.origin = global_transform.origin

# 🎵 RANDOM SOUND PICKER
func play_random_sound(sounds: Array[AudioStreamPlayer]) -> void:
	if sounds.is_empty():
		return
	var sound = sounds[randi() % sounds.size()]
	if sound.playing:
		sound.stop()
	sound.play()
