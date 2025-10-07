extends Node3D

@export var first_scene:PackedScene

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(first_scene)
