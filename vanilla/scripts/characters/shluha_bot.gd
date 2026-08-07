extends Player;

var value_difference : float = 0.0;

func _ready() -> void:
	hit_sound_stream = load("res://vanilla/sfx/damaged/shluha_bot_damaged.mp3");
	super._ready();
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL;

func _physics_process(delta: float) -> void:
	super._physics_process(delta);
	animation_player.advance(delta);
	
	if state != states_list.DEAD:
		value_difference = face.global_position.y - get_global_mouse_position().y;	
		face.rotation_degrees += (15 * ((value_difference + 270.0) / 495.0) - 7.5)*-1;
		face.position.y += ((3.0 * ((value_difference + 270.0) / 495.0) - 1.5))*-1;
