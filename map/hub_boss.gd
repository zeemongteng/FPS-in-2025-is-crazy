extends CanvasLayer

@onready var boss_label: RichTextLabel = $BossLabel

# ข้อความสอนการเล่นทีละขั้น
var tutorial_steps: Array = [
	"ฮึฮึ มาถึงแล้วสินะ",
	"เจ้านักเดินทางผู้โง่เขลา",
	"กล้าที่จะมาต่อกรกับข้าราชาผู้นี้งั้นเหรอ",
	"เอาสิข้าจะเล่นด้วยก็ได้"
]

var current_step: int = 0
var display_time: float = 5.0 # วินาทีต่อข้อความ

func _ready() -> void:
	boss_label.visible = false
	show_next_step()

func show_next_step() -> void:
	if current_step >= tutorial_steps.size():
		boss_label.visible = false
		return
	
	boss_label.text = tutorial_steps[current_step]
	boss_label.visible = true
	current_step += 1
	
	# ใช้ Timer เพื่อสลับข้อความอัตโนมัติ
	var t = get_tree().create_timer(display_time)
	t.timeout.connect(show_next_step)
