extends Node2D;
class_name Projectile;

var hitbox : Area2D;
var collision_shape : CollisionShape2D;

@export var base_damage : float = 10.0;
@export var life_time : float = 10.0;
@export var is_block_breaker : bool = false;
@export var is_blockable : bool = true;

var is_blocked : bool = false;

var is_friendly : bool = false;

var life_timer : Timer;

var is_active : bool;

signal deactivated;
signal activated;
signal blocked;
signal hitted_someone(something : Node2D);

func change_active_state(activate : bool = true, _global_position : Vector2 = Vector2.ZERO, _rotation_degrees : float = 0.0) -> void:
	(activated if activate else deactivated).emit();
	is_active = activate;
	visible = activate;
	set_process(activate);
	set_physics_process(activate);
	collision_shape.set_deferred("disabled", !activate);
	global_position = _global_position;
	rotation_degrees = _rotation_degrees;
	
	if activate:
		is_blocked = false;
		life_timer.start(life_time);
		
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsShapeQueryParameters2D.new()
		
		query.shape = collision_shape.shape;
		query.transform = global_transform;
		query.collision_mask = hitbox.collision_mask;
		query.collide_with_areas = true;
		query.collide_with_bodies = false;

		var results := space_state.intersect_shape(query);
		if results.size() > 0:
			for result in results:
				var area = result["collider"] as Area2D;
				if area and area.owner.has_method("handle_projectile"):
					area.owner.handle_projectile(self);
					blocked.emit();
					change_active_state(false);
					hitted_someone.emit(area.owner);
					break;
	else: life_timer.stop();

func _ready() -> void:
	hitbox.collision_layer = 0;
	hitbox.collision_mask = 0;
	hitbox.set_collision_layer_value(6, true);
	hitbox.set_collision_mask_value(2 if is_friendly else 1, true);
	hitbox.set_collision_mask_value(5 if is_friendly else 4, true);
	
	hitbox.set_collision_mask_value(3, true);
	
	if hitbox:
		hitbox.area_entered.connect(on_collided);
		hitbox.body_entered.connect(on_collided);
	
	life_timer = Timer.new();
	life_timer.one_shot = true;
	life_timer.autostart = true;
	life_timer.wait_time = life_time;
	life_timer.timeout.connect(change_active_state.bind(false));
	add_child(life_timer);
	
	change_active_state(false);
	
func _physics_process(delta) -> void:
	global_position += delta * 500.0 * Vector2.RIGHT.rotated(rotation);
	
func on_collided(collider : Node2D) -> void:
	if is_blocked: return;
	if collider.owner.has_method("handle_projectile"):
		is_blocked = true;
		collider.owner.handle_projectile(self);
		change_active_state(false);
		hitted_someone.emit(collider.owner);
		return;
	if collider.has_method("apply_damage"):
		collider.apply_damage(base_damage);
		hitted_someone.emit(collider);
		change_active_state(false);
