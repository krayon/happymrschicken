# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D;

# Score, set using _score_set function
export (int) onready var score = 0 setget _score_set;

# Array of sound resources
var s_lay_file = [
	  preload("res://lay.01.wav")
	, preload("res://lay.02.wav")
	, preload("res://lay.03.wav")
	, preload("res://lay.04.wav")
	];

# Array of AudioStreamPlayer/AudioStreamPlayer2D
var sstreams = [];

func _ready(): #{
	randomize();
	
	# Fill sound object array with or audio players
	sstreams.append($Stream1);
	sstreams.append($Stream2);
	sstreams.append($Stream3);
	sstreams.append($Stream4);
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	# Set score to zero. This also triggers music to play
	self.score = 0;
#}

func _input(ev): #{
	if (ev.is_pressed() and ev.is_action("ui_cancel")): #{
		get_tree().quit();
		return;
	#}
	
	if (ev.is_pressed() and ev.is_action("ui_accept")): #{
		if (!$chicken.laying): #{
			$chicken.lay();
		#}
		return;
		
	elif (ev.is_pressed()): #} {
		move_to_loc_rand($chicken);
	#}
#}

func _exit_tree(): #{
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
#}

func _score_set(score_new): #{
	score = score_new;
	print("score: ", score);
	if (score % 10 == 0): _play_music();
#}

func move_to_loc_rand(node): #{
	# Get the viewport (think screen) complete size
	var win_x = int(get_viewport().size.x);
	var win_y = int(get_viewport().size.y);
	if (OS.is_debug_build()): print("win x/y: ", win_x, ", ", win_y);
	
	# No node, nothing to do
	if (!node): return
	
	# The scale
	var scale = Vector2(1, 1);
	var extents = Vector2(1, 1);
	if (node.get_scale()): scale = node.get_scale();
	if (OS.is_debug_build()): print("scale:   ", scale);
	extents = node.get_node("Area2D/CollisionShape2D").shape.get_extents();
	if (OS.is_debug_build()): print("extents: ", extents);
	var sprite_extends = (extents * 2.0) * scale;
	if (OS.is_debug_build()): print("spr.ext: ", sprite_extends[0], ", ", sprite_extends[1]);
	
	# Win X/Y -= Chicken Size
	win_x -= int(sprite_extends[0]);
	win_y -= int(sprite_extends[1]);
	if (OS.is_debug_build()): print("win x/y: ", win_x, ", ", win_y);
	
	node.set_position(Vector2(
		 int((sprite_extends[0] * 0.5) + (randi() % win_x))
		,int((sprite_extends[1] * 0.5) + (randi() % win_y))
	));
#}

func play_lay_sound_at_loc(loc): #{
	var target_s = 0;
	
	# Find a non-playing stream
	for s in range(sstreams.size()): #{
		if (!sstreams[s].playing): #{
			target_s = s;
			break;
		#}
	#}
	
	sstreams[target_s].position = loc;
	sstreams[target_s].stream = s_lay_file[randi() % s_lay_file.size()];
	sstreams[target_s].play();
#}

func _play_music(): #{
	# Function is called prior to scene setup?
	if (!$musictime): return;
	$musictime.stop();
	$musictime/music.play();
	$musictime.start();
#}

func _on_musictime_timeout(): #{
	if (!$musictime/music.playing): $musictime/music.play();
#}
