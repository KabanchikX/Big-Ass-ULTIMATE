extends Camera2D;
class_name PlayerCamera;

var stop_shake_timer : Timer = Timer.new();
var fade_shake_timer : Timer = Timer.new();

var fade_tween : Tween;

var shake_fade_delay : float = 0.0;
var shake_amplitude : float = 0.0;
var shake_rotation : bool = false;
var shake_offset : bool = false;

var zoom_value : float = 1.0 :
	set(value) : zoom_value = clampf(value, 0.1, 10.0);

func _ready() -> void:
	stop_shake_timer.one_shot = true;
	fade_shake_timer.one_shot = true;
	add_child(stop_shake_timer);
	add_child(fade_shake_timer);
	
	stop_shake_timer.timeout.connect(stop_shake);
	fade_shake_timer.timeout.connect(fade_shake);
	
func _physics_process(delta: float) -> void:
	if shake_offset: offset = Vector2(randf_range(-shake_amplitude, shake_amplitude), randf_range(-shake_amplitude, shake_amplitude));
	else: offset = Vector2.ZERO;
	if shake_rotation: rotation = deg_to_rad(randf_range(-shake_amplitude, shake_amplitude))/2.0;
	else: rotation = 0.0;
	
	zoom = lerp(zoom, Vector2(zoom_value, zoom_value), delta*2.5);
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel"): zoom_value = 1.0;
	if event.is_action("wheel_up"): zoom_value *= 1.05;
	if event.is_action("wheel_down"): zoom_value /= 1.05;
	
func shake(amplitude : float = 10.0, duration : float = 5.0, fade_delay = 0.0, need_to_shake_offset : bool = true, need_to_shake_rotation : bool = true) -> void:
	shake_amplitude = amplitude;
	shake_offset = need_to_shake_offset;
	shake_rotation = need_to_shake_rotation;
	stop_shake_timer.start(duration);
	if fade_delay < duration: fade_shake_timer.start(fade_delay);
	else: fade_shake();
	
func stop_shake() -> void:
	shake_amplitude = 0.0;
	shake_offset = false;
	shake_rotation = false;
	fade_shake_timer.stop();
	stop_shake_timer.stop();
	if fade_tween: fade_tween.kill();
	
func fade_shake() -> void:
	if fade_tween: fade_tween.kill();
	fade_tween = create_tween();
	fade_tween.set_trans(Tween.TRANS_CUBIC);
	fade_tween.set_ease(Tween.EASE_OUT);
	fade_tween.tween_property(self, "shake_amplitude", 0.0, stop_shake_timer.time_left);
	
