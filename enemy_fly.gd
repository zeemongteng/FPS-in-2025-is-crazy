extends CharacterBody3D
class_name Enemy_fly

@export var HPnode: Health
@onready var hp = HPnode.health

var player: Player = null
var alive: bool = true


@export var fly_speed: float = 8.0           
@export var rush_speed: float = 25.0         
@export var rush_duration: float = 0.6
@export var cooldown: float = 2.0
@export var fly_height: float = 6.0          
@export var fly_up_force: float = 20.0       

var rush_timer: float = 0.0
var cooldown_timer: float = 0.0
var is_rushing: bool = false
var hit_player: bool = false
var direction: Vector3 = Vector3.ZERO

var circle_angle: float = 0.0
@export var circle_radius: float = 6.0
@export var circle_speed: float = 2.0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	cooldown_timer = randf_range(0.5, cooldown)


func _physics_process(delta: float) -> void:
	if not alive or player == null:
		return

	if is_on_floor():
		velocity.y = fly_up_force 

	if is_rushing:
		handle_rush(delta)
	else:
		handle_hover(delta)
	var target_rot = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(global_transform.origin + target_rot, Vector3.UP)
	move_and_slide()

	if hp <= 0:
		alive = false
		death()


func handle_hover(delta: float) -> void:
	var player_pos = player.global_transform.origin
	var self_pos = global_transform.origin

	circle_angle += circle_speed * delta
	var offset = Vector3(cos(circle_angle), 0, sin(circle_angle)) * circle_radius

	var target = player_pos + offset
	target.y = player_pos.y + fly_height

	var dir = (target - self_pos).normalized()
	velocity = dir * fly_speed

	cooldown_timer -= delta
	if cooldown_timer <= 0:
		start_rush()


func handle_rush(delta: float) -> void:
	rush_timer -= delta
	velocity = direction * rush_speed

	if rush_timer <= 0:
		is_rushing = false


func start_rush() -> void:
	if not player:
		return

	var to_player = (player.global_transform.origin - global_transform.origin)
	if to_player.length() > 0.1:
		direction = to_player.normalized()
	else:
		direction = Vector3.ZERO

	is_rushing = true
	hit_player = false
	rush_timer = rush_duration
	cooldown_timer = cooldown


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and is_rushing:
		hit_player = true
		var attack = Attack.new()
		attack.damage = 10
		body.on_damaged(attack)

		velocity.y = fly_up_force 
		is_rushing = false


func on_damaged(attack: Attack) -> void:
	HPnode.on_damaged(attack)
	hp = HPnode.health
	if hp <= 0:
		alive = false
		death()


func death() -> void:
	queue_free()
