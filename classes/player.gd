extends Entity;
class_name Player;

@onready var collision_shape : CollisionShape2D = get_node("CollisionShape");
@onready var parts_container : Node2D = get_node("Parts");
@onready var head : Sprite2D = get_node("Parts/Head");
@onready var face : Sprite2D = get_node("Parts/Face");
@onready var body : Sprite2D = get_node("Parts/Body");
@onready var front_leg : Sprite2D = get_node("Parts/FrontLeg");
@onready var back_leg : Sprite2D = get_node("Parts/BackLeg");

#head
@onready var hat : AnimatedSprite2D = get_node("Parts/Head/Hat");
#face
@onready var face_thing : AnimatedSprite2D = get_node("Parts/Face/FaceThing");
#body
@onready var necklace : AnimatedSprite2D = get_node("Parts/Body/Necklace");
@onready var chest : AnimatedSprite2D = get_node("Parts/Body/Chest");
@onready var tail : AnimatedSprite2D = get_node("Parts/Body/Tail");
#front_leg
@onready var front_pant : AnimatedSprite2D = get_node("Parts/FrontLeg/Pant");
@onready var front_boot : AnimatedSprite2D = get_node("Parts/FrontLeg/Boot");
#back_leg
@onready var back_pant : AnimatedSprite2D = get_node("Parts/BackLeg/Pant");
@onready var back_boot : AnimatedSprite2D = get_node("Parts/BackLeg/Boot");

@onready var camera : PlayerCamera = get_node("Camera");
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer");

@onready var gui_controller : GuiController = get_node("GuiController");

@onready var hit_sound_player : AudioStreamPlayer = AudioStreamPlayer.new();

@onready var pick_up_zone : Area2D = get_node("PickUpZone");

var hit_sound_stream : AudioStream :
	set(value):
		hit_sound_stream = value;
		hit_sound_player.stream = value;

var stick_camera : bool = true;
var mouse_position : Vector2 = Vector2.ZERO;

var item_to_be_picked_up : Item = null :
	set(value):
		if item_to_be_picked_up == value: return;
		item_to_be_picked_up = value;
		item_to_be_picked_up_changed.emit(value);

var current_slot : GuiSlot :
	set(value):
		if current_slot == value : return;
		if current_slot != null:
			if current_slot.is_connected("item_changed", on_current_slot_item_changed):
				current_slot.disconnect("item_changed", on_current_slot_item_changed);
		value.item_changed.connect(on_current_slot_item_changed);
		current_slot = value;
		current_item = current_slot.item;

signal shoted(projectile : Projectile);
signal picked_up(item : Item);
signal dropped(item : Item);
signal item_to_be_picked_up_changed(item : Item);

func on_current_slot_item_changed(old_item : Item, new_item : Item) -> void:
	if old_item != null: old_item.is_active = false;
	if new_item != null: new_item.is_active = true;

func _ready() -> void:
	sprite_container = parts_container;
	hit_sound_player.bus = "Sounds";
	hit_sound_player.max_polyphony = 15;
	add_child(hit_sound_player);
	super._ready();
	shadow.position.y = 23.0;
	speed = 8000.0;
	
	damaged.connect(func(_value): hit_sound_player.pitch_scale = randf_range(0.95, 1.05); hit_sound_player.play(); apply_invincibility(0.2));
	
	invincibled.connect(func(_value): collision_layer = 0b0);
	uninvincibled.connect(func(): if state != states_list.DEAD: collision_layer = 0b1);
	
	change_current_slot(gui_controller.slots[0])
	
	hp_changed.connect(func(old_hp : float, new_hp : float): if old_hp > new_hp: hp = old_hp);
	
func _physics_process(delta: float) -> void:
	on_dropped_item_detected()
	mouse_position = get_global_mouse_position();
	target = mouse_position;
	if stick_camera:
		camera.global_position = lerp(camera.global_position, lerp(position, mouse_position, 0.35), delta * 30.0);
		
	if state != states_list.DEAD and !is_stunned:
		if Input.is_action_just_pressed("e"): pick_up_item();
		if Input.is_action_just_pressed("["): give_item(1, "vanilla", 1);
		if Input.is_action_just_pressed("]"): give_item(0, "vanilla", 1);
		
		animation_player.play("IDLE" if state == states_list.IDLE else "RUN");
		direction = Input.get_vector("left", "right", "up", "down");
		
		velocity = speed * direction * delta;
		
		if !is_busy:
			if Input.is_action_just_pressed("q") and current_slot.item: current_slot.item.drop();
			if mouse_position.x > position.x: parts_container.scale.x = 1.0;
			else: parts_container.scale.x = -1.0;
		
		move_and_slide();

func on_dropped_item_detected() -> void:
	var all_areas : Array[Area2D] = pick_up_zone.get_overlapping_areas();
	if all_areas.size() == 0:
		item_to_be_picked_up = null;
		return;
	if all_areas.size() == 1:
		item_to_be_picked_up = all_areas[0].owner;
		return;
	
	var all_items_around : Array[Item];
	for area in all_areas: all_items_around.append(area.owner);
	
	var nearest_item : Item;
	var closest_distance : float = 0.0;
	var finish_closest_distance : float = 999999999.0;
	for item : Item in all_items_around:
		closest_distance = global_position.distance_squared_to(item.pickup_zone.global_position);
		if closest_distance < finish_closest_distance:
			finish_closest_distance = closest_distance;
			nearest_item = item;
	
	item_to_be_picked_up = nearest_item;

func _input(event: InputEvent) -> void:
	if !event.is_pressed() or event.is_echo(): return;
	
	if !is_busy and !is_stunned and state != states_list.DEAD:
		for i in range(1, 10):
			if event.is_action_pressed(str(i)) and i <= gui_controller.slots.size():
				change_current_slot(gui_controller.slots[i-1]);
				break;

func die() -> void:
	died.emit();
	collision_shape.set_deferred("disabled", true);
	animation_player.play("DEAD" if animation_player.has_animation("DEAD") else "IDLE");

func change_current_slot(slot : GuiSlot) -> void:
	if current_slot != slot:
		current_slot = slot;
		get_tree().call_group("item_slot", "set_self_modulate", Color(1.0, 1.0, 1.0) * gui_controller.current_theme.second_color);
		slot.slot.self_modulate = Color(1.4, 1.4, 1.4) * gui_controller.current_theme.second_color;
		for i in gui_controller.slots.size(): if gui_controller.slots[i].item: gui_controller.slots[i].item.is_active = false;
		if slot.item: slot.item.is_active = true;
	
func give_item(id : int = 1, mod_name : String = "vanilla", amount : int = 1, slot : GuiSlot = gui_controller.get_free_slot()) -> void:
	if !GlobalData.data.has(mod_name): return;
	if !GlobalData.data[mod_name].has("items"): return;
	if !GlobalData.data[mod_name]["items"].has(id): return;
	
	if slot == null: return;
	
	if slot.item == null:
		if amount <= 0: return;
		var technical_name : String = GlobalData.data[mod_name]["items"][id]["technical_name"];
		var new_item : Item = load("res://" + mod_name + "/scenes/items/" + technical_name + ".tscn").instantiate();
		
		new_item.id = id;
		new_item.master = self;
		new_item.mod_name = mod_name;
		
		parts_container.add_child(new_item);
		
		new_item.amount = new_item.max_stack if amount >= new_item.max_stack else amount;
		slot.item = new_item;
		slot.amount = new_item.amount;
		
		if slot.item:
			if slot == current_slot: current_slot.item.is_active = true;
			else: slot.item.is_active = false;
		if slot is MouseSlot: slot.item.is_active = false;
		if slot != current_slot: slot.item.is_active = false;

func pick_up_item() -> void:
	var free_slot : GuiSlot = gui_controller.get_free_slot()
	if item_to_be_picked_up and free_slot:
		item_to_be_picked_up.reparent(sprite_container);
		item_to_be_picked_up.pick_up();
		free_slot.item = item_to_be_picked_up;
		item_to_be_picked_up.is_active = true if free_slot == current_slot else false;
