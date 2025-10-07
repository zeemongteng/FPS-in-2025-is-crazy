extends Node3D

@onready var shockwave: MeshInstance3D = $Shockwave
@onready var collision_shape_3d: CollisionShape3D = $Hitbox/CollisionShape3D

@export var expand_speed: float = 20.0
@export var max_radius: float = 10.0
@export var ring_thickness: float = 3

var current_radius: float = 0.1

func _ready() -> void:
	# Start small ring
	shockwave.scale = Vector3.ONE * current_radius
	collision_shape_3d.scale = Vector3.ONE * current_radius

func _process(delta: float) -> void:
	if current_radius < max_radius:
		current_radius += expand_speed * delta
		
		# Outer ring grows, but thickness stays constant
		var outer = current_radius
		var inner = current_radius - ring_thickness
		if inner < 0.1:
			inner = 0.1  # prevent inversion
		
		# Adjust mesh transform to simulate a "donut expanding"
		shockwave.scale = Vector3(outer, 1.0, outer)
		collision_shape_3d.scale = Vector3(outer, 1.0, outer)
	else:
		queue_free()
