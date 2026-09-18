extends World;

var menu_color : Color;

@export var main_menu_bg : Sprite2D;
@export var camera : Camera2D;
const center : Vector2 = Vector2(288.0, 162.0);
var mouse_position : Vector2 = Vector2.ZERO;

@onready var mod_panel : Panel = get_node("ModPanel");
@onready var worlds_panel : Panel = get_node("WorldsPanel");

signal main_menu_state_changed(old_value : main_menu_states_list, new_value : main_menu_states_list);

enum main_menu_states_list {MAIN, SAVES, WORLDS, MODS};

var main_menu_state : main_menu_states_list = main_menu_states_list.MAIN :
	set(value):
		var list = main_menu_states_list;
		
		var set_settings_state : Callable = func(_is_on : bool = true):
			return;
			
		var set_mods_state : Callable = func(is_on : bool = true):
			mod_panel.visible = is_on;
			if !is_on: return;
			mod_panel.scale = Vector2(0.8, 1.2);
			mod_panel_tween = set_up_tween(mod_panel_tween, Tween.TRANS_CUBIC, Tween.EASE_OUT);
			mod_panel_tween.tween_property(mod_panel, "scale", Vector2.ONE, 0.5);
		var set_worlds_state : Callable = func(is_on : bool = true):
			worlds_panel.visible = is_on;
			if !is_on: return;
			worlds_panel.scale = Vector2(0.8, 1.2);
			worlds_panel_tween = set_up_tween(worlds_panel_tween, Tween.TRANS_CUBIC, Tween.EASE_OUT);
			worlds_panel_tween.tween_property(worlds_panel, "scale", Vector2.ONE, 0.5);
			
		var set_off_state_to_everyone : Callable = func():
			set_settings_state.call(false);
			set_mods_state.call(false);
			set_worlds_state.call(false);
		
		set_off_state_to_everyone.call();
		match value:
			list.MAIN: set_off_state_to_everyone.call();
			list.MODS: set_mods_state.call(true);
			list.WORLDS: set_worlds_state.call(true);
		
		var old_state : main_menu_states_list = main_menu_state
		main_menu_state = value;
		main_menu_state_changed.emit(old_state, value);

@onready var buttons_container : Node2D = get_node("MainMenuButtons");
@onready var saves_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonSaves");
@onready var worlds_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonWorlds");
@onready var mods_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonMods");
@onready var exit_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonExit");

var mod_panel_tween : Tween;
var worlds_panel_tween : Tween;

func _ready() -> void:
	main_menu_state_changed.connect(func(_old,new): print(main_menu_states_list.find_key(new)));
	main_menu_bg.position = center;
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	exit_button.clicked.connect(get_tree().quit);
	worlds_button.clicked.connect(func():
		if main_menu_state != main_menu_states_list.WORLDS: main_menu_state = main_menu_states_list.WORLDS;
		else: main_menu_state = main_menu_states_list.MAIN);
	mods_button.clicked.connect(func():
		print(main_menu_states_list.find_key(main_menu_state));
		if main_menu_state != main_menu_states_list.MODS: main_menu_state = main_menu_states_list.MODS;
		else: main_menu_state = main_menu_states_list.MAIN;
		print(main_menu_states_list.find_key(main_menu_state)));
		
func _physics_process(_delta: float) -> void:
	mouse_position = get_global_mouse_position()
	
func set_up_tween(_tween : Tween = null, _trans : Tween.TransitionType = Tween.TRANS_CUBIC, _ease : Tween.EaseType = Tween.EASE_OUT) -> Tween:
	if _tween: _tween.kill();
	_tween = create_tween();
	_tween.set_ease(_ease);
	_tween.set_trans(_trans);
	return _tween;
	
