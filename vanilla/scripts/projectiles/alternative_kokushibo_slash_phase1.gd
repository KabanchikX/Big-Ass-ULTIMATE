extends Projectile;

@export var speed : float = 1000.0;
var current_speed : float = 0.0;

@onready var sprite : Sprite2D = get_node("Sprite");

var tween : Tween;
var color_tween : Tween;

func _ready() -> void:
	collision_shape = get_node("CollisionShape");
	hitbox = collision_shape.owner;
	
	super._ready();
	
	activated.connect(func():
		var glow : Sprite2D = sprite.get_child(0);
		modulate.a = 2.0;
		sprite.scale.x = 1.4;
		sprite.self_modulate = Color.WHITE * 2.0;
		glow.modulate.a = 2.0;
		current_speed = speed;
		$CPUParticles2D.restart();
		$CPUParticles2D.lifetime = life_time;
		$CPUParticles2D.emitting = true;
		if tween: tween.kill();
		if color_tween: color_tween.kill();
		color_tween = create_tween();
		tween = create_tween();
		tween.set_ease(Tween.EASE_OUT);
		tween.set_trans(Tween.TRANS_CUBIC);
		color_tween.set_trans(Tween.TRANS_QUINT);
		
		color_tween.tween_property(self, "modulate:a", 0.0, life_time);
		tween.parallel().tween_property(sprite, "scale:x", 0.0, life_time*0.8	);
		tween.parallel().tween_property(self, "current_speed", 0.0, life_time);
		tween.parallel().tween_property(sprite, "self_modulate", Color.WHITE, life_time*0.5);
		tween.parallel().tween_property(glow, "modulate:a", 0.0, life_time*0.8);
		);
	
func on_collided(collider : Node2D) -> void:
	if is_blocked: return;
	if collider.owner.has_method("handle_projectile"):
		is_blocked = true;
		collider.owner.handle_projectile(self);
		change_active_state(false);
		return;
	if collider.has_method("apply_damage"):
		collider.apply_damage(base_damage);
		hitted_someone.emit(collider);
	
func _physics_process(delta) -> void:
	global_position += delta * current_speed * Vector2.RIGHT.rotated(rotation);
