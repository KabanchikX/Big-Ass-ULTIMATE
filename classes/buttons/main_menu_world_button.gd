extends BasicButton;
class_name MainMenuWorldButton;

@onready var world_text : Label = get_node("MainPanel/Text");
@onready var world_icon : Sprite2D = get_node("MainPanel/WorldIconPanel/WorldIcon");

var world_name : String = "vanilla.test_place";

@onready var world_icon_panel : Panel = get_node("MainPanel/WorldIconPanel");
@onready var main_panel : Panel = get_node("MainPanel");

var panel_color : Color = Color.WHITE;

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
	set_world();
	
	hovered.connect(on_state_changed.bind("hovered"));
	unhovered.connect(on_state_changed.bind("unhovered"));
	
	pressed.connect(on_state_changed.bind("pressed"));
	unpressed.connect(on_state_changed.bind("unpressed"));
		
func _physics_process(_delta: float) -> void:
	main_panel.scale = Vector2.ONE + first_scale_modifier + second_scale_modifier;
	main_panel.self_modulate = panel_color + first_self_modulate + second_self_modulate;
	
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
			first_tween = set_up_tween(self, first_tween, "first_scale_modifier", Vector2(0.05, 0.05));
		"unhovered":
			color_tween = set_up_tween(self, color_tween, "first_self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3);
			first_tween = set_up_tween(self, first_tween, "first_scale_modifier", Vector2.ZERO);
		"pressed":
			SoundManager.play_interface_sound(load("res://vanilla/sfx/buttons/gui/interface_button_pressed.mp3"));
			second_self_modulate = Color(-0.75, -0.75, -0.75, 0.0);
			second_scale_modifier = Vector2(-0.1, -0.1);
			second_tween = set_up_tween(self, second_tween, "second_scale_modifier", Vector2(-0.15, -0.15), 0.35);
			if color_tween2: color_tween2.kill();
		"unpressed":
			if is_hovered:
				SoundManager.play_interface_sound(load("res://vanilla/sfx/buttons/gui/interface_button_unpressed.mp3"))
				var world : World = GlobalData.get_world(world_name.split(".")[1], world_name.split(".")[0]);
				if world: GameManager.world = world;
				
			color_tween2 = set_up_tween(self, color_tween2, "second_self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3);
			second_tween = set_up_tween(self, second_tween, "second_scale_modifier", Vector2.ZERO, 0.35);

func set_world() -> Error:
	var _mod_name : String = world_name.split(".")[0];
	var _world_name : String = world_name.split(".")[1];
	
	if !GlobalData.data.has(_mod_name): return FAILED;
	if !GlobalData.data[_mod_name].has("worlds"): return FAILED;
	if !GlobalData.data[_mod_name]["worlds"].has(_world_name): return FAILED;
	
	var world_info : Dictionary = GlobalData.data[_mod_name]["worlds"][_world_name].duplicate(true);
	
	var text : String = "";
	text += world_info["name"]+"\n";
	text += "from "+_mod_name;
	
	world_text.text = text;
	return OK;
