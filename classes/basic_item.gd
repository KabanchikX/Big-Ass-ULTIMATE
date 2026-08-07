extends Node2D;
class_name Item;

var meta_data : Dictionary = {};

var id : int = -1;
var mod_name : String = "vanilla";
var master : Node2D;

@export var max_stack : int = 99;
var amount : int = 1 :
	set(value):
		amount = value;
		amount_changed.emit(amount);
		
@export var pickup_zone : Area2D;
@export var shadow : Shadow;

var is_active : bool = true:
	set(value):
		if value == is_active: return;
		if value == true: activated.emit();
		else: deactivated.emit();
		is_active = value;
		
signal amount_changed(value);
signal activated;
signal deactivated;
signal dropped;
signal picked_up;

func _ready() -> void:
	y_sort_enabled = true if master else false;
	pickup_zone.collision_layer = 0 if master else 0b1000000;
	pickup_zone.collision_mask = 0;
	pickup_zone.monitoring = false;
	shadow.visible = false;
	activated.connect(set_active.bind(true));
	deactivated.connect(set_active.bind(false));

func set_active(is_active_ : bool = true) -> void:
	visible = is_active_;
	set_process(is_active_);
	set_physics_process(is_active_);
	if is_active_:
		position = Vector2.ZERO;
		rotation = 0.0;
	
func pick_up() -> void:
	y_sort_enabled = false;
	shadow.visible = false;
	pickup_zone.collision_layer = 0;
	picked_up.emit();
	position = Vector2.ZERO;
	scale = Vector2.ONE;
	rotation = 0.0;
	if !master: return;
	set_active(master.current_item == self);
	
func drop() -> void:
	y_sort_enabled = true;
	shadow.visible = true;
	pickup_zone.collision_layer = 0b1000000;
	is_active = false;
	visible = true;
	reparent(GameManager.world, true);
	dropped.emit();
	rotation = 0.0;
	scale = Vector2.ONE;
	
