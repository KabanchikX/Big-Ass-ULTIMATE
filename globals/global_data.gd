extends Node;

var data : Dictionary = {
};

var id_by_name_data : Dictionary = {};
var id_by_technical_name_data : Dictionary = {};

var mods_list : Dictionary = {
};

func _ready() -> void:	
	load_pck();
	load_mods();
	
func load_pck() -> void:
	var mods_dir_path: String = "user://mods";
	
	if not DirAccess.dir_exists_absolute(mods_dir_path):
		DirAccess.make_dir_absolute(mods_dir_path);
	
	var dir : DirAccess = DirAccess.open(mods_dir_path);
	if dir:
		dir.list_dir_begin();
		var file_name : String = dir.get_next();
		while file_name != "":
			if file_name.ends_with(".pck"):
				var full_pck_path : String = mods_dir_path.path_join(file_name);
				ProjectSettings.load_resource_pack(full_pck_path, true);
			file_name = dir.get_next();
		dir.list_dir_end();
		
func load_mods() -> void:
	id_by_name_data.clear();
	id_by_technical_name_data.clear();
	
	var main_folders : PackedStringArray = DirAccess.get_directories_at("res://");
	main_folders.erase(".godot");
	main_folders.erase("classes");
	main_folders.erase("globals");
	
	for mod_name in main_folders:
		var path : String = "res://" + mod_name + "/";
		
		if ResourceLoader.exists(path + "localization.csv"):
			var translation : Translation = load(path + "localization.csv");
			if translation: TranslationServer.add_translation(translation);
		
		if ResourceLoader.exists(path + "data.gd"):
			var mod_data_file : RefCounted = ResourceLoader.load(path + "data.gd").new();
			if "mod_info" in mod_data_file: mods_list[mod_name] = mod_data_file.mod_info;
			if "mod_data" in mod_data_file: data[mod_name] = mod_data_file.mod_data;
		else:
			var fallback_info : Dictionary = {
				mod_name: {
					"name" : "Какой то мод",
					"description" : "Мод в котором забыли сделать data.gd",
					"version" : "balls.0.experimental",
					"author" : "Забывчивый простофиля"
				}
			}
			mods_list.merge(fallback_info);
	
	for mod_name in data:
		id_by_name_data[mod_name]= {};
		id_by_technical_name_data[mod_name] = {};
		if data[mod_name].has("items"):
			for id in data[mod_name]["items"]:
				id_by_name_data[mod_name][data[mod_name]["items"][id]["name"]] = id;
				id_by_technical_name_data[mod_name][data[mod_name]["items"][id]["technical_name"]] = id;
	
	print(mods_list)
	
func get_id_by_name(_name : String = "Steel sword", is_name_technical : bool = false, mod_name : String = "vanilla") -> int:
	var id : int = -1;
	if is_name_technical and id_by_technical_name_data[mod_name].has(_name): id = id_by_technical_name_data[mod_name][_name];
	if !is_name_technical and id_by_name_data[mod_name].has(_name): id = id_by_name_data[mod_name][_name];
	return id;
	
