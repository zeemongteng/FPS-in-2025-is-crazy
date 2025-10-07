extends Area3D
class_name Hitbox

signal hit_enemy
@export var damage : float = 10
func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area is Hurtbox:
		var attack := Attack.new()
		attack.damage = damage
		
		area.damage(attack)
		hit_enemy.emit()
