extends Node2D;
class_name TestTurret;

@export var initial_projectile_scene : PackedScene;
@export_range(0.0, 1000.0, 1.0) var initial_projectiles_pool_size : int;
@export var is_friendly : bool = false;
@export var is_enabled : bool = true;

@onready var shoot_sound_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
@onready var shooting_point : Marker2D = get_node("TurretGun/ShootingPoint");
@onready var gun_sprite : Sprite2D = get_node("TurretGun");
@onready var particles : CPUParticles2D = gun_sprite.get_child(0);
@onready var shoot_cooldown_timer : Timer = Timer.new();
@onready var too_fast_shoot_sound_timer : Timer = Timer.new();
@export var shoot_cooldown_in_sec : float = 1.0:
	set(value):
		if shoot_cooldown_timer: shoot_cooldown_timer.start(value);
		shoot_cooldown_in_sec = value;

var tween : Tween;
var target : Vector2 = Vector2.ZERO :
	set(value):
		gun_sprite.look_at(value);
		target = value;

var projectile_pool : Array[Projectile];

var shadow : Shadow;

func _ready() -> void:
	shadow = Shadow.new();
	add_child(shadow);
	
	y_sort_enabled = true;
	
	shadow.position.y = 12.0;
	
	shoot_sound_player.max_polyphony = 15;
	shoot_sound_player.bus = "Sounds";
	shoot_sound_player.stream = load("res://vanilla/sfx/test_room/test_turret_shooted.mp3");
	add_child(shoot_sound_player);
	
	shoot_cooldown_timer.timeout.connect(shoot);
	too_fast_shoot_sound_timer.timeout.connect(func(): if is_enabled and shoot_cooldown_in_sec <= 0.05: shoot_sound_player.pitch_scale = randf_range(0.9, 1.1); shoot_sound_player.play(); too_fast_shoot_sound_timer.start(0.05));
	shoot_cooldown_timer.one_shot = true;
	too_fast_shoot_sound_timer.wait_time = 0.1;
	too_fast_shoot_sound_timer.one_shot = true;
	shoot_cooldown_timer.wait_time = shoot_cooldown_in_sec;
	shoot_cooldown_timer.autostart = true;
	too_fast_shoot_sound_timer.autostart = true;
	add_child(too_fast_shoot_sound_timer);
	add_child(shoot_cooldown_timer);
	
	load_projectile_pool(initial_projectile_scene, initial_projectiles_pool_size, is_friendly);
	
func _physics_process(_delta: float) -> void:
	gun_sprite.scale.y = 1.0 if global_position.x < target.x else -1.0;
	particles.scale.x = gun_sprite.scale.y;
	gun_sprite.look_at(target);
	target = get_parent().get_child(0).global_position;
	
func load_projectile_pool(projectile_scene : PackedScene, pool_size : int = 0, friendly : bool = false) -> void:
	if pool_size <= 0: return;
	if projectile_pool.size() > 0:
		for i in projectile_pool.size():
			if projectile_pool[i]: projectile_pool[i].queue_free();
		projectile_pool.clear();
		
	var new_projectile : Projectile;
	for i in pool_size:
		new_projectile = projectile_scene.instantiate();
		new_projectile.is_friendly = friendly;
		projectile_pool.append(new_projectile);
		add_child(new_projectile);
		
func find_free_projectile_index() -> int:
	for i in projectile_pool.size():
		if projectile_pool[i].collision_shape.disabled and !projectile_pool[i].is_active: return i;
	return -1;
	
func shoot() -> void:
	if !is_enabled: return;
	
	shoot_cooldown_timer.start(shoot_cooldown_in_sec);
	
	gun_sprite.offset.x = 20.0;
	particles.restart();
	particles.emitting = true;
	
	if tween: tween.kill();
	tween = create_tween();
	
	tween.set_ease(Tween.EASE_OUT);
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(gun_sprite, "offset:x", 23.0, 1.0);
	
	#var projectile_index : int = projectile_pool.find_custom(func(projectile): return !projectile.is_processing);
	
	if shoot_cooldown_in_sec > 0.05: shoot_sound_player.play();
	
	var free_projectile_index : int = find_free_projectile_index();
	if free_projectile_index != -1:
		var free_projectile : Projectile = projectile_pool[free_projectile_index];
		free_projectile.change_active_state(true, shooting_point.global_position, gun_sprite.rotation_degrees + randf_range(-10.0, 10.0));
	free_projectile_index = find_free_projectile_index();
	if free_projectile_index != -1:
		var free_projectile : Projectile = projectile_pool[free_projectile_index];
		free_projectile.change_active_state(true, shooting_point.global_position, gun_sprite.rotation_degrees + randf_range(-10.0, 10.0));
