extends CanvasLayer;
class_name GuiController;

var current_theme : MenuTheme;
var current_theme_id : int = 0;
var themes_list : Array[MenuTheme];

@onready var player : Player = owner;

@onready var tooltip : PanelContainer = get_node("Tooltip");
@onready var tooltip_label : RichTextLabel = get_node("Tooltip/Label");
@onready var tooltip_target : Marker2D = get_node("TooltipTarget");

@onready var dropped_item_tooltip : PanelContainer = get_node("DroppedItemTooltip");
@onready var dropped_item_tooltip_label : RichTextLabel = get_node("DroppedItemTooltip/Label");

@onready var theme_changed_sound_stream : AudioStream = load("res://vanilla/sfx/buttons/gui/theme_changed.mp3");

@onready var background_parallax : Parallax2D = get_node("MenuBG/Parallax2D");

#@onready var health_bar : TextureProgressBar = get_node("HealthBar");

@onready var mouse_slot : MouseSlot = get_node("MouseSlot");
@onready var slots_background : Sprite2D = get_node("HotbarBackground");
@onready var inventory_background : NinePatchRect = get_node("InventoryBackground");

@onready var pause_menu : Sprite2D = get_node("PauseMenu");
@onready var fps_label : Label = get_node("FPS");

#themes things
@onready var pause_menu_background : TextureRect = get_node("MenuBG");
@onready var pause_menu_background_icon : Sprite2D = get_node("MenuBG/Parallax2D/Icon");

@onready var pause_menu_button_close : PauseMenuButton = get_node("PauseMenu/PauseMenuButtonClose");
@onready var pause_menu_button_change_theme_forward : PauseMenuButton = get_node("PauseMenu/PauseMenuButtonChangeThemeForward");
@onready var pause_menu_button_change_theme_backward : PauseMenuButton = get_node("PauseMenu/PauseMenuButtonChangeThemeBackward");

@onready var pause_menu_checkbox_play_theme_music_constantly : PauseMenuCheckbox = get_node("PauseMenu/PauseMenuCheckbox")

@onready var theme_icon : Sprite2D = get_node("PauseMenu/ThemeIcon");
@onready var theme_label : Label = get_node("PauseMenu/ThemeName");

@onready var inventory_cooldown_timer : Timer = Timer.new();
@onready var pause_cooldown_timer : Timer = Timer.new();

@onready var command_line_background : ColorRect = get_node("CommandLineBackground");
@onready var command_line : CommandLine = get_node("CommandLineBackground/CommandLine");

@onready var item_drop_area : ItemDropArea = get_node("ItemDropArea");

@onready var item_chooser : ItemChooser = get_node("ItemChooser");

var slots : Array[GuiSlot];

var inventory_tween : Tween;
var pause_menu_background_tween : Tween;
var pause_menu_tween : Tween;

var inventory_hidden : bool = true;
var pause_menu_hidden : bool = true;

var mouse_position : Vector2 = Vector2.ZERO;

signal right_mouse_slot_pressed(slot : GuiSlot);
signal left_mouse_slot_pressed(slot : GuiSlot);

func _ready() -> void:
	inventory_cooldown_timer.one_shot = true;
	pause_cooldown_timer.one_shot = true;
	pause_menu_button_close.clicked.connect(on_pause_menu_button_close_clicked);
	pause_menu_button_change_theme_forward.clicked.connect(on_pause_menu_button_theme_change_clicked.bind(true));
	pause_menu_button_change_theme_backward.clicked.connect(on_pause_menu_button_theme_change_clicked.bind(false));
	
	pause_menu_checkbox_play_theme_music_constantly.is_checkboxed = true if Settings.play_theme_music_as_main else false;
	pause_menu_checkbox_play_theme_music_constantly.checkboxed.connect(func(): Settings.play_theme_music_as_main = true);
	pause_menu_checkbox_play_theme_music_constantly.uncheckboxed.connect(func(): Settings.play_theme_music_as_main = false);
	
	for i in slots_background.get_child_count():
		var new_slot : GuiSlot = slots_background.get_child(i)
		new_slot.hovered.connect(slot_hovered.bind(new_slot));
		new_slot.unhovered.connect(slot_unhovered.bind());
		slots.append(new_slot);
		
		new_slot.pressed.connect(func(): left_mouse_slot_pressed.emit(new_slot));
		new_slot.right_mouse_pressed.connect(func(): right_mouse_slot_pressed.emit(new_slot));
		
	for i in inventory_background.get_child_count():
		var new_slot : GuiSlot = inventory_background.get_child(i)
		new_slot.hovered.connect(slot_hovered.bind(new_slot));
		new_slot.unhovered.connect(slot_unhovered.bind());
		slots.append(new_slot);
		
		new_slot.pressed.connect(func(): left_mouse_slot_pressed.emit(new_slot));
		new_slot.right_mouse_pressed.connect(func(): right_mouse_slot_pressed.emit(new_slot));
	
	add_child(inventory_cooldown_timer);
	add_child(pause_cooldown_timer);
	
	update_themes_list();
	set_theme_by_name("Uzi Doorman onelove <3");
	if Settings.play_theme_music_as_main: 
		SoundManager.theme_music_player.stream = current_theme.theme_music;
		SoundManager.play_theme_music(true);
	
	item_drop_area.pressed.connect(on_item_drop_area_pressed);
	left_mouse_slot_pressed.connect(on_left_mouse_slot_pressed);
	right_mouse_slot_pressed.connect(on_right_mouse_slot_pressed);

	player.item_to_be_picked_up_changed.connect(func(item):
		if item == null: dropped_item_tooltip.visible = false;
		else:
			var mod_name : String = item.mod_name;
			var _name : String = GlobalData.data[mod_name]["items"][item.id]["name"];
			var rareness_parts : PackedStringArray = GlobalData.data[mod_name]["items"][item.id]["rareness"].split(".");
			
			var rareness : String = "";
			if rareness_parts: rareness = GlobalData.data[rareness_parts[0]]["rareness_styles"][rareness_parts[1]];
			else: rareness = GlobalData.data["vanilla"]["rareness_styles"]["common"];
			
			_name = rareness % _name;
			
			dropped_item_tooltip_label.text = _name;
			dropped_item_tooltip_label.text += GlobalData.data[mod_name]["items"][item.id]["description"];
			dropped_item_tooltip.size = Vector2.ZERO;
			dropped_item_tooltip.visible = true if !get_tree().paused else false;
		);
	
func on_item_drop_area_pressed() -> void:
	if mouse_slot.item != null:
		mouse_slot.item.drop();
		mouse_slot.item = null;
	
func on_left_mouse_slot_pressed(slot : GuiSlot) -> void:
	if inventory_hidden: return;
	
	if mouse_slot.item == null or slot.item == null:
		switch_items(slot, mouse_slot);
		slot_hovered(slot);
		return
		
	if slot.item.scene_file_path == mouse_slot.item.scene_file_path:
		var difference : int = slot.item.amount + mouse_slot.item.amount - slot.item.max_stack;
		if mouse_slot.item.amount == mouse_slot.item.max_stack or slot.item.amount == slot.item.max_stack :
			switch_items(slot, mouse_slot);
			slot_hovered(slot);
			return;
		if difference > 0:
			slot.item.amount = slot.item.max_stack;
			mouse_slot.item.amount = difference;
		else:
			slot.item.amount += mouse_slot.item.amount;
			mouse_slot.item.queue_free();
	else:
		switch_items(slot, mouse_slot);
		slot_hovered(slot);
	
func on_right_mouse_slot_pressed(slot : GuiSlot) -> void:
	if inventory_hidden: return;
	
	if mouse_slot.item == null:
		if slot.item == null: return;
		if slot.item.amount < 2:
			switch_items(slot, mouse_slot);
			slot_hovered(slot);
			return;
		var division : int = ceili((float(slot.item.amount)/2));
		player.give_item(slot.item.id, slot.item.mod_name, division, mouse_slot);
		slot.item.amount -= division;
		return;
		
	if slot.item == null:
		if mouse_slot.item == null: return;
		if mouse_slot.item.amount <= 1:
			switch_items(slot, mouse_slot);
		else:
			player.give_item(mouse_slot.item.id, mouse_slot.item.mod_name, 1, slot);
			mouse_slot.item.amount -= 1;
		slot_hovered(slot);
		return;
		
	if slot.item.scene_file_path == mouse_slot.item.scene_file_path:
		if slot.item.amount < slot.item.max_stack:
			if mouse_slot.item.amount <= 1: mouse_slot.item.queue_free();
			else: mouse_slot.item.amount -= 1;
			slot.item.amount += 1;
	
func switch_items(slot1 : GuiSlot, slot2 : GuiSlot) -> void:
	var old_item : Item = slot1.item;
	slot1.item = slot2.item;
	slot2.item = old_item;
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if command_line.visible: switch_command_line();
		else: switch_pause();
	if Input.is_action_just_pressed("`"):
		if !command_line.visible and pause_menu_hidden: switch_command_line();
	if !get_tree().paused and Input.is_action_just_pressed("tab"): switch_inventory();
	
func _physics_process(delta: float) -> void:
	fps_label.text = "FPS:" + str(Engine.get_frames_per_second());
	mouse_position = get_viewport().get_mouse_position();
	var screen_size : Vector2 = get_viewport().get_visible_rect().size;
	
	if !get_tree().paused:
		if player.item_to_be_picked_up:
			var item_screen_pos: Vector2 = player.item_to_be_picked_up.pickup_zone.get_global_transform_with_canvas().origin;
			dropped_item_tooltip.position = dropped_item_tooltip.position.lerp(item_screen_pos + Vector2(20.0, 15.0), 0.6);
		
		tooltip_target.position = tooltip_target.position.lerp(mouse_position, 12.0 * delta);
		
		var _offset : Vector2 = Vector2(
			-tooltip.size.x if mouse_position.x > screen_size.x * 0.5 else 5.0,
			-tooltip.size.y if mouse_position.y > screen_size.y * 0.5 else 5.0);
		
		tooltip.position = lerp(tooltip.position, tooltip_target.position + _offset, 40.0 * delta);
		
		var difference : Vector2 = tooltip_target.position - mouse_position;
		
		var target_scale : Vector2 = Vector2(
			remap(difference.x, -50.0, 50.0, -1.0, 1.0),
			remap(difference.y, -50.0, 50.0, -1.0, 1.0));
		
		tooltip.scale = lerp(tooltip.scale, target_scale + Vector2.ONE, 10.0 * delta);
	
func switch_command_line() -> void:
	var _is_enabled : bool = command_line.visible;
	command_line.visible = !_is_enabled;
	command_line_background.visible = !_is_enabled;
	if _is_enabled: command_line.release_focus();
	else: command_line.grab_focus();
	get_tree().paused = !_is_enabled;
	
func switch_pause() -> void:
	if pause_cooldown_timer.is_stopped():
		pause_cooldown_timer.start(1.0);
		if pause_menu_background_tween: pause_menu_background_tween.kill();
		pause_menu_background_tween = create_tween();
		pause_menu_background_tween.set_ease(Tween.EASE_IN_OUT);
		pause_menu_background_tween.set_trans(Tween.TRANS_CUBIC);
		SaveLoad.save_settings();
		if pause_menu_hidden:
			if SoundManager.theme_music_player.stream == null: SoundManager.theme_music_player.stream = current_theme.theme_music;
			SoundManager.play_theme_music();
			pause_menu_background_tween.tween_property(pause_menu_background, "position:y", 0.0, 0.5);
			pause_menu_background_tween.parallel().tween_property(pause_menu, "position:y", 162.0, 0.7);
			get_tree().paused = true;
			get_tree().call_group("pause_menu_button", "set", "is_enabled", true);
			get_tree().call_group("pause_menu_button", "set", "is_hand_checking", true);
			pause_menu_hidden = not pause_menu_hidden;
			await get_tree().create_timer(1.0).timeout;
			get_tree().call_group("pause_menu_button", "set", "is_hand_checking", false);
		else:
			get_tree().paused = false;
			if SoundManager.is_main_player_now_cool: SoundManager.play_main_music();
			else: SoundManager.play_music();
			pause_menu_background_tween.tween_property(pause_menu_background, "position:y", -324.0, 0.5);
			pause_menu_background_tween.parallel().tween_property(pause_menu, "position:y", -100.0, 0.4);
			get_tree().call_group("pause_menu_button", "set", "is_enabled", false);
			pause_menu_hidden = not pause_menu_hidden;

func switch_inventory() -> void:
	if inventory_cooldown_timer.is_stopped():
		inventory_cooldown_timer.start(0.5);
		
		if inventory_tween: inventory_tween.kill();
		inventory_tween = create_tween();
		inventory_tween.set_ease(Tween.EASE_IN_OUT);
		inventory_tween.set_trans(Tween.TRANS_CUBIC);
		
		if inventory_hidden: inventory_tween.tween_property(inventory_background, "position:y", 56.0, 0.4);
		else:
			tooltip.visible = false; 
			inventory_tween.tween_property(inventory_background, "position:y", -200.0, 0.4);
		
		if !inventory_hidden and mouse_slot.item and get_free_slot():
			get_free_slot().item = mouse_slot.item;
			mouse_slot.item = null;
		
		item_drop_area.visible = inventory_hidden;
		inventory_hidden = !inventory_hidden

func get_free_slot() -> GuiSlot:
	for slot in slots:
		if slot.item == null: return slot;
	return null

func update_themes_list() -> void:
	themes_list.resize(0);
	
	var file_paths : Array[String];
	var dir: DirAccess = DirAccess.open("res://vanilla/resources/menu_themes/");
	dir.list_dir_begin();
	var file_name : String = dir.get_next();
	
	while file_name != "":
		if !dir.current_is_dir():
			var clean_name : String = file_name.replace(".remap", "").replace(".import", "");
			if clean_name.ends_with(".tres"):
				var full_path : String = "res://vanilla/resources/menu_themes/".path_join(clean_name);
				if !file_paths.has(full_path):
					file_paths.append(full_path);
		file_name = dir.get_next();
	dir.list_dir_end();
	
	for i in file_paths.size(): themes_list.append(load(file_paths[i]))

func set_theme_by_name(theme_name : String = "Classic") -> void:
	var searched_theme : MenuTheme;
	for i in themes_list.size():
		if themes_list[i].name == theme_name:
			searched_theme = themes_list[i];
	set_theme(searched_theme);

func set_theme(_theme : MenuTheme) -> void:
	current_theme = _theme;
	current_theme_id = themes_list.find(_theme);
	
	if !pause_menu_hidden and SoundManager.theme_music_player.stream != _theme.theme_music:
		SoundManager.play_theme_music(false, _theme.theme_music);
	
	get_tree().call_group("main_color", "set", "self_modulate", current_theme.main_color);
	get_tree().call_group("second_color", "set", "self_modulate", current_theme.second_color);
	if player.current_slot: player.current_slot.slot.self_modulate *= Color(1.4, 1.4, 1.4, 1.0);
	theme_icon.texture = current_theme.icon;
	pause_menu_background_icon.texture = current_theme.background_icon;
	pause_menu_background_icon.rotation_degrees = current_theme.background_icon_rotation;
	
	background_parallax.repeat_size = current_theme.parallax_size;
	background_parallax.autoscroll = current_theme.parallas_autoscroll_speed;
	background_parallax.repeat_times = current_theme.parallax_icon_repeat_times;
	
	var gradient_resource : Gradient = (pause_menu_background.texture as GradientTexture2D).gradient;
	gradient_resource.set_color(0, current_theme.first_background_color);
	gradient_resource.set_color(1, current_theme.second_background_color);
	
	var stylebox : StyleBoxTexture = tooltip.get_theme_stylebox("panel") as StyleBoxTexture;
	stylebox.modulate_color = current_theme.second_color;
	theme_label.text = "Theme: " + current_theme.name;
	
func on_pause_menu_button_close_clicked() -> void: if !pause_menu_hidden: switch_pause();

func on_pause_menu_button_theme_change_clicked(is_forward : bool = true) -> void:
	if is_forward:
		if current_theme_id < themes_list.size()-1: set_theme(themes_list[current_theme_id+1]);
		else: set_theme(themes_list[0]);
	else:
		if current_theme_id > 0: set_theme(themes_list[current_theme_id-1]);
		else: set_theme(themes_list[themes_list.size()-1]);

func slot_hovered(_slot : GuiSlot) -> void:
	if _slot.item:
		item_chooser.target_slot = _slot
		
		var item : Item = _slot.item;
		var mod_name : String = item.mod_name;
		var _name : String = GlobalData.data[mod_name]["items"][item.id]["name"];
		var rareness_parts : PackedStringArray = GlobalData.data[mod_name]["items"][item.id]["rareness"].split(".");
		
		var rareness : String = "";
		if rareness_parts: rareness = GlobalData.data[rareness_parts[0]]["rareness_styles"][rareness_parts[1]];
		else: rareness = GlobalData.data["vanilla"]["rareness_styles"]["common"];
		
		_name = rareness % _name;
		
		tooltip_label.text = _name;
		tooltip_label.text += GlobalData.data[mod_name]["items"][item.id]["description"];
		tooltip.size = Vector2.ZERO;
		tooltip.visible = true if !get_tree().paused else false;
	else:
		tooltip.visible = false;
func slot_unhovered() -> void:
	tooltip.visible = false;
	item_chooser.target_slot = null;
