extends CharacterBody2D;
class_name Entity;

@onready var effect_pool : Node2D = Node2D.new();

var current_item : Item = null;

var sprite_container : Node2D;

var speed : float = 0.0;
var direction : Vector2 = Vector2.ZERO;
var hp : float = 100.0 :
	set(value):
		var old_hp : float = hp;
		hp = value if hp >= 0 else 0.0;
		if hp <= 0.0:
			hp = 0.0;
			die();
		hp_changed.emit(old_hp, value);
var max_hp : float = 100.0 :
	set(value):
		max_hp_changed.emit(max_hp, value);
		max_hp = value if max_hp >= 0 else 0.0;

var is_invincible : bool = false :
	set(value):
		if !value:
			invincibility_timer.stop();
			uninvincibled.emit();
		is_invincible = value;
var is_stunned : bool = false :
	set(value):
		if value: speed = 0.0;
		else:
			stun_timer.stop();
			unstunned.emit();
		is_stunned = value;
var is_busy : bool = false :
	set(value):
		if value: pass;
		else:
			busy_timer.stop();
			unbusied.emit();
		is_busy = value;

var target : Vector2 = Vector2.ZERO;

var invincibility_timer : Timer = Timer.new();
var stun_timer : Timer = Timer.new();
var busy_timer : Timer = Timer.new();

enum states_list{IDLE, MOVING, DEAD}
var state : states_list = states_list.IDLE :
	set(value):
		state = value;
		state_changed.emit(value);
		if state == states_list.DEAD: speed = 0.0;
	get():
		if hp <= 0.0: return states_list.DEAD;
		else:
			if velocity: return states_list.MOVING;
			else: return states_list.IDLE;

var base_hit_color : Color = Color(6.0, 0.0, 0.0, 1.0);
var modified_hit_color : Color = Color(6.0, 0.0, 0.0, 1.0);
var hit_color_modifiers : Array[Color] :
	set(value):
		hit_color_modifiers = value;
		modified_hit_color = base_hit_color;
		for i in hit_color_modifiers.size():
			modified_hit_color *= hit_color_modifiers[i];

var hit_color_tween : Tween;

var shadow : Shadow;

signal invincibled(time : float);
signal stunned(time : float);
signal busied(time : float);
signal uninvincibled;
signal unstunned;
signal unbusied;
signal hp_changed(old_amount, new_amount : float);
signal max_hp_changed(old_amount, new_amount : float);
signal damaged(amount : float);
signal state_changed(value : states_list);
signal effect_applied(effect : Effect);
signal died;

func _ready() -> void:
	y_sort_enabled = true;
	
	stun_timer.one_shot = true;
	busy_timer.one_shot = true;
	invincibility_timer.one_shot = true;
	
	stun_timer.timeout.connect(func(): is_stunned = false);
	busy_timer.timeout.connect(func(): is_busy = false);
	invincibility_timer.timeout.connect(func(): is_invincible = false);
	
	add_child(effect_pool);
	add_child(stun_timer);
	add_child(busy_timer);
	add_child(invincibility_timer);
	
	shadow = Shadow.new();
	add_child(shadow);
	
func _physics_process(_delta: float) -> void:
	if state != states_list.DEAD and !is_stunned:
		velocity = speed * direction;
		move_and_slide();

func apply_damage(amount : float) -> void:
	if is_invincible: return;
	hp -= amount;
	damaged.emit(amount);
	
	if sprite_container:
		sprite_container.modulate = modified_hit_color;
		
		if hit_color_tween: hit_color_tween.kill();
		hit_color_tween = create_tween();
		hit_color_tween.set_ease(Tween.EASE_OUT);
		hit_color_tween.set_trans(Tween.TRANS_CUBIC);
		hit_color_tween.tween_property(sprite_container, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5);

func apply_effect(duration : float, id : int) -> void:
	var effect : Effect = load("res://vanilla/scenes/effects/" + str(id) + ".tscn").instantiate();
	var effects : Array[Node2D] = effect_pool.get_children() as Array[Node2D];
	for i in effects:
		if effect.name == effects[i].name:
			effects[i].stack();
			effect_applied.emit(effects[i]);
			return;
	effect.duration = duration;
	effect.master = self;
	effect.set_up();
	effect_pool.add_child(effect);
	effect_applied.emit(effect);

func die() -> void:
	died.emit();

func apply_stun(time : float = 1.0):
	stun_timer.start(time);
	is_stunned = true;
	stunned.emit(time);
func apply_busy(time : float = 1.0):
	busy_timer.start(time);
	is_busy = true;
	busied.emit(time);
func apply_invincibility(time : float = 1.0):
	invincibility_timer.start(time);
	is_invincible = true;
	invincibled.emit(time);

func pick_up_item() -> void: return;
