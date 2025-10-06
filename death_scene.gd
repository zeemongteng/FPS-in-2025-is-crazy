extends Node2D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Restart"):
		get_tree().change_scene_to_file("res://scene/testing_ground.tscn")
	elif Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
