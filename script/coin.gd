extends RigidBody3D
class_name Coin

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()
