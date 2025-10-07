extends CanvasLayer

@onready var tutorial_label: RichTextLabel = $TutorialLabel

# ข้อความสอนการเล่นทีละขั้น
var tutorial_steps: Array = [
	"กด X เพื่อ skip",
	"สามารถเดินได้ทุกทิศทาง: W A S D",
	"กด Shift เพื่อพุ่ง",
	"กด Space Bar เพื่อกระโดด",
	"ใช้เมาส์ในการคลิกเลือกเมนูต่างๆ",
	"ลากเมาส์เพื่อควบคุมทิศทางปืน",
	"คลิกซ้ายเพื่อยิงปืน",
	"กำจัดศัตรูทั้งหมดเพื่อไปยังด่านต่อไป"
]

var current_step: int = 0
var display_time: float = 4.0 # วินาทีต่อข้อความ

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
