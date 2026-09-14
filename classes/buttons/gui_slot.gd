extends BasicButton;
class_name GuiSlot;

var item : Item: 
	set(value):
		if item == value: return;
		var _old_item : Item = item;
		if item:
			if item.amount_changed.is_connected(on_item_amount_changed):
				item.amount_changed.disconnect(on_item_amount_changed);
			if item.tree_exiting.is_connected(on_item_tree_exiting):
				item.tree_exiting.disconnect(on_item_tree_exiting);
		if value:
			value.amount_changed.connect(on_item_amount_changed);
			value.tree_exiting.connect(on_item_tree_exiting);
		
		if value != null and GlobalData.data.has(value.mod_name):
			var technical_name : String = GlobalData.data[value.mod_name]["items"][value.id]["technical_name"];
			icon.texture = load("res://" + value.mod_name + "/sprites/items/" + technical_name + "/icon.png");
			amount = value.amount;
		else:
			icon.texture = null;
			amount = 0;
		item = value;
		item_changed.emit(_old_item, value);
		
@onready var hovered_sound_stream : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_hovered.mp3");

@onready var slot : Sprite2D = get_child(0);
@onready var icon : Sprite2D = slot.get_child(0);
@onready var icon_shadow : Sprite2D = icon.get_child(0);

@onready var amount_label : Label = slot.get_node("Amount");

var amount : int = 0 :
	set(value):
		amount = value;
		if value > 1: amount_label.visible = true;
		else: amount_label.visible = false;
		amount_label.text = str(amount);

var tween : Tween;

signal item_changed(old_item : Item, new_item : Item);
signal right_mouse_pressed();

func _ready() -> void:
	super._ready();
	icon.texture_changed.connect(func(): icon_shadow.texture = icon.texture);
	hovered.connect(on_hovered_state_changed.bind(true));
	unhovered.connect(on_hovered_state_changed.bind(false));
	
	icon.texture = icon.texture;
	amount = amount;
	item = item;

func on_item_tree_exiting() -> void:
	item = null;

func on_item_amount_changed(value) -> void:
	amount = value;

func on_hovered_state_changed(is_hovered_ : bool = true) -> void:
	if tween: tween.kill();
	tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.set_ease(Tween.EASE_OUT);
	
	var _is_hovered : int = int(is_hovered_);
	tween.tween_property(slot, "rotation_degrees", -7.0 * _is_hovered , 0.25);
	tween.parallel().tween_property(slot, "scale", Vector2(1.0 + 0.1 * _is_hovered, 1.0 + 0.1 * _is_hovered), 0.25);
	tween.parallel().tween_property(icon, "rotation_degrees", -16.0 * _is_hovered, 0.4);
	tween.parallel().tween_property(icon, "scale", Vector2(1.0 + 0.2 * _is_hovered, 1.0 + 0.2 * _is_hovered), 0.4);
	tween.parallel().tween_property(icon_shadow, "scale", Vector2(1.0 - 0.2 * _is_hovered, 1.0 - 0.2 * _is_hovered), 0.4);
	if is_hovered_ and is_processing(): SoundManager.play_interface_sound(hovered_sound_stream);

func _gui_input(event: InputEvent) -> void:
	super._gui_input(event);
	if is_enabled and event.is_action_pressed("mouse_right"):
		right_mouse_pressed.emit();
	
func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
