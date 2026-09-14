extends LineEdit;
class_name CommandLine;

var errored : bool = false :
	set(value):
		errored = value;
		placeholder_text = "Error" if value else "Type command";

func _ready() -> void:
	text_submitted.connect(execute_command);
	Settings.master_volume = 1.0;
	text_changed.connect(func(_new_text : String):
		if errored: errored = false);
	
func execute_command(new_text : String) -> void:
	if text.is_empty(): return;
	
	text = "";
	
	var command_parts : Array = new_text.split(" ", false);
	if command_parts.is_empty():
		return_error();
		return;
	
	var mod_name_and_command : Array = command_parts[0].split(":", false);
	if mod_name_and_command.size() < 2:
		return_error();
		return;
	
	var mod_name : String = mod_name_and_command[0];
	var command_name : String = mod_name_and_command[1];
	
	var arguments : Array = [];
	
	if !GlobalData.commands_containers.has(mod_name) or !GlobalData.commands_containers[mod_name].has_method(command_name):
		return_error();
		return;
	
	for i in range(1, command_parts.size()):
		if command_parts[i].is_valid_int(): command_parts[i] = int(command_parts[i]);
		arguments.append(command_parts[i]);
	
	arguments.push_front(owner);
	
	var command_container : CommandContainer = GlobalData.commands_containers[mod_name];
	var command : Callable = Callable(command_container, command_name);
	
	if command.is_valid(): command.callv(arguments);
	else: return_error();
	
func return_error() -> void:
	errored = true;
