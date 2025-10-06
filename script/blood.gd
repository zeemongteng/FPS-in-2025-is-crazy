extends Node3D

@onready var debris: GPUParticles3D = $Debris
@onready var fire: GPUParticles3D = $Fire

# Editable in the inspector
@export var debris_albedo_color: Color = Color(0.821, 0.009, 0.0, 1.0)   # reddish-orange
@export var debris_emission_color: Color = Color(0.821, 0.009, 0.0, 1.0) # glowing orange

func _ready() -> void:
	debris.emitting = true
	#fire.emitting = true

	_change_debris_material_color(debris_albedo_color, debris_emission_color)

	await get_tree().create_timer(2).timeout
	queue_free()


func _change_debris_material_color(albedo: Color, emission: Color) -> void:
	# Make sure the debris has a mesh and a material
	if debris.draw_pass_1 and debris.draw_pass_1.material:
		# Duplicate material so we don’t modify shared ones
		var mat = debris.draw_pass_1.material.duplicate()
		debris.draw_pass_1.material = mat

		# Change color properties (for StandardMaterial3D)
		if mat is StandardMaterial3D:
			mat.albedo_color = albedo
			mat.emission_enabled = true
			mat.emission = emission
			mat.emission_energy = 2.0  # how bright it glows
