extends Area3D
class_name Hurtbox 

signal damaged(attack: Attack)

func damage(attack: Attack):
	damaged.emit(attack)
	
