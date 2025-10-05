extends CharacterBody3D
class_name EnemyFlyShoot

@export var HPnode: Health
@onready var hp = HPnode.health

@export var fireball_scene: PackedScene
@export var shoot_interval: float = 5.0
@export var speed: float = 5.0
@export var keep_distance: float = 10.0
@export var move_smoothness: float = 3.0
@export var rotation_speed: float = 5.0
@export var hover_height: float = 5.0  # height above player
@onready var fire_ball_posistion: Marker3D = $fire_ball_posistion

var player: Player = null
var alive: bool = true
var shoot_timer: float = 0.0

func _ready() -> void:
	shoot_timer = shoot_interval
	player = get_tree().get_first_node_in_group("Player") as Player

func _physics_process(delta: float) -> void:
	if not alive or player == null:
		return

	# --- Horizontal movement
	var to_player = player.global_transform.origin - global_transform.origin
	var distance = to_player.length()
	var move_dir = Vector3.ZERO

	if distance > keep_distance + 2:
		move_dir = to_player.normalized()  # move closer
	elif distance < keep_distance - 2:
		move_dir = -to_player.normalized()  # move away

	# Smooth horizontal movement
	var target_velocity = move_dir * speed
	velocity.x = lerp(velocity.x, target_velocity.x, move_smoothness * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, move_smoothness * delta)

	# --- Vertical hover
	var target_y = player.global_transform.origin.y + hover_height
	var delta_y = target_y - global_transform.origin.y
	velocity.y = lerp(velocity.y, delta_y * speed, move_smoothness * delta)

	# --- Move
	move_and_slide()

	# --- Rotate toward player (Y-axis only)
	var target_direction = player.global_transform.origin - global_transform.origin
	target_direction.y = 0
	if target_direction.length() > 0:
		target_direction = target_direction.normalized()
		var target_basis = Basis.looking_at(target_direction, Vector3.UP).orthonormalized()
		global_transform.basis = global_transform.basis.orthonormalized().slerp(target_basis, rotation_speed * delta)

	# --- Shooting
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_fireball()
		shoot_timer = shoot_interval

	# --- Death check
	if hp <= 0:
		alive = false
		death()

# --- Fireball shooting
func shoot_fireball() -> void:
	if fireball_scene == null or fire_ball_posistion == null:
		return
	var fireball = fireball_scene.instantiate() as Fireball
	get_parent().add_child(fireball)
	fireball.global_transform.origin = fire_ball_posistion.global_transform.origin
	fireball.direction = (player.global_transform.origin - fireball.global_transform.origin).normalized()

# --- Damage handling
func on_damaged(attack: Attack) -> void:
	HPnode.on_damaged(attack)
	hp = HPnode.health
	if hp <= 0:
		alive = false
		death()

func death():
	queue_free()

# --- Optional melee collision
func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var attack = Attack.new()
		attack.damage = 10
		body.on_damaged(attack)
