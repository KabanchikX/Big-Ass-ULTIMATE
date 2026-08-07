extends Entity;

@export var is_friendly : bool = false : 
	set(value):
		is_friendly = value;
		collision_layer = 0;
		collision_layer = 0b1 if value else 0b10;
		
@onready var hit_sound_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();

func _ready() -> void:
	super._ready();
	shadow.position.y = 15.0;
	shadow.size.x = 30.0;
	
	sprite_container = get_node("Sprite");
	
	is_friendly = is_friendly;
	
	collision_mask = 0;
	collision_mask = 0b111;
	
	hit_sound_player.bus = "Sounds";
	hit_sound_player.stream = load("res://vanilla/sfx/damaged/dummy_hit_sound.mp3");
	hit_sound_player.volume_linear = 2.5;
	add_child(hit_sound_player);
	hit_sound_player.position = Vector2.ZERO;
	damaged.connect(func(_value):
		hit_sound_player.pitch_scale = randf_range(0.95, 1.05);
		SoundManager.play_player_with_protection(hit_sound_player, hit_sound_player.stream));
	
func _physics_process(_delta: float) -> void:
	return;
