extends Node;

var music_volume : float = 1.0 :
	set(value):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value);
		music_volume = value;
var sounds_volume : float = 1.0:
	set(value):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sounds"), value);
		sounds_volume = value;
var master_volume : float = 1.0:
	set(value):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value);
		master_volume = value;

var play_theme_music_as_main : bool = true;

var enabled_mods : Array[String] = [];
enum languages_list{en, ru};
var language : languages_list = languages_list.en :
	set(value):
		if language == value or !value: return;
		var old_value = language;
		language = value;
		language_changed.emit(old_value, value);

var fullscreen : bool = true :
	set(value):
		fullscreen = value;
		get_window().mode = Window.MODE_FULLSCREEN if value else Window.MODE_WINDOWED;

signal language_changed(old : languages_list, new : languages_list);

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveLoad.save_settings();
		get_tree().quit() 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	SaveLoad.load_settings();
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("f11"): fullscreen = !fullscreen;
