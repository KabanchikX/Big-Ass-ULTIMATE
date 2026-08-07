extends LineEdit;
class_name CommandLine;

func _ready() -> void:
	text_submitted.connect(execute_command);

func execute_command(new_text : String) -> void:
	if text.is_empty(): return;
	
	text = "";
	
	var command_parts : Array = new_text.split(" ", false);
	if command_parts.is_empty(): return;
	
	var arguments : Array = [];
	
	for i in range(1, command_parts.size()):
		if command_parts[i].is_valid_int(): command_parts[i] = int(command_parts[i]);
		arguments.append(command_parts[i]);
		
	var command : Callable = Callable(owner, command_parts[0]);
	
	if command.is_valid(): command.callv(arguments);
	else: text = "Error";
	
