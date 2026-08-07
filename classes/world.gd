extends Node2D;
class_name World;

func _init() -> void:
	GameManager.world = self;

func _exit_tree() -> void:
	if GameManager.world == self: GameManager.world = null;
