extends GuiSlot;
class_name MouseSlot;

var mouse_pos : Vector2 = Vector2.ZERO;
var old_pos : Vector2 = Vector2.ZERO;
var rotation_target : float = 15.0;

func _physics_process(delta: float) -> void:
	mouse_pos = get_global_mouse_position();
	old_pos = position;
	position = lerp(position, mouse_pos - Vector2(20.0, 20.0), 10.0*delta);
	rotation_degrees = lerp(rotation_degrees, rotation_target, 10.0*delta);
	scale = lerp(scale, Vector2(1.2, 1.2), 4.0*delta)
	
	rotation_degrees = remap(old_pos.x-position.x, 0.0, 40.0, -15.0, 60.0);

func _ready() -> void:
	super._ready();
	is_enabled = false;
	item_changed.connect(func(_value, __value): rotation_degrees = 0.0; scale = Vector2.ONE);

func on_hovered_state_changed(_is_hovered_ : bool = true) -> void:
	return;
