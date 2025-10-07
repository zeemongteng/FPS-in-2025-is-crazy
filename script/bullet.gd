extends Node3D
class_name Bullet

@export var speed: float = 60.0
@export var lifetime: float = 5.0
@export var damage: float = 10.0
@export var color: Color = Color(1, 0, 0)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var alive_time: float = 0.0
var target_node: Node3D = null
var ricocheted: bool = false  # Becomes true after hitting first coin

func _ready() -> void:
	if mesh_instance_3d.material_override == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy = 3.0
		mesh_instance_3d.material_override = mat

	_update_target()

func _process(delta: float) -> void:
	alive_time += delta
	if alive_time >= lifetime:
		queue_free()
		return

	# Homing behavior only after ricocheted
	if ricocheted and target_node and target_node.is_inside_tree():
		var to_target = (target_node.global_transform.origin - global_transform.origin).normalized()
		look_at(global_transform.origin + to_target, Vector3.UP)

	# Move forward in current direction
	global_translate(-transform.basis.z * speed * delta)

	# Collision check
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()

		# Hit a coin → chain to next coin
		if hit is Coin:
			hit.queue_free()
			damage *= 2
			speed *= 1.1
			ricocheted = true

			var overlay = get_tree().get_first_node_in_group("Flash")
			if overlay:
				overlay.flash(0.1, Color.ORANGE, 0.5)

			# Wait briefly for effect
			get_tree().paused = true
			await get_tree().create_timer(0.1).timeout
			get_tree().paused = false
			$AudioStreamPlayer3D.play()
			
			_update_target()  # Set next coin or enemy
			return  # Continue without dying

		# Hit an enemy
		elif hit is Hurtbox:
			var attack = Attack.new()
			attack.damage = damage
			hit.damage(attack)
			queue_free()
			return

# Updates target: nearest coin first, then enemies after all coins gone
func _update_target():
	var coins = get_tree().get_nodes_in_group("Coin")
	if coins.size() > 0:
		target_node = _find_nearest(coins)
	else:
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if enemies.size() > 0:
			target_node = _find_nearest(enemies)
		else:
			target_node = null

# Find nearest node helper
func _find_nearest(nodes: Array) -> Node3D:
	var nearest: Node3D = null
	var nearest_dist = INF
	for node in nodes:
		if node is Node3D:
			var dist = global_transform.origin.distance_to(node.global_transform.origin)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = node
	return nearest
