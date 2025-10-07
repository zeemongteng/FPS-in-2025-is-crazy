extends Control

@export var combo_reset_time: float = 4.0
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var name_combo: Label = $NameCombo
@onready var num_mul: Label = $NumMul

# Style / combo data
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_active: bool = false
var score: int = 0

# Style rank thresholds
var style_ranks = [
	{"name": "DISRESPECTFUL", "min": 5, "color": Color.LIGHT_GRAY},
	{"name": "DESTRUCTIVE", "min": 10, "color": Color.DARK_ORANGE},
	{"name": "BRUTAL", "min": 20, "color": Color.RED},
	{"name": "SSADISTIC", "min": 30, "color": Color.PURPLE},
	{"name": "ULTRAKILL", "min": 50, "color": Color.GOLD}
]

func _process(delta: float) -> void:
	if combo_active:
		combo_timer -= delta
		if combo_timer <= 0:
			_reset_combo()
		else:
			progress_bar.value = combo_timer

# Called when player performs a kill or style action
func add_combo(amount: int = 1):
	combo_count += amount
	combo_active = true
	combo_timer = combo_reset_time
	progress_bar.max_value = combo_reset_time
	progress_bar.value = combo_timer

	# Update score based on combo count
	score += 100 * amount
	num_mul.text = "x%d" % combo_count

	# Get current style rank
	var rank_info = _get_style_rank(combo_count)
	name_combo.text = rank_info.name
	name_combo.modulate = rank_info.color

	# Optional: add screen shake or animation
	flash_rank()

func _reset_combo():
	combo_count = 0
	combo_active = false
	combo_timer = 0
	progress_bar.value = 0
	name_combo.text = ""
	num_mul.text = "x0"

func _get_style_rank(count: int) -> Dictionary:
	var result = {"name": "DISRESPECTFUL", "color": Color.LIGHT_GRAY}
	for rank in style_ranks:
		if count >= rank.min:
			result = rank
	return result

func flash_rank():
	# A quick animation to make the rank label pop
	name_combo.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(name_combo, "modulate:a", 0.5, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
