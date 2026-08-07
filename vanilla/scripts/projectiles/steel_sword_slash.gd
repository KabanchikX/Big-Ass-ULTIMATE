extends Projectile;

@onready var sprite : AnimatedSprite2D = get_node("Sprite");

func _ready() -> void:
	collision_shape = get_node("CollisionShape");
	hitbox = collision_shape.owner;
	activated.connect(func():
		sprite.play("default"));
	super._ready();
	
func _physics_process(_delta) -> void:
	return;

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
		
