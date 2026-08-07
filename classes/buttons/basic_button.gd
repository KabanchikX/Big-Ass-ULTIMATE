extends Control;
class_name BasicButton;##Ебанные баттоны обычные, убейте их

var is_enabled : bool = true :
	set(value):
		if value: enabled.emit();
		else: disabled.emit();
		is_enabled = value;
var is_hovered : bool = false : 
	set(value):
		if is_enabled:
			if value:
				if !is_hovered: hovered.emit();
			else:
				unhovered.emit();
				if is_pressed:
					is_hovered = false;
					is_pressed = false;
			is_hovered = value;
var is_pressed : bool = false :
	set(value):
		if is_enabled:
				if value: pressed.emit();
				else: unpressed.emit();
				if !value and is_pressed:
					if is_hovered: clicked.emit();
					else: canceled.emit();
				is_pressed = value;
var is_hand_checking : bool = false :
	set(value):
		if value: is_hovered = false;
		is_hand_checking = value;

signal pressed;
signal unpressed;
signal canceled;
signal clicked;
signal hovered;
signal unhovered;
signal disabled;
signal enabled;

func _ready() -> void:
	mouse_entered.connect(on_mouse.bind(true));
	mouse_exited.connect(on_mouse.bind(false));

func _physics_process(_delta: float) -> void:
	if is_hand_checking: update_hover_check();

func on_mouse(value : bool) -> void: is_hovered = value;

func _gui_input(event: InputEvent) -> void:
	if is_enabled and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = event.pressed;
		
func update_hover_check() -> void:
	if get_global_rect().has_point(get_global_mouse_position()) and !is_hovered: on_mouse(true);
	if !get_global_rect().has_point(get_global_mouse_position()) and is_hovered: on_mouse(false);
