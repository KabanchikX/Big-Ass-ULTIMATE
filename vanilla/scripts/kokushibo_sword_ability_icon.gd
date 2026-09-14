extends Sprite2D;

@onready var cooldown_texture : TextureRect = get_node("CooldownRect");
@onready var icon : Sprite2D = get_node("Icon");
@onready var current_timer : Timer = Timer.new();

@export var cooldown : float = 0.0;

var scale_tween : Tween;
var color_tween : Tween;

var is_ready : bool = true;

func _ready() -> void:
	current_timer.one_shot = true;
	add_child(current_timer);
	
	cooldown_texture.visible = false;
	
	current_timer.timeout.connect(func():
		is_ready = true;
		modulate = Color(3.0, 3.0, 3.0);
		
		if color_tween: color_tween.kill();
		color_tween = create_tween();
		color_tween.set_ease(Tween.EASE_OUT);
		color_tween.set_trans(Tween.TRANS_CUBIC);
		color_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.5);
		cooldown_texture.visible = false;
		);

func _physics_process(_delta: float) -> void:
	if !current_timer: return;
	cooldown_texture.size.y = remap(current_timer.time_left, 0.0, cooldown, 0.0, 41.0);
	
func use() -> void:
	if !current_timer or !is_ready: return;
	current_timer.start(cooldown);
	is_ready = false;
	scale = Vector2(1.4, 1.4);
	cooldown_texture.visible = true;
	if scale_tween: scale_tween.kill();
	scale_tween = create_tween();
	scale_tween.set_ease(Tween.EASE_OUT);
	scale_tween.set_trans(Tween.TRANS_CUBIC);
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.4);
