extends Node

@export var bullet_scene: PackedScene
@onready var marker_3d: Marker3D = $"../Camera3D/Marker3D"
@export var parryBox : CollisionShape3D

@export var parry_cooldown: float = 2.0  # seconds before you can parry again
var can_parry: bool = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()
	if Input.is_action_just_pressed("right_mouse_button"):
		parry()

func shoot():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_transform = marker_3d.global_transform
	get_tree().current_scene.add_child(bullet)

func parry():
	if not can_parry:
		print("Parry on cooldown!") 
		return

	can_parry = false
	parryBox.disabled = false

	# how long the parry window stays active
	await get_tree().create_timer(0.3).timeout
	parryBox.disabled = true

	# cooldown time before next parry
	await get_tree().create_timer(parry_cooldown).timeout
	can_parry = true
