extends Item;

@onready var visual_light_node : Sprite2D = get_node("VisualLight");
@onready var actual_light_node : PointLight2D = get_node("ActualLight");
@onready var visual_light : GradientTexture2D = visual_light_node.texture;
@onready var actual_light : GradientTexture2D = actual_light_node.texture;
@onready var particles : CPUParticles2D = get_node("Particles");

func _init():
	id = 1;
	mod_name = "vanilla";

func _ready() -> void:
	super._ready();
	max_stack = 10;
	amount = 1;
	var tween : Tween = create_tween();
	var duration : float = 1.0;
	
	tween.set_trans(Tween.TRANS_CUBIC);
	
	tween.tween_property(visual_light, "width", 56.0, duration);
	tween.parallel().tween_property(visual_light, "height", 56.0, duration);
	tween.parallel().tween_property(actual_light, "width", 112.0, duration);
	tween.parallel().tween_property(actual_light, "height", 112.0, duration);
	
	tween.tween_property(visual_light, "width", 64.0, duration);
	tween.parallel().tween_property(visual_light, "height", 64.0, duration);
	tween.parallel().tween_property(actual_light, "width", 128.0, duration);
	tween.parallel().tween_property(actual_light, "height", 128.0, duration);
	
	tween.set_loops();
