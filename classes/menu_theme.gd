extends Resource;
class_name MenuTheme;

@export var name : String;
@export var main_color : Color;
@export var second_color : Color;
@export var first_background_color : Color;
@export var second_background_color : Color;
@export var theme_music : AudioStream;
@export var icon : Texture;
@export var background_icon : Texture;
@export var text_color : Color;
@export var text_shadow_color : Color;
@export var parallax_size : Vector2 = Vector2(100.0, 100.0);
@export var parallas_autoscroll_speed : Vector2 = Vector2(-20.0, 20.0);
@export var parallax_icon_repeat_times : int = 7;
@export var background_icon_rotation : float = -19.0;

func _to_string() -> String:
	return name;
