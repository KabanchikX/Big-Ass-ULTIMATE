extends Item;
class_name Weapon;

var icon : Sprite2D;

var is_friendly : bool = true :
	set(value):
		if value == is_friendly: return;
		var old_value : bool = is_friendly;
		is_friendly = value;
		is_friendly_changed.emit(old_value, value);

signal is_friendly_changed(old_value : bool, new_value : bool);

func load_projectiles_pool(projectile_scene : PackedScene, pool_size : int = 0, pool : Array[Projectile] = []) -> void:
	pool.clear();
	
	if pool_size <= 0: return;
	var new_projectile : Projectile;
	
	for i in pool_size:
		new_projectile = projectile_scene.instantiate();
		new_projectile.hitted_someone.connect(on_hitted);
		new_projectile.visible = false;
		new_projectile.set_process(false);
		new_projectile.set_physics_process(false);
		new_projectile.is_friendly = is_friendly
		pool.append(new_projectile);
		add_child(new_projectile);
func load_attack_effects_pool(effect_scene : PackedScene, pool_size : int = 0, pool : Array[AttackEffect] = []) -> void:
	pool.clear();
	
	if pool_size <= 0: return;
	var new_effect : AttackEffect;
	
	for i in pool_size:
		new_effect = effect_scene.instantiate();
		new_effect.visible = false;
		new_effect.set_process(false);
		new_effect.set_physics_process(false);
		pool.append(new_effect);
		add_child(new_effect);

func get_free_projectile_id(pool : Array[Projectile]) -> int:
	for i in pool.size():
		if pool[i].collision_shape.disabled: return i;
	return -1;
func get_free_attack_effect_id(pool : Array[AttackEffect]) -> int:
	for i in pool.size():
		if !pool[i].visible: return i;
	return -1;
	
func _ready() -> void:
	super._ready();

func on_hitted(_body : Node2D) -> void:
	return;
