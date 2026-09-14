extends World;

var menu_color : Color;

@export var main_menu_bg : Sprite2D;
@export var camera : Camera2D;
const center : Vector2 = Vector2(288.0, 162.0);
var mouse_position : Vector2 = Vector2.ZERO;

signal main_menu_state_changed(old_value : main_menu_states_list, new_value : main_menu_states_list);

enum main_menu_states_list {MAIN, SAVES, WORLDS, MODS};

var main_menu_state : main_menu_states_list = main_menu_states_list.MAIN :
	set(value):
		var list = main_menu_states_list;
		
		var set_settings_state : Callable = func(is_on : bool = true):
			return;
			
		match value:
			list.MAIN:return
		
		var old_state : main_menu_states_list = main_menu_state
		main_menu_state = value;
		main_menu_state_changed.emit(old_state, value);

@onready var buttons_container : Node2D = get_node("MainMenuButtons");
@onready var saves_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonSaves");
@onready var worlds_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonWorlds");
@onready var mods_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonMods");
@onready var exit_button : MainMenuButton = get_node("MainMenuButtons/MainMenuButtonExit");

func _ready() -> void:
	main_menu_bg.position = center;
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	exit_button.clicked.connect(get_tree().quit);
	worlds_button.clicked.connect(func(): GameManager.world = GlobalData.get_world("test_place", "vanilla"));
	
func _physics_process(_delta: float) -> void:
	mouse_position = get_global_mouse_position()
	
func set_up_tween(_tween : Tween = null, _trans : Tween.TransitionType = Tween.TRANS_CUBIC, _ease : Tween.EaseType = Tween.EASE_OUT) -> Tween:
	if _tween: _tween.kill();
	_tween = create_tween();
	_tween.set_ease(_ease);
	_tween.set_trans(_trans);
	return _tween;
	
