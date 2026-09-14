extends Weapon;


@onready var sheathed_texture : Texture2D = load("res://vanilla/sprites/items/kokushibo_sword/sword_sheathed.png");
@onready var first_form_texture : Texture2D = load("res://vanilla/sprites/items/kokushibo_sword/sword_phase1.png");
@onready var second_form_texture : Texture2D = load("res://vanilla/sprites/items/kokushibo_sword/sword_phase2.png");

@onready var slash_sound_player : AudioStreamPlayer2D = get_node("SlashSoundPlayer")

@onready var sprite : Sprite2D = get_node("Sprite");
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer");

@onready var slash_particles_phase1 : CPUParticles2D = get_node("SlashParticlesPhase1");
@onready var slash_particles_phase2 : CPUParticles2D = get_node("SlashParticlesPhase2");

var phase1_slash_scene : PackedScene = preload("res://vanilla/scenes/projectiles/kokushibo_slash_phase1.tscn");
var phase2_slash_scene : PackedScene = preload("res://vanilla/scenes/projectiles/kokushibo_slash_phase2.tscn");
var basic_slash_phase1 : PackedScene = preload("res://vanilla/scenes/projectiles/basic_kokushibo_slash_phase1.tscn");
var basic_slash_phase2 : PackedScene = preload("res://vanilla/scenes/projectiles/basic_kokushibo_slash_phase2.tscn");
var alternate_slash_phase1 : PackedScene = preload("res://vanilla/scenes/projectiles/alternate_kokushibo_slash_phase1.tscn");
var alternate_slash_phase2 : PackedScene = preload("res://vanilla/scenes/projectiles/alternate_kokushibo_slash_phase2.tscn");
var saw_scene : PackedScene = preload("res://vanilla/scenes/projectiles/kokushibo_saw.tscn");
var ground_attack_scene : PackedScene = preload("res://vanilla/scenes/projectiles/kokushibo_ground_attack.tscn")

@onready var abilities_container : Node2D = get_node("AbilitiesContainer");

var abilities : Array[Sprite2D] = [];

var points_array : PackedVector2Array = [];
var max_points : int = 30;

var active_texture : Texture2D;

var phase1_slashes_pool : Array[Projectile] = [];
var phase2_slashes_pool : Array[Projectile] = [];

var basic_slashes_phase1_pool : Array[Projectile] = [];
var basic_slashes_phase2_pool : Array[Projectile] = [];

var alternate_slashes_phase1_pool : Array[Projectile] = [];
var alternate_slashes_phase2_pool : Array[Projectile] = [];

var saws_pool : Array[Projectile] = [];
var ground_attack_pool : Array[Projectile] = [];

var phase : int = 1;

var combo : bool = false;

var rage : float = 0.0 :
	set(value):
		rage = value;
		active_texture = second_form_texture if rage >= 100.0 else first_form_texture;
		phase = 2 if rage >= 100.0 else 1;

func _init() -> void:
	id = 3;
	mod_name = "vanilla";

func _ready() -> void:
	super._ready();
	tree_exiting.connect(func(): set_abilities_icon(self));
	
	abilities.assign(abilities_container.get_children());
	
	rage = rage;
	sprite.texture = sheathed_texture;
	animation_player.animation_finished.connect(on_animation_finished);
	activated.connect(func():
		sprite.texture = active_texture;
		if master.is_in_group("Player") and "gui_controller" in master:
			set_abilities_icon(master.gui_controller);
			abilities_container.visible = true;
		);
	deactivated.connect(func():
		sprite.texture = sheathed_texture;
		abilities_container.visible = false;
		);
	sprite.visible = false;
	load_projectiles_pool(basic_slash_phase1, 15, basic_slashes_phase1_pool);
	load_projectiles_pool(basic_slash_phase2, 50, basic_slashes_phase2_pool);
	load_projectiles_pool(alternate_slash_phase1, 15, alternate_slashes_phase1_pool);
	load_projectiles_pool(alternate_slash_phase2, 50, alternate_slashes_phase2_pool);
	load_projectiles_pool(phase1_slash_scene, 15, phase1_slashes_pool);
	load_projectiles_pool(phase2_slash_scene, 50, phase2_slashes_pool);
	load_projectiles_pool(saw_scene, 20, saws_pool);
	load_projectiles_pool(ground_attack_scene, 15, ground_attack_pool);
	
enum keys{z,x,c,v};
func _physics_process(_delta: float) -> void:
	if !master.is_in_group("Player") or master.is_stunned or master.state == master.states_list.DEAD or master.is_busy: return
	if Input.is_action_just_pressed("mouse_left"): slash();
	if Input.is_action_just_pressed("0"): rage = 0.0 if rage >= 100.0 else 100.0;
	
	for i in keys: if Input.is_action_just_pressed(i):
		if !abilities[keys[i]].is_ready or phase == 1 and keys[i] == 3: return;
		call("ability_"+str(keys[i]+1));
		abilities[keys[i]].use();
	
func drop() -> void:
	set_abilities_icon(self);
	super.drop();
	abilities_container.visible = false;
func pick_up(new_master : Entity = null) -> void:
	super.pick_up(new_master);
	if new_master.is_in_group("Player") and "gui_controller" in new_master and new_master.current_slot.item == self:
		set_abilities_icon(new_master.gui_controller);
		abilities_container.visible = true;

func slash() -> void:
	var pool : Array[Projectile] = get("phase"+str(phase)+"_slashes_pool");
	var projectile_id : int = get_free_projectile_id(pool);
	
	if projectile_id != -1:
		look_at(master.target)
		master.camera.shake(2.5 if phase == 1 else 5.5, 0.2, 0.0, true, false);
		var free_projectile : Projectile = pool[projectile_id];
		free_projectile.change_active_state(true, master.global_position);
		animation_player.play("slash");
		master.apply_busy(0.4);
		var particles : CPUParticles2D = get("slash_particles_phase"+str(phase));
		particles.restart();
		particles.emitting = true;
		sprite.visible = true;
		slash_sound_player.volume_linear = 2.0 if phase == 2 else 1.0;
		slash_sound_player.pitch_scale = randf_range(0.8, 1.2);
		SoundManager.play_player_with_protection(slash_sound_player, slash_sound_player.stream, 0.2);
		sprite.texture = active_texture;
		scale.y = 1.0 - 2.0 * float(combo);
		combo = not combo;
		
func set_abilities_icon(boss_molokosos : Node = self) -> void:
	abilities_container.reparent(boss_molokosos, false);

func on_animation_finished(animation_name) -> void:
	if animation_name == "slash":
		animation_player.play("idle");
		#rotation = 0.0;
		sprite.visible = false;
		if phase == 1: sprite.texture = sheathed_texture;
func shoot_classic_slash(_rotation : float = 0.0, speed : float = 1000.0, life_time : float = 1.0) -> void:
	var pool : Array[Projectile] = get("basic_slashes_phase"+str(phase)+"_pool");
	var free_id = get_free_projectile_id(pool);
	if free_id <= -1: return;
	
	var free_slash : Projectile = pool[free_id];
	free_slash.life_time = life_time;
	free_slash.speed = speed;
	free_slash.change_active_state(true, global_position, _rotation);
	master.camera.shake(5.5, 0.2, 0.0, true, false);

func shoot_ground_attack(_rotation : float = 0.0, speed : float = 1000.0, life_time : float = 1.0) -> void:
	var pool : Array[Projectile] = ground_attack_pool;
	var free_id = get_free_projectile_id(pool);
	if free_id <= -1: return;
	
	var free_slash : Projectile = pool[free_id];
	free_slash.life_time = life_time;
	free_slash.speed = speed;
	free_slash.change_active_state(true, global_position, _rotation);
	free_slash.scale.y = -1.0 if master.global_position.x >= master.target.x else 1.0;
	master.camera.shake(5.5, 0.2, 0.0, true, false);
	
func shoot_alternate_slash(_rotation : float = 0.0, speed : float = 1000.0, life_time : float = 1.0, position_offset : Vector2 = Vector2.ZERO) -> void:
	var pool : Array[Projectile] = get("alternate_slashes_phase"+str(phase)+"_pool");
	var free_id = get_free_projectile_id(pool);
	if free_id <= -1: return;
	
	var free_slash : Projectile = pool[free_id];
	free_slash.life_time = life_time;
	free_slash.speed = speed;
	free_slash.scale = Vector2.ONE * randf_range(0.6, 1.4);
	free_slash.change_active_state(true, global_position + position_offset, _rotation);
	master.camera.shake(5.5, 0.2, 0.0, true, false);

func shoot_saw(_rotation : float = 0.0, speed : float = 1000.0, life_time : float = 1.0, position_offset : Vector2 = Vector2.ZERO) -> void:
	var pool : Array[Projectile] = saws_pool;
	var free_id = get_free_projectile_id(pool);
	if free_id <= -1: return;
	
	slash_sound_player.pitch_scale = randf_range(0.8, 1.2);
	SoundManager.play_player_with_protection(slash_sound_player, slash_sound_player.stream);
	var free_slash : Projectile = pool[free_id];
	free_slash.life_time = life_time;
	free_slash.speed = speed;
	free_slash.change_active_state(true, global_position + position_offset, _rotation);
	master.camera.shake(5.5, 0.2, 0.0, true, false);

func ability_1() -> void:
	if !abilities[0].is_ready: return;
	master.apply_busy(1.0);
	
	var tree : SceneTree = get_tree();
	
	var shot : Callable = func():
		var direction : Vector2 = master.target - master.global_position;
		var rotation_ : float = rad_to_deg(atan2(direction.y, direction.x)) + randf_range(-5.0, 5.0)*phase*phase;
		var speed : float = 1000.0 * phase + randf_range(-200.0, 300.0);
		var life_time : float = 1.0 + randf_range(0.0, 0.6);
		shoot_classic_slash(rotation_, speed, life_time);
		slash();
	
	for i in 6*phase*phase:
		var timer : SceneTreeTimer = tree.create_timer(i*0.2/phase/phase);
		timer.timeout.connect(shot);
	
func ability_2() -> void:
	if !abilities[1].is_ready: return;
	
	master.apply_busy(1.0);
	
	var tree : SceneTree = get_tree();
	
	var shot : Callable = func():
		var rotation_ : float = randf_range(0.0, 360.0);
		var speed : float = 50.0 * randf_range(0.8, 1.3) * phase;
		var life_time : float = 1.0 + randf_range(0.0, 0.6);
		var position_offset : Vector2 = Vector2.ONE * (randf_range(-100.0, 100.0) * phase);
		shoot_alternate_slash(rotation_, speed, life_time, position_offset);
		master.target = master.global_position + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0));
		slash();
		
	for i in 12 * phase:
		var timer : SceneTreeTimer = tree.create_timer(i*0.1/phase);
		timer.timeout.connect(shot);

func ability_3() -> void:
	if !abilities[2].is_ready: return;
	var tree : SceneTree = get_tree();
	master.apply_busy(1.0);
	
	if phase == 1:
		var _shot : Callable = func(cycle : bool = false):
			var direction : Vector2 = master.target - master.global_position;
			var rotation_ : float = rad_to_deg(atan2(direction.y, direction.x)) + randf_range(-10.0, 10.0)*phase*phase;
			var speed : float = 1000.0 + randf_range(-200.0, 300.0) * pow(phase, 2);
			var life_time : float = 1.0 + randf_range(0.0, 0.6);
			master.target *= -1.0 if cycle else 1.0;
			shoot_classic_slash(fposmod(rotation_ + 180.0 * float(cycle), 360.0), speed, life_time);
			combo = 1;
			slash();
		for i in 18:
			tree.create_timer(i*0.05).timeout.connect(_shot.bind(false if i%2 == 0 else true));
		return;
	
	var shot : Callable = func():
		var direction : Vector2 = master.target - master.global_position;
		var rotation_ : float = rad_to_deg(atan2(direction.y, direction.x)) + randf_range(-15.0, 15.0);
		var speed : float = 3500.0 * randf_range(0.2, 1.0);
		shoot_saw(rotation_, speed, 1.0);
		slash();
	for i in 12:
		tree.create_timer(i*0.05).timeout.connect(shot);
	
func ability_4() -> void:
	if !abilities[3].is_ready: return;
	if phase != 2: return;
	
	master.apply_busy(1.0);

	var shot : Callable = func():
		var direction : Vector2 = master.target - master.global_position;
		var rotation_ : float = rad_to_deg(atan2(direction.y, direction.x));
		for i in 9:
			shoot_ground_attack(rotation_ - 10 * i + 40, 1000.0, 1.0);
	shot.call();
	slash();
