extends Node3D

@export var parry_cooldown: float = 2.0  # seconds
var can_parry: bool = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()
	if Input.is_action_just_pressed("right_mouse_button"):
		parry()

func shoot():
	$AnimationPlayer.play("shoot")

func parry():
	if not can_parry:
		return  
	
	can_parry = false
	$AnimationPlayer3.play("parry")
	

	await get_tree().create_timer(parry_cooldown).timeout
	can_parry = true
