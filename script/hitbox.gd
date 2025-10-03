extends Area3D
class_name Hitbox 

signal damaged(attack: Attack)

func damage(attack: Attack):
	damaged.emit(attack)
	
