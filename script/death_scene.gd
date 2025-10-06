extends CanvasLayer

@export var start_scene: PackedScene
func _process(_delta: float) -> void:
	if Input.is_action_pressed("Restart"):
		hide()
		get_tree().reload_current_scene()
	elif Input.is_action_pressed("ui_cancel"):
		#make a start menu pls
		#get_tree().change_scene_to_packed(start_scene)
		get_tree().quit()
