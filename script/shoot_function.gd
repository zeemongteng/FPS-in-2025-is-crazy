extends Node

@export var parry_cooldown: float = 2.0 


@export_group("export")
@export var bullet_scene: PackedScene
@export var marker_3d: Marker3D
@export var parryBox : CollisionShape3D
@export var coin_scene: PackedScene

var can_parry: bool = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		shoot()
	if Input.is_action_just_pressed("right_mouse_button"):
		parry()
	if Input.is_action_just_pressed("middle_mouse"):
		throw_coin()

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

func throw_coin():
	var coin = coin_scene.instantiate() as Coin
	coin.global_transform = marker_3d.global_transform
	get_tree().current_scene.add_child(coin)

	var forward_dir = -marker_3d.global_transform.basis.z.normalized()
	var throw_strength: float = 15.0
	var upward_strength: float = 5.0
	coin.linear_velocity = forward_dir * throw_strength + Vector3.UP * upward_strength

	var spin_strength: float = 10.0
	var random_axis = Vector3(randf(), randf(), randf()).normalized()
	coin.angular_velocity = random_axis * spin_strength
