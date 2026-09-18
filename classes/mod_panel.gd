extends Panel;
class_name ModPanel;

@onready var mod_buttons_container : VBoxContainer = get_node("ScrollContainer/VBoxContainer");
@onready var mod_button_scene : PackedScene = load("res://vanilla/scenes/main_menu_mod_button.tscn");

@onready var mod_description : RichTextLabel = get_node("ModDescription");
@onready var reload_button : MainMenuButton = get_node("MainMenuButtonReloadMods");

func update_mods_list() -> void:
	for mod in mod_buttons_container.get_children(): mod.queue_free();
	
	for mod_name in GlobalData.mods_list:
		var new_button : MainMenuModButton = mod_button_scene.instantiate();
		new_button.mod_name = mod_name;
		mod_buttons_container.add_child(new_button);
		new_button.hovered.connect(func(): mod_description.text = GlobalData.mods_list[mod_name]["description"]);
		
func _ready() -> void:
	update_mods_list();
	
	reload_button.clicked.connect(func():
		OS.create_process(OS.get_executable_path(), OS.get_cmdline_args())
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST));
