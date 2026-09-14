extends Node;

var data : Dictionary = {
};

const fallback_info : Dictionary = {
	"name" : "Какой то мод",
	"description" : "Мод в котором забыли сделать data.gd",
	"version" : "balls.0.experimental",
	"author" : "Забывчивый простофиля"
}

var id_by_name_data : Dictionary = {};
var id_by_technical_name_data : Dictionary = {};

var mods_list : Dictionary = {};

var worlds_list : Dictionary = {};

var commands_containers : Dictionary[String, Node] = {}

@onready var commands_container_for_commands_containers : Node = Node.new();

signal mods_loaded;
signal vanilla_loaded;
signal enabled_mods_loaded;

func _ready() -> void:
	add_child(commands_container_for_commands_containers);
	load_vanilla();
	load_mods();
	SaveLoad.load_settings();
	load_enabled_mods();
	
func load_vanilla() -> void:
	var path : String = "res://vanilla/";
	
	var mod_data_file : GDScript = load(path + "data.gd");
	mods_list["vanilla"] = mod_data_file.mod_info;
	data["vanilla"] = mod_data_file.mod_data;
	
	var new_command_container : CommandContainer = load(path + "commands.gd").new();
	commands_containers["vanilla"] = new_command_container;
	commands_container_for_commands_containers.add_child(new_command_container);
	
	var translation : Translation = load(path + "localization.csv");
	if translation: TranslationServer.add_translation(translation);
	
	var preloader : ResourcePreloader = load(path + "preloader.tscn").instantiate();
	add_child(preloader);
	
	id_by_name_data["vanilla"]= {};
	id_by_technical_name_data["vanilla"] = {};
	
	for id in data["vanilla"]["items"]:
		id_by_name_data["vanilla"][data["vanilla"]["items"][id]["name"]] = id;
		id_by_technical_name_data["vanilla"][data["vanilla"]["items"][id]["technical_name"]] = id;
	vanilla_loaded.emit();

func load_mods() -> void:
	var mods_dir_path: String = "user://mods";
	
	if not DirAccess.dir_exists_absolute(mods_dir_path):
		DirAccess.make_dir_absolute(mods_dir_path);
	
	var dir : DirAccess = DirAccess.open(mods_dir_path);
	if dir:
		dir.list_dir_begin();
		var file_name : String = dir.get_next();
		while file_name != "":
			if file_name.ends_with(".zip"):
				var full_pck_path : String = mods_dir_path.path_join(file_name);
				var fl : PackedStringArray = get_root_folders(full_pck_path);
				
				if !fl.has("vanilla") and !fl.has("classes") and !fl.has("globals") and fl.size() == 1:
					var data_file : GDScript = load_script_from_zip(full_pck_path, fl[0]+"/data.gd");
					var data_dictionary : Dictionary = get_data_dictionary(data_file).duplicate();
					data_dictionary.merge({"full_path" : full_pck_path});
					mods_list[fl[0]] = data_dictionary;
					
				else: print("this bro is doin som shit")
				
			file_name = dir.get_next();
		dir.list_dir_end();
	mods_loaded.emit();

func get_data_dictionary(script : GDScript) -> Dictionary:
	if !"mod_info" in script: return {};
	
	var info : Dictionary = script.mod_info;
	if !info.has("name"): info["name"] = fallback_info["name"];
	if !info.has("author"): info["author"] = fallback_info["author"];
	if !info.has("description"): info["description"] = fallback_info["description"];
	if !info.has("version"): info["version"] = fallback_info["version"];
	return info

func get_root_folders(zip_path: String) -> Array:
	var reader : ZIPReader = ZIPReader.new()
	if reader.open(zip_path) != OK: return []
		
	var files : PackedStringArray = reader.get_files()
	reader.close()
	
	var root_folders : PackedStringArray = []
	
	for path in files:
		if "/" in path and path.count("/") == 1:
			var folder_name : String = path.split("/")[0];
			if !root_folders.has(folder_name): root_folders.append(folder_name)
	return root_folders

func load_enabled_mods() -> void:
	for mod_path in Settings.enabled_mods:
		if FileAccess.file_exists(mod_path): ProjectSettings.load_resource_pack(mod_path, false);
	print(Settings.enabled_mods)
	
	var main_folders : PackedStringArray = DirAccess.get_directories_at("res://");
	main_folders.erase(".godot");
	main_folders.erase("classes");
	main_folders.erase("globals");
	main_folders.erase("vanilla");
	
	for mod_name in main_folders:
		var path : String = "res://" + mod_name + "/";
		
		var mod_data_file : RefCounted = ResourceLoader.load(path + "data.gd").new();
		if "mod_data" in mod_data_file and ResourceLoader.exists(path + "data.gd"): data[mod_name] = mod_data_file.mod_data;
		
		if ResourceLoader.exists(path + "commands.gd"):
			var new_command_container : CommandContainer = load(path + "commands.gd").new();
			commands_containers[mod_name] = new_command_container;
			commands_container_for_commands_containers.add_child(new_command_container);
			
		if ResourceLoader.exists(path + "localization.csv"):
			var translation : Translation = load(path + "localization.csv");
			if translation: TranslationServer.add_translation(translation);
		
		if ResourceLoader.exists(path + "preloader.tscn"):
			var preloader : ResourcePreloader = load(path + "preloader.tscn").instantiate();
			add_child(preloader);
				
	for mod_name in data:
		id_by_name_data[mod_name]= {};
		id_by_technical_name_data[mod_name] = {};
		if data[mod_name].has("items"):
			for id in data[mod_name]["items"]:
				id_by_name_data[mod_name][data[mod_name]["items"][id]["name"]] = id;
				id_by_technical_name_data[mod_name][data[mod_name]["items"][id]["technical_name"]] = id;
	
func get_id_by_name(_name : String = "Steel sword", is_name_technical : bool = false, mod_name : String = "vanilla") -> int:
	var id : int = -1;
	if is_name_technical and id_by_technical_name_data[mod_name].has(_name): id = id_by_technical_name_data[mod_name][_name];
	if !is_name_technical and id_by_name_data[mod_name].has(_name): id = id_by_name_data[mod_name][_name];
	return id;

func get_world(_name : String = "test_place", mod_name : String = "vanilla") -> World:
	if !data.has(mod_name) or !data[mod_name].has("worlds") or !data[mod_name]["worlds"].has(_name): return null;
	
	if ResourceLoader.exists("res://" + mod_name + "/scenes/worlds/" + _name + ".tscn"):
		var new_world : World = load("res://" + mod_name + "/scenes/worlds/" + _name + ".tscn").instantiate();
		return new_world;
	return null;
	
func load_script_from_zip(zip_path: String, script_inside_zip: String) -> GDScript:
	var reader := ZIPReader.new();
	var error := reader.open(zip_path);
	
	if error != OK: return null;
	
	var buffer := reader.read_file(script_inside_zip);
	reader.close();
	
	if buffer.is_empty(): return null;
	
	var script_code := buffer.get_string_from_utf8();
	
	var new_script := GDScript.new();
	new_script.source_code = script_code;
	
	var compile_error = new_script.reload();
	if compile_error != OK: return null;
	return new_script;

func execute_command(sender : Entity = null, _name : String = "give_item", mod_name : String = "vanilla", args : Array = []) -> Error:
	if !sender: return ERR_DOES_NOT_EXIST;
	args.push_front(sender);
	var command_container : CommandContainer = commands_containers[mod_name];
	var command : Callable = Callable(command_container, _name);
	var result : Error;
	if command.is_valid():
		result = command.callv(args);
		return result;
	return FAILED;
