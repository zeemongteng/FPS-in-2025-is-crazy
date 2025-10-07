extends ColorRect
class_name Flash

func flash(duration: float = 0.2, flash_color: Color = Color.WHITE, max_alpha: float = 0.7) -> void:
	self.color = flash_color
	self.color.a = max_alpha
	show()
	
	var tween := create_tween()
	tween.tween_property(self, "color:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(self.hide)

func fade_to_black(fade_duration: float = 2.0, hold_time: float = 3.0, fade_color: Color = Color.BLACK, max_alpha: float = 1.0) -> void:
	self.color = fade_color
	self.color.a = 0.0
	show()

	var tween := create_tween()
	
	# Fade in to full black
	tween.tween_property(self, "color:a", max_alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Hold black screen
	tween.tween_interval(hold_time)
	
	# Keep showing black screen after hold
