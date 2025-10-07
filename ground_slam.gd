extends Node3D

@onready var shockwave: MeshInstance3D = $Shockwave
@onready var collision_shape_3d: CollisionShape3D = $Hitbox/CollisionShape3D

@export var expand_speed: float = 20.0
@export var max_radius: float = 50.0
@export var ring_thickness: float = 1.0  # minimum safe value is 0.1

var current_radius: float = 1.0

func _ready() -> void:
	var torus = shockwave.mesh
	if torus is TorusMesh:
		var inner = current_radius - max(ring_thickness, 0.1)
		if inner >= current_radius:
			inner = current_radius - 0.1
		torus.outer_radius = current_radius
		torus.inner_radius = inner
	
	collision_shape_3d.scale = Vector3.ONE * current_radius

func _process(delta: float) -> void:
	if current_radius < max_radius:
		current_radius += expand_speed * delta

		var torus = shockwave.mesh
		if torus is TorusMesh:
			var inner = current_radius - max(ring_thickness, 0.1)
			if inner >= current_radius:
				inner = current_radius - 0.1
			torus.outer_radius = current_radius
			torus.inner_radius = inner

		collision_shape_3d.scale = Vector3(current_radius, current_radius * 0.1, current_radius)
	else:
		queue_free()
