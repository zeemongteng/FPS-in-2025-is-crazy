extends Node

@export var hitscan: RayCast3D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()

func shoot():
	hitscan.enabled = true
	hitscan.force_raycast_update() 

	if hitscan.is_colliding():
		var target = hitscan.get_collider()

		if target is Hurtbox:
			var attack = Attack.new()
			attack.damage = 10 
			target.damage(attack)

	hitscan.enabled = false
