extends Node2D;
class_name ItemChooser;

@export var icon : Sprite2D;
@export var icon_shadow : Sprite2D;

var target_slot : GuiSlot = null :
	set(slot):
		if slot == target_slot: return;
		var old_slot : GuiSlot = target_slot;
		
		if target_slot != null and target_slot.item_changed.is_connected(on_slot_item_changed):
			target_slot.item_changed.disconnect(on_slot_item_changed);
		if slot:
			slot.item_changed.connect(on_slot_item_changed);
		
		target_slot = slot;
		on_target_slot_changed();
		target_slot_changed.emit(old_slot, slot);

signal target_slot_changed(old_slot, new_slot);

var position_tween : Tween;
var alpha_tween : Tween;

func _ready() -> void:
	modulate.a = 0.0;

func _physics_process(delta: float) -> void:
	icon.rotation += delta;
	icon_shadow.rotation += delta;

func fade(fade_in : bool = true) -> void:
	if alpha_tween: alpha_tween.kill();
	alpha_tween = create_tween();
	alpha_tween.set_trans(Tween.TRANS_CUBIC);
	alpha_tween.set_ease(Tween.EASE_OUT);
	alpha_tween.tween_property(self, "modulate:a", 1.0 if fade_in else 0.0, 0.2 if fade_in else 1.0);

func on_target_slot_changed() -> void:
	if target_slot:
		if position_tween: position_tween.kill();
		position_tween = create_tween();
		position_tween.set_trans(Tween.TRANS_CUBIC);
		position_tween.set_ease(Tween.EASE_OUT);
		position_tween.tween_property(self, "global_position", target_slot.global_position+Vector2(20.0, 20.0), 0.4);
		fade(true);
	else:
		fade(false);

func on_slot_item_changed(_item : Item, old_item : Item) -> void:
	fade(is_instance_valid(old_item));
