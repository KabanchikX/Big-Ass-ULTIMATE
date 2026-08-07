extends AttackEffect;

func _ready() -> void:
	super._ready();
	var penis : Node2D = Node2D.new() as AnimatedSprite2D;
	penis = self;
	activated.connect(func():
		penis.stop();
		penis.play("default");
		rotation_degrees = randf_range(0.0, 360.0));
