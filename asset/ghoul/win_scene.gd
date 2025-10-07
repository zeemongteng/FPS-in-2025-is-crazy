extends Node3D

@export var first: PackedScene
@export var main: PackedScene


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(main)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(first)
