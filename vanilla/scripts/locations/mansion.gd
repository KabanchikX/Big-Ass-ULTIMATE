extends Location;

func _ready() -> void:
	var tween : Tween = create_tween();
	var light_resource : GradientTexture2D = $PointLight2D.texture;


	tween.set_trans(Tween.TRANS_CUBIC);
	
	tween.tween_property(light_resource, "width", 192.0, 2.0);
	tween.parallel().tween_property(light_resource, "height", 192.0, 2.0);
	tween.tween_property(light_resource, "width", 256.0, 2.0);
	tween.parallel().tween_property(light_resource, "height", 256.0, 2.0);
	
	tween.set_loops();
