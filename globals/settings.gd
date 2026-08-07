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

var fullscreen : bool = true :
	set(value):
		fullscreen = value;
		get_window().mode = Window.MODE_FULLSCREEN if value else Window.MODE_WINDOWED;

func _ready() -> void:
	SaveLoad.load_settings();
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("f11"): fullscreen = !fullscreen;
