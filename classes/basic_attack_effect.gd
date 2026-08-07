extends Node2D;
class_name AttackEffect;

@export var life_time : float = 1.0;
var sprite_container : Node2D;
var life_timer : Timer;

var is_active : bool = false : 
	set(value):
		if is_active == value: return;
		is_active = value;
		(activated if is_active else deactivated).emit();

signal activated;
signal deactivated;

func _ready() -> void:
	top_level = true;
	activated.connect(set_active_state.bind(true));
	deactivated.connect(set_active_state.bind(false));
	is_active = false;
	
	life_timer = Timer.new();
	life_timer.one_shot = true;
	life_timer.timeout.connect(set.bind("is_active", false));
	add_child(life_timer);
	
func set_active_state(activate : bool = true) -> void:
	set_physics_process(activate);
	set_process(activate);
	visible = activate;
	if activate: life_timer.start(life_time);
