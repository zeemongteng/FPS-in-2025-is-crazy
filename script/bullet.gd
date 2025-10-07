extends Node3D
class_name Bullet

@export var speed: float = 40.0
@export var lifetime: float = 2.0
@export var damage: float = 10.0
@export var color: Color = Color(1, 0, 0)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var alive_time: float = 0.0
var target_node: Node3D = null

func _ready() -> void:
	# Set bullet color
	if mesh_instance_3d.material_override == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy = 3.0
		mesh_instance_3d.material_override = mat

	# Initial target can be null or assigned externally
	target_node = null

func _process(delta: float) -> void:
	alive_time += delta
	if alive_time >= lifetime:
		queue_free()
		return

	# Update target direction if we have a target
	if target_node and target_node.is_inside_tree():
		var to_target = (target_node.global_transform.origin - global_transform.origin).normalized()
		look_at(global_transform.origin + to_target, Vector3.UP)
	
	var direction = -transform.basis.z
	global_translate(direction * speed * delta)

	# Check collisions
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		var target = ray_cast_3d.get_collider()
		
		if target is Hurtbox:
			var attack = Attack.new()
			attack.damage = damage
			target.damage(attack)
			queue_free()
			return
		
		elif target is Coin:
			target.queue_free()
			damage = damage * 5
			speed = speed * 1.5

			# Find nearest remaining coin
			var coins = get_tree().get_nodes_in_group("Coin")
			if coins.size() > 0:
				target_node = _find_nearest(coins)
			else:
				# No coins left → find nearest enemy
				var enemies = get_tree().get_nodes_in_group("Enemy")
				if enemies.size() > 0:
					target_node = _find_nearest(enemies)
				else:
					# Nothing left → continue forward or expire
					target_node = null

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
