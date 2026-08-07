extends Line2D;

var tween : Tween;

func shoot() -> void:
	default_color = Color(1.353, 1.332, 0.618, 1.0);
	width = 10.0;
	
	if tween: tween.kill();
	tween = create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(self, "width", 0.0, 1.0);
	tween.parallel().tween_property(self, "default_color", Color(0.875, 0.4, 0.0, 1.0), 0.8);
