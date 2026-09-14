extends Projectile;

@export var speed : float = 1000.0;
var current_speed : float = 0.0;

@onready var sprite : Sprite2D = get_node("Sprite");

var tween : Tween;
var speed_tween : Tween;
var rotater : float = 0.0;

@onready var timer : Timer = Timer.new();

func _ready() -> void:
	timer.timeout.connect(func():
		timer.start(randf_range(0.08, 0.11))
		for body in hitbox.get_overlapping_bodies():
			on_collided(body);
		);
	add_child(timer);
	
	timer.start(1.0);
	
	collision_shape = get_node("CollisionShape");
	hitbox = collision_shape.owner;
	
	activated.connect(func():
		rotater = 2.0;
		current_speed = speed;
		sprite.rotation = 0.0;
		$CPUParticles2D.restart();
		$CPUParticles2D.lifetime = life_time;
		$CPUParticles2D.emitting = true;
		modulate.a = 100.0;
		var old_scale_x : float = scale.x;
		scale.x *= 1.4;
		if tween: tween.kill();
		tween = create_tween();
		tween.set_ease(Tween.EASE_OUT);
		tween.set_trans(Tween.TRANS_CUBIC);
		tween.tween_property(self, "modulate:a", 0.0, life_time);
		tween.parallel().tween_property(self, "current_speed", 0.0, life_time*1.3);
		tween.parallel().tween_property(self, "scale:x", old_scale_x, life_time);
		tween.parallel().tween_property(self, "rotater", 0.0, life_time*0.8);
		);
		
	super._ready();
	
func on_collided(collider : Node2D) -> void:
	if is_blocked: return;
	if collider.has_method("apply_damage"):
		collider.apply_damage(base_damage);
		hitted_someone.emit(collider);
	
func _physics_process(delta) -> void:
	#var progress : float = 1.0 - (life_timer.time_left/life_time);
	#current_speed = lerp(speed*0.9, 0.0, progress);
	global_position += delta * current_speed * Vector2.RIGHT.rotated(rotation);
	sprite.rotation += rotater;
	
