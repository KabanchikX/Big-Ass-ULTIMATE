extends Node;

var world : Node = null :
	set(new_world):
		if world == new_world or !main: return;
		SoundManager.stop_players();
		var old_world : World = world;
		world = new_world;
		if old_world: old_world.queue_free();
		if new_world: main.call_deferred("add_child", new_world);
		world_changed.emit(old_world, new_world);
var hitstop_time : float = 0.0 :
	set(value):
		hitstop_time = value;
		get_tree().paused = true;
		hitstop_timer.start(value);

@onready var hitstop_timer : Timer = Timer.new();
@onready var main : SubViewport = get_tree().root.get_node("SubViewportContainer/SubViewport");

signal world_changed(old_world : World, new_world : World);

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	hitstop_timer.one_shot = true;
	hitstop_timer.timeout.connect(func(): get_tree().paused = false);
	add_child(hitstop_timer);

	world = GlobalData.get_world("main_menu", "vanilla");
	
