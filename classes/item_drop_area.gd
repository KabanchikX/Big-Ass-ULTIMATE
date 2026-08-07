extends Control;
class_name ItemDropArea;

signal pressed;

func _ready() -> void:
	gui_input.connect(func(event : InputEvent) -> void:
		if event.is_action_pressed("mouse_left", false): pressed.emit());
