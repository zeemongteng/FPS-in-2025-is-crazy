extends Camera3D

var shake_time: float = 0.0
var shake_duration: float = 0.0
var shake_intensity: float = 0.0

var original_rotation: Vector3 = Vector3.ZERO
var original_offset: Vector3 = Vector3.ZERO

@export var follow_node: Node3D  # assign the player's head or camera parent

func _ready() -> void:
	if follow_node:
		original_offset = global_transform.origin - follow_node.global_transform.origin
		original_rotation = rotation

func shake(duration: float, intensity: float) -> void:
	shake_time = duration
	shake_duration = duration
	shake_intensity = intensity

func _process(delta: float) -> void:
	if not follow_node:
		return

	# Base position and rotation follow the player
	global_transform.origin = follow_node.global_transform.origin + original_offset
	rotation = original_rotation

	# Apply shake if active
	if shake_time > 0.0:
		shake_time -= delta
		var progress = shake_time / shake_duration
		var current_intensity = shake_intensity * progress

		# Small translation offsets (mostly horizontal/vertical)
		var offset = Vector3(
			randf_range(-1, 1) * current_intensity * 0.02,
			randf_range(-1, 1) * current_intensity * 0.02,
			0
		)

		# Small rotation offsets (yaw/pitch)
		var rotation_offset = Vector3(
			randf_range(-1, 1) * current_intensity * 0.005,
			randf_range(-1, 1) * current_intensity * 0.005,
			0
		)

		global_transform.origin += offset
		rotation += rotation_offset
