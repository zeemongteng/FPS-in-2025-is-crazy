extends Node3D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()


func shoot():
	$AnimationPlayer.play("shoot")
