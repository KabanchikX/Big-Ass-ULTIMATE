extends HSlider;
class_name SoundSlider;

enum bus_list{Master, Music, Sounds};
@export var bus : bus_list = bus_list.Master;

@onready var drag_sound : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_pressed.mp3");
@onready var undrag_sound : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_unpressed.mp3");
@onready var hover_sound : AudioStream = load("res://vanilla/sfx/buttons/gui/interface_button_hovered.mp3");

@onready var sprite : Sprite2D = get_node("Sprite");

func _ready() -> void:
	mouse_exited.connect(func(): release_focus());
	drag_ended.connect(func(_value : bool): SoundManager.play_interface_sound(undrag_sound));
	drag_started.connect(func(): SoundManager.play_interface_sound(drag_sound));
	mouse_entered.connect(func(): SoundManager.play_interface_sound(hover_sound));
	value_changed.connect(on_value_changed);
	
	sprite.frame = int(bus);
	sprite.position.x = size.x + 7.0;
	
	match bus:
		bus_list.Master: value = Settings.master_volume * 100.0;
		bus_list.Music: value = Settings.music_volume * 100.0;
		bus_list.Sounds: value = Settings.sounds_volume * 100.0;
	
func on_value_changed(_value : float = 0.0) -> void:
	match bus:
		bus_list.Master: Settings.master_volume = _value * 0.01;
		bus_list.Music: Settings.music_volume = _value * 0.01;
		bus_list.Sounds: Settings.sounds_volume = _value * 0.01;
	
