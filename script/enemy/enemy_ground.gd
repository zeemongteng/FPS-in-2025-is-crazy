extends CharacterBody3D
class_name enemy_ground

@export var HPnode: Health
@onready var hp = HPnode.health

var player: Player = null
var alive: bool = true

@export var speed: float = 2.0
@export var launch_force: float = 12.0
@export var launch_speed: float = 16.0
@export var gravity: float = 20.0
@export var launch_distance: float = 30.0
@export var rotation_speed: float = 5.0   # how fast it rotates toward player

@onready var anim_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer
signal died
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return

func _physics_process(delta: float) -> void:
	if not alive:
		await death()
		return

	if player and player.alive and is_on_floor():
		look_at_player(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
		if anim_player.current_animation != "Freddy--Jumpscare":
			anim_player.play("Freddy--Jumpscare")
	else:
		velocity.y = 0
		if player and player.alive:
			var dir = player.global_transform.origin - global_transform.origin
			dir.y = 0
			var distance = dir.length()
			if distance > 0.1:
				dir = dir.normalized()
				if distance > launch_distance:
					# Launch toward player
					velocity.y = launch_force
					velocity.x = dir.x * launch_speed
					velocity.z = dir.z * launch_speed
					anim_player.play("Freddy--Jumpscare")
				else:
					# Walk toward player
					velocity.x = dir.x * speed
					velocity.z = dir.z * speed
					anim_player.play("Freddy--Charge_Loop")
			else:
				velocity.x = 0
				velocity.z = 0
				anim_player.play("Freddy--Idle")

	move_and_slide()

func look_at_player(delta: float) -> void:
	var target_dir = player.global_transform.origin - global_transform.origin
	target_dir.y = 0
	if target_dir.length() > 0.01:
		var target_rotation = atan2(target_dir.x, target_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

func death() -> void:
	alive = false
	velocity = Vector3.ZERO
	anim_player.play("Freddy--Shutdown")
	await anim_player.animation_finished
	emit_signal("died")
	queue_free()
