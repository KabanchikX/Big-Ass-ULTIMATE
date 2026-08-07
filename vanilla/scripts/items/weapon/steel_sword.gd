extends Weapon;

@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer");
@onready var sprite : Sprite2D = get_node("Sprite");
@onready var shooting_point : Marker2D = get_node("ShootingPoint");

@onready var block_hitbox : Area2D = get_node("Sprite/Blockbox");
@onready var hitbox : Area2D = get_node("Sprite/Hitbox");
@onready var particles : CPUParticles2D = get_node("Sprite/Particles");

var projectile_pool : Array[Projectile] = [];
var attack_effects_pool : Array[AttackEffect] = [];

@onready var sound_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var sound_player_playback : AudioStreamPlayback

@onready var block_stream : AudioStream = load("res://vanilla/sfx/steel_sword_block.mp3");
@onready var slash_stream : AudioStream = load("res://vanilla/sfx/projectiles/steel_sword_slash.mp3");
@onready var penis_stream : AudioStream = load("res://vanilla/sfx/projectiles/steel_sword_slash.mp3");

@onready var attack_effects_container : Node = Node.new();

func _ready() -> void:
	super._ready();
	y_sort_enabled = true if master else false;
	pickup_zone.collision_layer = 0 if master else 0b1000000;
	pickup_zone.collision_mask = 0;
	pickup_zone.monitoring = false;
	
	shadow.visible = false;
	
	max_stack = 1;
	add_child(attack_effects_container);
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL;
	if is_active: animation_player.play("idle");
	animation_player.animation_finished.connect(on_animation_finished);
	
	block_hitbox.set_collision_layer_value(4, true);
	block_hitbox.get_child(0).set_deferred("disabled", true);
	
	load_projectiles_pool(load("res://vanilla/scenes/projectiles/steel_sword_slash.tscn"), 4, projectile_pool);
	load_attack_effects_pool(load("res://vanilla/scenes/attack_effects/slash_attack_effect.tscn"),25, attack_effects_pool);
	
	add_child(sound_player);
	sound_player.stream = AudioStreamPolyphonic.new()
	sound_player.play();
	
	sound_player_playback = sound_player.get_stream_playback() as AudioStreamPlaybackPolyphonic;
	
	sound_player.bus = "Sounds";
	
func play_sound(stream) -> void:
	if sound_player_playback:
		var thingy = sound_player_playback.play_stream(stream);
		sound_player_playback.set_stream_pitch_scale(thingy, randf_range(0.95, 1.05));

func _input(event: InputEvent) -> void:
	if master == null: return;
	if is_active:
		if !master.is_busy:
			if event.is_action_pressed("mouse_left") and !event.is_echo() and animation_player.current_animation == "idle":
				slash();
			
			if event.is_action_pressed("f") and !event.is_echo():
				if animation_player.current_animation != "block": block_hitbox.get_child(0).set_deferred("disabled", false);
				animation_player.play("block");
			if event.is_action_released("f") and animation_player.current_animation == "block":
				block_hitbox.get_child(0).set_deferred("disabled", true);
				animation_player.play("idle");
		
func slash() -> void:
	if is_active:
		animation_player.playback_default_blend_time = 0.0;
		animation_player.play("slash");
		animation_player.playback_default_blend_time = 0.1;
		master.apply_busy(0.35);
		look_at(master.target);
		
		var free_projectile : Projectile = projectile_pool[get_free_projectile_id(projectile_pool)];
		free_projectile.change_active_state(true, shooting_point.global_position, global_rotation);
		
		play_sound(slash_stream);
		
func _physics_process(delta: float) -> void:
	animation_player.advance(delta);
	if master.sprite_container: particles.scale.x = master.sprite_container.scale.x;
	if is_active:
		if animation_player.current_animation == "idle": rotation = lerp(rotation, 0.0, delta*10);
		if animation_player.current_animation == "block": look_at(master.target);

func set_active(is_active_ : bool = true) -> void:
	show_behind_parent = !is_active_;
	rotation *= float(is_active); 
	animation_player.play("idle" if is_active_ else "hidden");
	if !is_active_: block_hitbox.get_child(0).set_deferred("disabled", true);

func on_animation_finished(anim_name : String) -> void:
	if anim_name == "slash":
		animation_player.play("idle");

func handle_projectile(_projectile : Projectile) -> void:
	particles.restart();
	particles.position.y = -25.0 + randf_range(-5.0, 5.0);
	particles.emitting = true;
	play_sound(block_stream);

func on_hitted(_body : Node2D) -> void:
	if _body.has_method("apply_damage"):
		var free_attack_effect : AttackEffect = attack_effects_pool[get_free_attack_effect_id(attack_effects_pool)];
		free_attack_effect.global_position = _body.global_position;
		free_attack_effect.is_active = true;
