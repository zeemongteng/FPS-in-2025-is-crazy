extends Area3D
class_name Parrybox

signal parried(fireball: Fireball)

func parrying(area: Area3D) -> void:
	if area is Fireball:
		var enemyUnit = get_tree().get_first_node_in_group("Enemy") # make sure your enemy is in "Enemy" group
		if enemyUnit:
			var dir_to_enemy = (enemyUnit.global_transform.origin - area.global_transform.origin).normalized()
			area.direction = dir_to_enemy
			
			area.speed *= 1.5

			area.flipp
			
			area.parried = true

		parried.emit(area)
