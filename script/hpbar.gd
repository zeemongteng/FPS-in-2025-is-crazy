class_name Hpbar
extends ProgressBar

@export var iframe := false
@export var HPnode: Health
@export var smooth_speed := 8.0 # how fast the red bar moves
@export var bar_name: String

@onready var damage_bar = $DamageBar
@onready var timer = $Timer
@onready var hp = HPnode.health
@onready var label: Label = $Label

var player: Player = get_owner()
var target_hp: float

func _ready() -> void:
	label.text = bar_name
	# Connect Health node signals
	HPnode.health_changed.connect(change_health)
	init_health(hp)

	# Connect Timer signal
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.wait_time = 0.3

func change_health(new_hp: float) -> void:
	_set_health(new_hp)

func _set_health(new_hp: float) -> void:
	target_hp = clamp(new_hp, 0, HPnode.max_health)

	# Update main HP instantly
	max_value = HPnode.max_health
	damage_bar.max_value = HPnode.max_health
	value = target_hp

	# Start the delay only when HP goes down
	if target_hp < hp:
		timer.start()
	else:
		damage_bar.value = target_hp

	hp = target_hp

func init_health(_hp: int) -> void:
	hp = _hp
	target_hp = _hp
	max_value = _hp
	value = _hp
	damage_bar.max_value = _hp
	damage_bar.value = _hp

func _process(delta: float) -> void:
	# Smooth animation only after timer timeout
	if not timer.is_stopped():
		return

	if damage_bar.value > hp:
		damage_bar.value = lerp(damage_bar.value, hp, delta * smooth_speed)
	else:
		damage_bar.value = hp

func _on_timer_timeout() -> void:
	# Timer just allows _process to start animating
	pass
