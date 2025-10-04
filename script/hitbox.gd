extends Area3D
class_name Hitbox

signal hit_enemy

@onready var projectile = get_owner()

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area is Hurtbox:
		var attack := Attack.new()
		attack.damage = projectile.damage
		
		area.damage(attack)
		
		hit_enemy.emit()
