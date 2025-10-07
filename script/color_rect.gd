extends ColorRect

func flash(duration: float = 0.2, color: Color = Color.WHITE, max_alpha: float = 0.7) -> void:
	self.color = color
	self.modulate.a = max_alpha
	show()
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(self.hide)
