extends Node;

enum players_list{MAIN, MUSIC, THEME, NULL};
var current_player : players_list = players_list.NULL;

var is_main_player_now_cool : bool = true;

@onready var interface_player : AudioStreamPlayer = AudioStreamPlayer.new();
var interface_playback : AudioStreamPlayback;

@onready var theme_music_player : AudioStreamPlayer = AudioStreamPlayer.new();
@onready var music_player : AudioStreamPlayer = AudioStreamPlayer.new();
@onready var main_music_player : AudioStreamPlayer = AudioStreamPlayer.new();

var player_tween : Tween;

var new_music_time : float = 0.0;
var new_main_music_time : float = 0.0;
var new_theme_music_time : float = 0.0;

var streams_played_at_this_frame : Array[AudioStream];

signal music_player_started(stream : AudioStream, time : float);
signal main_music_player_started(stream : AudioStream, time : float);
signal theme_music_player_started(stream : AudioStream, time : float);

signal any_music_player_started(stream : AudioStream, time : float, player : AudioStreamPlayer);

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	music_player.finished.connect(play_music);
	main_music_player.finished.connect(play_main_music)
	theme_music_player.finished.connect(play_theme_music)
	
	music_player.bus = "Music";
	main_music_player.bus = "Music";
	theme_music_player.bus = "Music";
	
	add_child(music_player);
	add_child(main_music_player);
	add_child(theme_music_player);
	
	interface_player.bus = "Sounds";
	add_child(interface_player);
	
	interface_player.max_polyphony = 100;
	interface_player.stream = AudioStreamPolyphonic.new()
	interface_player.play();
	
	interface_playback = interface_player.get_stream_playback();
	
	theme_music_player.volume_linear = 0.0;
	music_player.volume_linear = 0.0;
	main_music_player.volume_linear = 0.0;
	
	play_main_music(false, load("res://vanilla/music/test_music.mp3"));

func _physics_process(_delta: float) -> void:
	streams_played_at_this_frame.clear();
	
	if Input.is_action_just_pressed("5"): SoundManager.play_main_music();
	if Input.is_action_just_pressed("6"):
		SoundManager.music_player.stream = load("res://vanilla/music/second_trumpet.mp3");
		SoundManager.play_music(true);
	if Input.is_action_just_pressed("7"): SoundManager.play_main_music(true, load("res://vanilla/music/themes/strawberry_peppermint.mp3"));

func play_interface_sound(stream : AudioStream) -> void:
	if stream:
		play_playback_with_protection(interface_playback, stream)
		#interface_playback.play_stream(stream);
		

func stop_players() -> void:
	main_music_player.stop();
	music_player.stop();
	theme_music_player.stop();

func fade_players(player : AudioStreamPlayer) -> void:
	if player_tween: player_tween.kill();
	player_tween = create_tween();
	
	if main_music_player != player: player_tween.parallel().tween_property(main_music_player, "volume_linear", 0.0, 0.4);
	if music_player != player: player_tween.parallel().tween_property(music_player, "volume_linear", 0.0, 0.4);
	if theme_music_player != player: player_tween.parallel().tween_property(theme_music_player, "volume_linear", 0.0, 0.4);
	
	await get_tree().create_timer(0.4).timeout;
	
	if main_music_player != player: main_music_player.stream_paused = true;
	if music_player != player: music_player.stream_paused = true;
	if theme_music_player != player: theme_music_player.stream_paused = true;
	
	player_tween.stop();
	player_tween.play();
	
	player_tween.tween_property(player, "volume_linear", 1.0, 0.75);

func turn_on_only_one(player : AudioStreamPlayer) -> void:
	music_player.stream_paused = true;
	main_music_player.stream_paused = true;
	theme_music_player.stream_paused = true;
	
	player.stream_paused = false;

func play_theme_music(with_fade : bool = true, stream : AudioStream = null) -> void:
	if stream: theme_music_player.stream = stream;
	if with_fade: fade_players(theme_music_player);
	else: turn_on_only_one(theme_music_player);
	
	var playback_position : float = theme_music_player.get_playback_position()
	theme_music_player.play(playback_position);
	theme_music_player_started.emit(theme_music_player.stream, playback_position);
	any_music_player_started.emit(theme_music_player.stream, playback_position, theme_music_player);
	
	if new_theme_music_time != 0.0:
		theme_music_player.seek(new_theme_music_time);
		new_theme_music_time = 0.0;
	current_player = players_list.THEME;
func play_main_music(with_fade : bool = true, stream : AudioStream = null) -> void:
	if stream: main_music_player.stream = stream;
	is_main_player_now_cool = true;
	if !Settings.play_theme_music_as_main and !get_tree().paused:
		if with_fade: fade_players(main_music_player);
		else: turn_on_only_one(main_music_player);
		
		var playback_position : float = main_music_player.get_playback_position()
		main_music_player.play(playback_position);
		main_music_player_started.emit(main_music_player.stream, playback_position);
		any_music_player_started.emit(main_music_player.stream, playback_position, main_music_player);
		
		if new_main_music_time != 0.0:
			main_music_player.seek(new_main_music_time);
			new_main_music_time = 0.0;
		
		current_player = players_list.MAIN;
	else:
		if current_player != players_list.THEME:
			play_theme_music(true);
func play_music(with_fade : bool = true, stream : AudioStream = null) -> void:
	if stream: music_player.stream = stream;
	if !get_tree().paused:
		is_main_player_now_cool = false
		if with_fade: fade_players(music_player);
		else: turn_on_only_one(music_player);
		
		var playback_position : float = music_player.get_playback_position()
		music_player.play(playback_position);
		music_player_started.emit(music_player.stream, playback_position);
		any_music_player_started.emit(music_player.stream, playback_position, music_player);
		
		if new_music_time != 0.0:
			music_player.seek(new_music_time);
			new_music_time = 0.0;
		
		current_player = players_list.MUSIC;

func play_player_with_protection(player : Node, stream : AudioStream, offset : float = 0.0) -> void:
	for i in streams_played_at_this_frame.size():
		if streams_played_at_this_frame[i] == stream: return;
	streams_played_at_this_frame.push_back(stream);
	player.play(offset);
func play_playback_with_protection(playback : AudioStreamPlayback, stream : AudioStream) -> void:
	for i in streams_played_at_this_frame.size():
		if streams_played_at_this_frame[i] == stream: return;
	streams_played_at_this_frame.push_back(stream);
	playback.play_stream(stream);
