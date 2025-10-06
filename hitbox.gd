extends Hitbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area is Hurtbox:
		var attack := Attack.new()
		attack.damage = 20
		
		area.damage(attack)
		
		hit_enemy.emit()
