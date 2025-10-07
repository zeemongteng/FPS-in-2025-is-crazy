extends Node3D

@onready var sketchfab_scene: Node3D = $Sketchfab_Scene
@onready var hub_boss_scene: PackedScene = preload("res://map/hub_boss.tscn")
var boss: BossMinosPrime = null

func _ready() -> void:
	boss = get_tree().get_first_node_in_group("boss") as BossMinosPrime

func _process(_delta: float) -> void:
	if boss and is_instance_valid(boss):
		if not boss.alive:
			sketchfab_scene.show()
	else:
		# Boss no longer exists (freed) — optional logic
		print("Boss has been destroyed.")
		boss = null
