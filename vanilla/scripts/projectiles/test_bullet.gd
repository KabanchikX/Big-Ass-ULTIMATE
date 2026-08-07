extends Projectile;

func _ready() -> void:
	collision_shape = get_node("CollisionShape2D");
	hitbox = collision_shape.owner;
	super._ready();
	
