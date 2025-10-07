extends Control

@onready var boss_label: RichTextLabel = $BossLabel
@onready var tween: Tween = create_tween()

# === CONFIG ===
@export var tutorial_steps: Array[Dictionary] = [
	{"text": "Ahh…", "text_speed": 0.04, "pause": 1.5, "font_size": 20},
	{"text": "Free at last", "text_speed": 0.04, "pause": 3.8, "font_size": 20},
	{"text": "O, Gabriel", "text_speed": 0.04, "pause": 2.5, "font_size": 20},
	{"text": "Now dawns thy reckoning", "text_speed": 0.035, "pause": 3.2, "font_size": 20},
	{"text": "and thy gore shall glisten before the temples of man", "text_speed": 0.03, "pause": 5.6, "font_size": 20},
	{"text": "Creature of steel", "text_speed": 0.035, "pause": 2.8, "font_size": 20},
	{"text": "my gratitude upon thee for my freedom", "text_speed": 0.03, "pause": 4.0, "font_size": 20},
	{"text": "But the crimes thy kind have committed against humanity", "text_speed": 0.03, "pause": 3.8, "font_size": 20},
	{"text": "are NOT forgotten", "text_speed": 0.04, "pause": 2.5, "font_size": 20},
	{"text": "And thy punishment...", "text_speed": 0.035, "pause": 2.5, "font_size": 20},
	{"text": "is DEATH!", "text_speed": 0.025, "pause": 3.0, "font_size": 20}
]

@export var flash_speed: float = 0.15
@export var flash_color: Color = Color(1, 0, 0)
@export var normal_color: Color = Color(1, 1, 1)
@export var size_growth_speed: float = 0.3

var current_step: int = 0
var typing: bool = false
var skip_requested: bool = false

func _ready() -> void:
	boss_label.visible = false
	boss_label.autowrap_mode = TextServer.AUTOWRAP_OFF # ❗ disable wrapping
	boss_label.fit_content = true
	show_next_step()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip"):
		queue_free()

func show_next_step() -> void:
	if current_step >= tutorial_steps.size():
		boss_label.visible = false
		return

	var step: Dictionary = tutorial_steps[current_step]
	current_step += 1

	var text: String = step.get("text", "")
	var text_speed: float = step.get("text_speed", 0.04)
	var pause_time: float = step.get("pause", 1.5)
	var font_size: int = step.get("font_size", 20)

	boss_label.visible = true

	# === Adjust font size ===
	boss_label.add_theme_font_size_override("normal_font_size", font_size)
	boss_label.text = text

	# Measure text width using font metrics
	var font := boss_label.get_theme_font("normal_font")
	var text_width := font.get_string_size(text).x
	var label_height := font.get_height()

	# Add padding
	var label_size := Vector2(text_width + 20, label_height + 10)

	# Smoothly animate resizing
	tween.kill()
	tween = create_tween()
	tween.tween_property(boss_label, "size", label_size, size_growth_speed)

	# Center background with label

	# Clear text for typing effect
	boss_label.text = ""
	await type_text(text, text_speed)
	await flash_text()
	await get_tree().create_timer(pause_time).timeout
	show_next_step()

# === Typewriter effect ===
func type_text(line: String, speed: float) -> void:
	typing = true
	skip_requested = false
	boss_label.text = ""
	for c in line:
		if skip_requested:
			boss_label.text = line
			break
		boss_label.text += str(c)
		await get_tree().create_timer(speed).timeout
	typing = false
	skip_requested = false

# === Flash red effect ===
func flash_text() -> void:
	boss_label.add_theme_color_override("default_color", flash_color)
	await get_tree().create_timer(flash_speed).timeout
	boss_label.add_theme_color_override("default_color", normal_color)
