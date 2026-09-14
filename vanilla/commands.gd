extends CommandContainer;

func give_item(sender : Entity, id : int = 1, mod_name : String = "vanilla", amount : int = 1, slot : GuiSlot = null) -> Error:
	if !GlobalData.data.has(mod_name): return FAILED;
	if !GlobalData.data[mod_name].has("items"): return FAILED;
	if !GlobalData.data[mod_name]["items"].has(id): return FAILED;
	
	var technical_name : String = GlobalData.data[mod_name]["items"][id]["technical_name"];
	var new_item : Item;
	
	if amount <= 0 or !sender.sprite_container or !GameManager.world: return FAILED;
	
	new_item = load("res://" + mod_name + "/scenes/items/" + technical_name + ".tscn").instantiate();
	if !new_item: return FAILED;
	new_item._init();
	new_item.master = sender;
	new_item.amount = amount;
	GameManager.world.add_child(new_item);
	
	if sender is Player:
		slot = sender.gui_controller.get_free_slot();
		if slot == null: return FAILED;
		
		new_item.pick_up(sender);
		slot.item = new_item;
		
		var current_slot : GuiSlot = sender.current_slot;
	
		if slot == current_slot: new_item.is_active = true;
		return OK;
	
	if !sender.current_item:
		sender.current_item = new_item;
		new_item.pick_up(sender);
		return OK
	sender.current_item.drop();
	sender.current_item = new_item;
	new_item.pick_up(sender);
	return OK
