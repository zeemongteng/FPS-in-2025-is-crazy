extends Node3D

@onready var shockwave: MeshInstance3D = $Shockwave
@onready var hitbox: Hitbox = $Hitbox
@onready var collision_shape_3d: CollisionShape3D = $Hitbox/CollisionShape3D

@export var expand_speed: float = 20.0
@export var max_radius: float = 50.0
@export var ring_thickness: float = 1.0 
@export var damage: float = 20.0

var current_radius: float = 1.0

func _ready() -> void:
	# set hitbox damage value
	hitbox.damage = damage

	var torus = shockwave.mesh
	if torus is TorusMesh:
		torus.outer_radius = current_radius
		torus.inner_radius = max(current_radius - ring_thickness, 0.1)

	collision_shape_3d.scale = Vector3.ONE * current_radius

	# connect signal for debug
	hitbox.hit_enemy.connect(_on_hit_enemy)

func _process(delta: float) -> void:
	if current_radius < max_radius:
		current_radius += expand_speed * delta

		var torus = shockwave.mesh
		if torus is TorusMesh:
			var inner = current_radius - ring_thickness
			if inner >= current_radius:
				inner = current_radius - 0.1  # prevent same value
			torus.outer_radius = current_radius
			torus.inner_radius = max(inner, 0.1)

		# Expand hitbox
		collision_shape_3d.scale = Vector3(current_radius, 1.0, current_radius)
	else:
		queue_free()

func _on_hit_enemy() -> void:
	print("Shockwave hit enemy!")
