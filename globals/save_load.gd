extends Node;

var settings_save_path = "user://settings.save";

@onready var settings_save_file : ConfigFile;

func save_settings() -> void:
	settings_save_file = ConfigFile.new();
	
	settings_save_file.set_value("video", "fullscreen", Settings.fullscreen);
	settings_save_file.set_value("audio", "music_volume", Settings.music_volume);
	settings_save_file.set_value("audio", "sounds_volume", Settings.sounds_volume);
	settings_save_file.set_value("audio", "master_volume", Settings.master_volume);
	
	settings_save_file.save(settings_save_path);
	
func load_settings() -> void:
	if FileAccess.file_exists(settings_save_path):
		settings_save_file = ConfigFile.new();
		
		settings_save_file.load(settings_save_path);
		
		Settings.fullscreen = settings_save_file.get_value("video", "fullscreen", true);
		Settings.music_volume = settings_save_file.get_value("audio", "music_volume", 1.0);
		Settings.sounds_volume = settings_save_file.get_value("audio", "sounds_volume", 1.0);
		Settings.master_volume = settings_save_file.get_value("audio", "master_volume", 1.0);
