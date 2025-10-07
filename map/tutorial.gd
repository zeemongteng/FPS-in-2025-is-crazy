extends Node3D
"res://map/normal_scene.tscn"

@export var next_scene_path: String = "res://map/normal_scene.tscn"
var alive_enemies: Array = []

func _ready() -> void:
	# หา Enemy ทั้งหมดในกลุ่ม "enemies"
	alive_enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in alive_enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(func(): _on_enemy_died(enemy))

func _on_enemy_died(enemy):
	if enemy in alive_enemies:
		alive_enemies.erase(enemy)
		print("Enemy died. Remaining:", alive_enemies.size())

	if alive_enemies.is_empty():
		print("✅ All enemies defeated! Changing scene...")
		change_scene()

func change_scene():
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
