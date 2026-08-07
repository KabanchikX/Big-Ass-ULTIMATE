extends BasicButton;
class_name ClassicButton;

@export_group("Textures")
@export var idle_texture : Texture2D;
@export var pressed_texture : Texture2D;
@export var hover_texture : Texture2D;
@export var disable_texture : Texture2D;

@export_category("Sounds")
@export var hover_sound : AudioStream;
@export var pressed_sound : AudioStream;
@export var unpressed_sound : AudioStream;
@export var canceled_sound : AudioStream;

@onready var sound : AudioStreamPlayer = AudioStreamPlayer.new();
var playback : AudioStreamPlayback;
@onready var sprite : Sprite2D = get_child(0);

func _ready() -> void:
	super._ready();
	add_child(sound);
	
	sound.stream = AudioStreamPolyphonic.new()
	sound.play();
	
	playback = sound.get_stream_playback();
	
	sprite.texture = idle_texture;
	
	canceled.connect(on_canceled);
	pressed.connect(on_pressed);
	clicked.connect(on_clicked);
	hovered.connect(on_hovered);
	unhovered.connect(on_unhovered);

func on_canceled() -> void:
	sprite.texture = idle_texture;
	play_sound(canceled_sound);
func on_pressed() -> void:
	sprite.texture = pressed_texture;
	play_sound(pressed_sound);
func on_clicked() -> void:
	sprite.texture = idle_texture if !is_hovered else hover_texture;
	play_sound(unpressed_sound);
func on_hovered() -> void:
	sprite.texture = hover_texture;
	play_sound(hover_sound);
func on_unhovered() -> void:
	sprite.texture = idle_texture;

func play_sound(stream : AudioStream) -> void:
	if playback: playback.play_stream(stream);
