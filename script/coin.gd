extends RigidBody3D
class_name Coin

func _ready() -> void:
	await get_tree().create_timer(1).finished
	queue_free()
