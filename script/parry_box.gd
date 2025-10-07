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
			area.flipped()
			%Flash.flash(0.1, Color.WHITE, 0.8)
			get_tree().paused = true
			await get_tree().create_timer(0.3).timeout
			get_tree().paused = false

		parried.emit(area)
