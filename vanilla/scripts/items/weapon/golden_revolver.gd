extends Weapon;

@onready var sprite : Sprite2D = get_node("Sprite");
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer");

@onready var shot_particles : CPUParticles2D = get_node("ShotParticles");

@onready var shot_sound_stream : AudioStream = load("res://vanilla/sfx/golden_revolver.mp3");

@onready var heat_sprite : Sprite2D = get_node("Sprite/HeatSprite");
@onready var heat_effect : ShaderMaterial = get_node("Sprite/HeatEffect").material;
@onready var shot_sound_player_container : Node2D = get_node("ShotSoundPlayerContainer");
@onready var heat_particles : CPUParticles2D = get_node("Sprite/HeatParticles");
@onready var shine_particles_container : Node2D = get_node("ShineParticlesContainer");
@onready var coin_particles_container : Node2D = get_node("CoinParticlesContainer");
@onready var shot_line_container : Node2D = get_node("ShotLinesContainer");
@onready var coin_boom_particles_container : Node2D = get_node("CoinsBoomParticlesContainer");

var shot_sound_players : Array[AudioStreamPlayer2D] = [];
var shine_particles : Array[CPUParticles2D] = [];
var coins_particles : Array[CPUParticles2D] = [];
var coins_boom_particles : Array[CPUParticles2D] = [];
var shot_lines : Array[Line2D] = [];
var boom_effect_pool : Array[AttackEffect] = [];

var anus : float = 0.0;

func _init() -> void:
	id = 2;
	mod_name = "vanilla";

func _ready() -> void:
	super._ready();
	is_friendly = is_friendly;
	
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL;
	
	load_attack_effects_pool(load("res://vanilla/scenes/attack_effects/boom_effect.tscn"), 12, boom_effect_pool);
	
	for sound_player in shot_sound_player_container.get_children():
		sound_player.bus = "Sounds";
		sound_player.stream = shot_sound_stream;
		shot_sound_players.append(sound_player);
	for particles in shine_particles_container.get_children(): shine_particles.append(particles as CPUParticles2D);
	for particles in coin_particles_container.get_children(): coins_particles.append(particles as CPUParticles2D);
	for particles in coin_boom_particles_container.get_children(): coins_boom_particles.append(particles as CPUParticles2D);
	for shot_line in shot_line_container.get_children(): shot_lines.append(shot_line);
	
func set_active(is_active_ : bool = true) -> void:
	sprite.visible = is_active_;
	set_process(is_active_);
	set_physics_process(is_active_);
	if is_active_:
		position = Vector2.ZERO;
		rotation = 0.0;
	
func _physics_process(delta: float) -> void:
	heat_particles.scale_amount_min = remap(heat_sprite.modulate.a, 0.0, 1.0, 0.0, 1.5);
	heat_particles.scale_amount_max = remap(heat_sprite.modulate.a, 0.0, 1.0, 0.0, 2.0);
	heat_effect.set_shader_parameter("strength", remap(heat_sprite.modulate.a, 0.0, 1.0, 0.0, 0.06));
	heat_sprite.modulate.a = move_toward(heat_sprite.modulate.a, 0.0, 0.3*delta);
	
	look_at(master.target);
	shot_particles.scale.x = master.sprite_container.scale.x;
	if !master.is_busy:
		if Input.is_action_just_pressed("mouse_left"):
			master.apply_busy(0.1);
			shot();
	sprite.rotation_degrees = 0.0 + anus;
	anus = lerp(anus, 0.0, delta * 12.0);
	
func get_free_shine_particles() -> CPUParticles2D:
	for particles in shine_particles:
		if !particles.emitting: return particles;
	return null;
func get_free_coins_particles() -> CPUParticles2D:
	for particles in coins_particles:
		if !particles.emitting: return particles;
	return null;
func get_free_coins_boom_particles() -> CPUParticles2D:
	for particles in coins_boom_particles:
		if !particles.emitting: return particles;
	return null;
func get_free_player() -> AudioStreamPlayer2D:
	for sound_player in shot_sound_players:
		if !sound_player.playing: return sound_player;
	return null;
func get_free_shot_line() -> Line2D:
	for line in shot_lines:
		if line.width <= 0.01: return line;
	return null;
func get_free_boom_effect() -> AttackEffect:
	for effect in boom_effect_pool:
		if !effect.is_active: return effect;
	return null;

func shot() -> void:
	var free_player : AudioStreamPlayer2D = get_free_player();
	if free_player:
		free_player.pitch_scale = randf_range(0.9, 1.1);
		SoundManager.play_player_with_protection(free_player, shot_sound_stream);
	anus = -70.0;
	
	var _shine_particles : CPUParticles2D = get_free_shine_particles();
	if _shine_particles: _shine_particles.emitting = true;
	var _coin_particles : CPUParticles2D = get_free_coins_particles();
	if _coin_particles: _coin_particles.emitting = true;
	var line : Line2D = get_free_shot_line();
	if line:
		line.position = shot_line_container.global_position;
		line.global_rotation = global_rotation;
		line.shoot();
		
		var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
		var start_position : Vector2 = shot_line_container.global_position;
		var end_position : Vector2 = start_position + global_transform.x * 1000.0;
		
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(start_position, end_position);
		query.collision_mask = 0b1000110 if is_friendly else 0b1101;
		
		query.exclude = [master.get_rid()];
		var result : Dictionary = space_state.intersect_ray(query);
		var end_point : Vector2 = end_position;
		if result:
			var hitted_object : Node2D = result.collider;
			end_point = hitted_object.global_position;
			if hitted_object.has_method("apply_damage"):
				hitted_object.apply_damage(0.1);
				var free_effect : AttackEffect = get_free_boom_effect();
				if free_effect:
					free_effect.global_position = end_point;
					free_effect.is_active = true;
				var free_coins_boom_particles : CPUParticles2D = get_free_coins_boom_particles();
				if free_coins_boom_particles:
					free_coins_boom_particles.global_position = hitted_object.global_position;
					free_coins_boom_particles.emitting = true;
		line.points[1].x = start_position.distance_to(end_point);
		
	shot_particles.restart();
	shot_particles.emitting = true;
	if master is Player: master.camera.shake(2.0, 0.1, 0.0, true, true);
	
	heat_sprite.modulate.a = clamp(heat_sprite.modulate.a + 0.15, 0.0, 1.0);
	
