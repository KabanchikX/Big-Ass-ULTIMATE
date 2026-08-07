extends Sprite2D;
class_name Shadow;

@onready var gradient_texture : GradientTexture2D = load("res://vanilla/resources/shadow.tres").duplicate();
@onready var gradient : Gradient = gradient_texture.gradient;

@export var size : Vector2 = Vector2(40.0, 15.0):
	set(value):
		value = abs(value);
		size = value;
		if gradient_texture:
			gradient_texture.width = int(value.x);
			gradient_texture.height = int(value.y);

func reset_size() -> void:
	size = Vector2(40.0, 15.0);

func _ready() -> void:
	texture = gradient_texture;
	z_index = -3;
	size = size;
