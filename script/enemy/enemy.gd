extends CharacterBody3D
class_name enemy

@export var HPnode : Health
@onready var hp = HPnode.health

var player: Player = null
var alive: bool = true

@export var speed: float = 8.0              
@export var min_jump_force: float = 8.0    
@export var max_jump_force: float = 16.0   
@export var gravity: float = 20.0
@export var jump_cooldown: float = 0.5      
@export var blood_scene: PackedScene
var jump_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return

func _physics_process(delta: float) -> void:
	if not alive:
		death()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = 0
		velocity.z = 0
		jump_timer -= delta
		if jump_timer <= 0 and player and player.alive:
			random_jump_toward_player()
			jump_timer = jump_cooldown

	move_and_slide()

func random_jump_toward_player() -> void:
	if not player: 
		return
	
	var jump_force = randf_range(min_jump_force, max_jump_force)

	var dir = player.global_transform.origin - global_transform.origin
	dir.y = 0
	if dir.length() > 0.1:
		dir = dir.normalized()
	else:
		dir = Vector3.ZERO

	velocity.y = jump_force
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func death():
	var blood = blood_scene.instantiate()
	blood.global_transform = global_transform
	get_tree().current_scene.add_child(blood)
	queue_free()
