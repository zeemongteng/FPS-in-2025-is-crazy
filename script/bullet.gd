extends Node3D
class_name Bullet

@export var speed: float = 40.0
@export var lifetime: float = 2.0
@export var damage: float = 10.0
@export var color: Color = Color(1, 0, 0)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var alive_time: float = 0.0

func _ready() -> void:
	# Set bullet color
	if mesh_instance_3d.material_override == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy = 3.0
		mesh_instance_3d.material_override = mat

func _process(delta: float) -> void:
	alive_time += delta
	if alive_time >= lifetime:
		queue_free()
		return

	# Move forward
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
