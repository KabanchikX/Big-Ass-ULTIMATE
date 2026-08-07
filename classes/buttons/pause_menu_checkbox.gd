extends PauseMenuButton;
class_name PauseMenuCheckbox;

@onready var check_mark_sprite : Sprite2D = sprite.get_child(0);
var check_mark_tween : Tween;
var is_checkboxed : bool = false :
	set(value):
		check_mark_sprite.visible = true if value else false;
		is_checkboxed = value;

signal checkboxed;
signal uncheckboxed;

func _ready() -> void:
	super._ready();
	if !is_checkboxed: check_mark_sprite.visible = false;

func use_check_box_tween(_rotation : float = 0.0, _scale : Vector2 = Vector2.ONE) -> void:
	if check_mark_tween: check_mark_tween.kill();
	check_mark_tween = create_tween();
	
	check_mark_tween.set_ease(Tween.EASE_OUT);
	check_mark_tween.set_trans(Tween.TRANS_CUBIC);
	
	check_mark_tween.tween_property(check_mark_sprite, "rotation_degrees", _rotation, 0.25);
	check_mark_tween.parallel().tween_property(check_mark_sprite, "scale", _scale, 0.25);

func on_pressed() -> void:
	super.on_pressed();
	use_check_box_tween(0.0, Vector2(1.2, 1.2));

func on_unpressed() -> void:
	super.on_unpressed();
	is_checkboxed = !is_checkboxed;
	(checkboxed if is_checkboxed else uncheckboxed).emit();
	use_check_box_tween();
