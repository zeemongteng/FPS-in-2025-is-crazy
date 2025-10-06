extends CanvasLayer

@export var start_scene: PackedScene
var active := false
func _process(_delta: float) -> void:
	if active:
		if Input.is_action_pressed("Restart"):
			active = false
			hide()
			get_tree().reload_current_scene()
		elif Input.is_action_pressed("ui_cancel"):
			active = false
			#make a start menu pls
			#get_tree().change_scene_to_packed(start_scene)
			get_tree().quit()
