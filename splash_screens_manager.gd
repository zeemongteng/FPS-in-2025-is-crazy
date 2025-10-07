extends Control

@export var load_screen : PackedScene
@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5
@export var splash_screen_container : Node



var splash_screens : Array
var skipping := false   # Flag to detect skipping

func _ready() -> void:
	get_screens()
	fade()

func get_screens() -> void:
	splash_screens = splash_screen_container.get_children()
	for screen in splash_screens:
		screen.modulate.a = 0.0

func fade() -> void:
	for screen in splash_screens:
		skipping = false
		screen.show()
		var tween = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0 , fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0 , fade_out_time)
		tween.tween_interval(out_time)

		# Wait for tween OR skip
		while tween.is_running() and not skipping:
			await get_tree().process_frame

		# If skipped, kill the tween and hide instantly
		if skipping:
			tween.kill()
			screen.modulate.a = 0.0

	get_tree().change_scene_to_packed(load_screen)

func _unhandled_input(event: InputEvent) -> void:
	# Any key, mouse click, or screen tap skips
	if event.is_pressed():
		skipping = true
