
class_name HPbar
extends ProgressBar

@export var iframe := false
@export var timer2 := 1.0
@export var HealthComponent : Health

var health_point

func _ready() -> void:
	health_point = HealthComponent.health
	HealthComponent.health_changed.connect(change_health)
	init_health(health_point)

func change_health(HP: float) -> void:
	_set_health(HP)

func _set_health(new_hp: float) -> void:
	health_point = clamp(new_hp, 0, HealthComponent.max_health)
	
	var hp_percent = float(health_point) / max_value

	var fill_style = get("theme_override_styles/fill")
	if fill_style:
		fill_style = fill_style.duplicate()
		set("theme_override_styles/fill", fill_style)

	# Change color based on hp %
	if hp_percent <= 0.2:
		fill_style.bg_color = Color.RED
	elif hp_percent <= 0.5:
		fill_style.bg_color = Color.YELLOW
	else:
		fill_style.bg_color = Color.WEB_GREEN

func init_health(_hp: int) -> void:
	max_value = _hp
	value = _hp
