extends Node2D;
class_name DialogueCharacter;

var body_animation_player : AnimationPlayer;
var mouth_animation_player : AnimationPlayer;
var parts : Array[Node2D] = [];
var animations_list : Array[String] = [];
var current_animation : String = "RESET";

func _ready() -> void:
	if !body_animation_player or !mouth_animation_player: return;
	animations_list = body_animation_player.get_animation_library_list() as Array[String];

func play_animation() -> void:
	if !body_animation_player or !mouth_animation_player: return;
	
