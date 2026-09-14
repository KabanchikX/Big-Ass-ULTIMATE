extends Line2D;
class_name Trail;

@export_range(3, 100) var dots_amount : int = 3;
@export var point : Marker2D;

func _physics_process(_delta: float) -> void:
	add_point(point.global_position);
	if points.size() > dots_amount:
		remove_point(0);
		
