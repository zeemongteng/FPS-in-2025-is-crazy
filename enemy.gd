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

var jump_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return

func _physics_process(delta: float) -> void:
	if not alive:
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

	if hp <= 0:
		alive = false
		death()

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


func on_damaged(attack: Attack) -> void:
	HPnode.on_damaged(attack)
	hp = HPnode.health
	if hp <= 0:
		alive = false
		death()

func death():
	queue_free()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var attack = Attack.new()
		attack.damage = 10
		body.damage(attack) 
