extends Node3D

@export var next_scene_path: String = "res://map/map_boss.tscn"
var alive_enemies: Array = []

func _ready() -> void:
	# หา Enemy ทั้งหมดในกลุ่ม "enemies"
	alive_enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy_node in alive_enemies:
		if enemy_node.has_signal("died"):
			enemy_node.died.connect(func(): _on_enemy_died(enemy_node))

func _on_enemy_died(enemy_node):
	if enemy_node in alive_enemies:
		alive_enemies.erase(enemy_node)

	if alive_enemies.is_empty():
		change_scene()

func change_scene():
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
