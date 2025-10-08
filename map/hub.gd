extends CanvasLayer

@onready var tutorial_label: RichTextLabel = $TutorialLabel

var tutorial_steps: Array = [
	"Press X to Skip",
	"Walk: W A S D",
	"Press Shift to Dash",
	"Press Space Bar to Jump",
	"Press F to throw coin",
	"Shoot the coin to make more damage",
	"Press Space Bar to Jump",
	"Press m1 to shoot",
	"Press m2 to parry",
	"Kill all the monster to go to the next stage",
	"Lastly don't get hit"
]

var current_step: int = 0
var display_time: float = 4.0

func _ready() -> void:
	tutorial_label.visible = false
	show_next_step()

func show_next_step() -> void:
	if current_step >= tutorial_steps.size():
		tutorial_label.visible = false
		return
	
	tutorial_label.text = tutorial_steps[current_step]
	tutorial_label.visible = true
	current_step += 1
	
func _input(event):
	if event.is_action_pressed("skip"):
		show_next_step()
