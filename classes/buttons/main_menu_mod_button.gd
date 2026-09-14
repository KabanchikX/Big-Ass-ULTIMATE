extends BasicButton;
class_name MainMenuModButton;

@export var translation_size : Dictionary[Settings.languages_list, Vector2];

@onready var mod_text : Label = get_node("MainPanel/Text");
@onready var mod_icon : Sprite2D = get_node("MainPanel/ModIconPanel/ModIcon");

var mod_name : String = "";

@onready var mod_icon_panel : Panel = get_node("MainPanel/ModIconPanel");
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

var is_mod_enabled : bool = false :
	set(value):
		is_mod_enabled = value;
		panel_color = Color(1.483, 0.508, 0.465) if !value else Color(0.749, 1.406, 0.776);
		mod_icon_panel.self_modulate = panel_color;
		
		if mod_name == "vanilla": return;
		var mod_path : String = GlobalData.mods_list[mod_name]["full_path"];
		if Settings.enabled_mods.has(mod_path) and !value:
			for element in Settings.enabled_mods.count(mod_path): Settings.enabled_mods.erase(mod_path);
		if value: Settings.enabled_mods.append(mod_path);
		
func _ready() -> void:
	super._ready();
	set_mod();
	if mod_name != "vanilla":
		hovered.connect(on_state_changed.bind("hovered"));
		unhovered.connect(on_state_changed.bind("unhovered"));
		
		pressed.connect(on_state_changed.bind("pressed"));
		unpressed.connect(on_state_changed.bind("unpressed"));
		
		var mod_path : String = GlobalData.mods_list[mod_name]["full_path"];
		is_mod_enabled = Settings.enabled_mods.has(mod_path);
		Settings.enabled_mods.erase(mod_path);
		return;
	is_mod_enabled = true;
		
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
				is_mod_enabled = !is_mod_enabled;
			color_tween2 = set_up_tween(self, color_tween2, "second_self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3);
			second_tween = set_up_tween(self, second_tween, "second_scale_modifier", Vector2.ZERO, 0.35);

func set_mod() -> void:
	if !GlobalData.mods_list.has(mod_name): return;
	
	var mod_info : Dictionary = {};
	mod_info.assign(GlobalData.mods_list[mod_name].duplicate());
	
	if FileAccess.file_exists("res://"+mod_name+"/icon.png"): mod_icon.texture = load("res://"+mod_name+"/icon.png");
	
	var text : String = "";
	text += mod_info["name"]+" ";
	text += mod_info["version"]+"\n";
	text += "by "+mod_info["author"]+"\n";
	
	mod_text.text = text;
	
