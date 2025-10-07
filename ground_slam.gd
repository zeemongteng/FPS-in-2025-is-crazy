extends Node3D

@onready var shockwave: MeshInstance3D = $Shockwave
@onready var collision_shape_3d: CollisionShape3D = $Hitbox/CollisionShape3D

@export var expand_speed: float = 8.0
@export var fade_speed: float = 1.5
@export var max_scale: float = 20.0

func _ready() -> void:
	shockwave.scale = Vector3.ONE * 0.1
	collision_shape_3d.scale = Vector3.ONE * 0.1

func _process(delta: float) -> void:
	if shockwave.scale.x < max_scale:
		# Expand the visual ring
		shockwave.scale += Vector3.ONE * expand_speed * delta
		# Expand the collision shape at the same rate
		collision_shape_3d.scale = shockwave.scale
	else:
		queue_free()
