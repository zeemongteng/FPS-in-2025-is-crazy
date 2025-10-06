extends Node
@export var bullet_scene: PackedScene
@onready var marker_3d: Marker3D = $"../Camera3D/Marker3D"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_transform = marker_3d.global_transform
	get_tree().current_scene.add_child(bullet)
