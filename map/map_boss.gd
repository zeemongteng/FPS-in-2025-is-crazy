extends Node3D

@onready var hub_boss_scene: PackedScene = preload("res://map/hub_boss.tscn")

func _ready() -> void:
	# Instance HUB_Boss ลงใน Scene บอส
	var hub = hub_boss_scene.instantiate()
	add_child(hub)
