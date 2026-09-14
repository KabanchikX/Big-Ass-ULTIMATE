extends BasicButton;
class_name MainMenuButton;

@export var translation_size : Dictionary[Settings.languages_list, Vector2];

@onready var sprite : Sprite2D = get_node("Sprite2D");

var color_tween : Tween;
var color_tween2 : Tween;
var press_animation : bool = false;

var first_tween : Tween;
var second_tween : Tween;

var first_scale_modifier : Vector2 = Vector2.ZERO;
var second_scale_modifier : Vector2 = Vector2.ZERO;

var first_self_modulate : Color = Color(0.0, 0.0, 0.0, 0.0);
var second_self_modulate : Color = Color(0.0, 0.0, 0.0, 0.0);

func _ready() -> void:
	super._ready();
	
	#size = translation_size[Settings.language];
	#sprite.size = size;
	#panel.pivot_offset = size/2;
	#
	#Settings.language_changed.connect(func(_old, new):
		#size = translation_size[new];
		#panel.size = size;
		#panel.pivot_offset = size/2;
		#);
	
	hovered.connect(on_state_changed.bind("hovered"));
	unhovered.connect(on_state_changed.bind("unhovered"));
	
	pressed.connect(on_state_changed.bind("pressed"));
	unpressed.connect(on_state_changed.bind("unpressed"));

func _physics_process(_delta: float) -> void:
	sprite.scale = Vector2.ONE + first_scale_modifier + second_scale_modifier;
	sprite.self_modulate = Color.WHITE + first_self_modulate + second_self_modulate;
	
func set_up_tween(object : Node = self, tween : Tween = create_tween(), property : NodePath = "", value : Variant = null, _duration : float = 0.25, trans : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC) -> Tween:
	if property == ("" as NodePath) or value == null: return;
	if tween: tween.kill();
	tween = create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.set_trans(trans);
	tween.parallel().tween_property(object, property, value, _duration);
	return tween;
	
func on_state_changed(_state : String = "hovered") -> void:
	match _state:
		"hovered":
			SoundManager.play_interface_sound(load("res://vanilla/sfx/buttons/gui/interface_button_hovered.mp3"))
			first_self_modulate = Color(1.0, 1.0, 1.0, 0.0);
			color_tween = set_up_tween(self, color_tween, "first_self_modulate", Color(0.3, 0.3, 0.3, 0.0), 0.3);
			first_tween = set_up_tween(self, first_tween, "first_scale_modifier", Vector2(0.1, 0.1));
		"unhovered":
			color_tween = set_up_tween(self, color_tween, "first_self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3);
			first_tween = set_up_tween(self, first_tween, "first_scale_modifier", Vector2.ZERO);
		"pressed":
			SoundManager.play_interface_sound(load("res://vanilla/sfx/buttons/gui/interface_button_pressed.mp3"));
			second_self_modulate = Color(-0.75, -0.75, -0.75, 0.0);
			second_scale_modifier = Vector2(-0.20, -0.20);
			second_tween = set_up_tween(self, second_tween, "second_scale_modifier", Vector2(-0.3, -0.3), 0.35);
			if color_tween2: color_tween2.kill();
		"unpressed":
			if is_hovered: SoundManager.play_interface_sound(load("res://vanilla/sfx/buttons/gui/interface_button_unpressed.mp3"))
			color_tween2 = set_up_tween(self, color_tween2, "second_self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3);
			second_tween = set_up_tween(self, second_tween, "second_scale_modifier", Vector2.ZERO, 0.35);
