extends Panel;
class_name WorldPanel;

@onready var world_buttons_container : VBoxContainer = get_node("ScrollContainer/VBoxContainer");
@onready var world_button_scene : PackedScene = load("res://vanilla/scenes/main_menu_world_button.tscn");

@onready var world_description : RichTextLabel = get_node("WorldDescription");

func update_world_list() -> void:
	for world in world_buttons_container.get_children(): world.queue_free();
	
	for mod_name in GlobalData.data:
		if !GlobalData.data[mod_name].has("worlds"): return
		for world in GlobalData.data[mod_name]["worlds"]:
			var new_button : MainMenuWorldButton = world_button_scene.instantiate();
			new_button.world_name = mod_name+"."+world;
			world_buttons_container.add_child(new_button);
			new_button.hovered.connect(func(): world_description.text = GlobalData.data[mod_name]["worlds"][world]["description"]);
				
func _ready() -> void:
	update_world_list();
