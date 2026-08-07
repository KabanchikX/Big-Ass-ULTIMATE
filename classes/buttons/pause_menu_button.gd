extends BasicButton;
class_name PauseMenuButton;

var rotation_tween : Tween;
var scale_tween : Tween;

@onready var sprite : Sprite2D = get_child(0);

func _ready() -> void:
	super._ready();
	hovered.connect(on_hovered);
	unhovered.connect(on_unhovered);
	pressed.connect(on_pressed);
	clicked.connect(on_unpressed);
	disabled.connect(on_unhovered);

func set_up_rotation_tween() -> void:
	if rotation_tween: rotation_tween.kill();
	rotation_tween = create_tween();
	
	rotation_tween.set_trans(Tween.TRANS_CUBIC);
	rotation_tween.set_ease(Tween.EASE_OUT);
func set_up_scale_tween() -> void:
	if scale_tween: scale_tween.kill();
	scale_tween = create_tween();
	
	scale_tween.set_trans(Tween.TRANS_CUBIC);
	scale_tween.set_ease(Tween.EASE_OUT);

func on_hovered() -> void:
	set_up_rotation_tween();
	set_up_scale_tween();
	
	rotation_tween.tween_property(sprite, "rotation_degrees", -11.0, 0.25);
	scale_tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.25);
	
	sprite.modulate = Color(1.5, 1.5, 1.5, 1.0);
	
	var stream : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_hovered.mp3");
	SoundManager.play_interface_sound(stream);
func on_unhovered() -> void:
	set_up_rotation_tween();
	set_up_scale_tween();
	
	rotation_tween.tween_property(sprite, "rotation_degrees", 0.0, 0.25);
	scale_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25);
	
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0);

func on_pressed() -> void:
	set_up_scale_tween();
	scale_tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.15);
	sprite.modulate = Color(0.75, 0.75, 0.75, 1.0);
	var stream : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_pressed.mp3");
	SoundManager.play_interface_sound(stream);
func on_unpressed() -> void:
	set_up_scale_tween();
	scale_tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.25);
	sprite.modulate = Color(1.5, 1.5, 1.5, 1.0);
	var stream : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_unpressed.mp3");
	SoundManager.play_interface_sound(stream);
