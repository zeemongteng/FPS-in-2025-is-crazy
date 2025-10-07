extends Node3D

@export var win_scene: PackedScene

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		call_deferred("_change_scene")

func _change_scene() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_packed(win_scene)
