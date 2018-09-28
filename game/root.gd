# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D;

# Score, set using _score_set function
export (int) onready var score = 0 setget _score_set;

var _quit_delay = 3000.0;

# Array of sound resources
onready var s_lay_file = [
	  preload("res://lay.01.wav")
	, preload("res://lay.02.wav")
	, preload("res://lay.03.wav")
	, preload("res://lay.04.wav")
	];

# Array of AudioStreamPlayer/AudioStreamPlayer2D
var sstreams = [];

# Touch events
var touches = Array();
var quit_touches = Array();

func _ready(): #{
	randomize();
	
	for i in s_lay_file: #{
		i.loop = false;
	#}
	
	# Fill sound object array with or audio players
	sstreams.append($Stream1);
	sstreams.append($Stream2);
	sstreams.append($Stream3);
	sstreams.append($Stream4);
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	# Set score to zero. This also triggers music to play
	self.score = 0;
#}

func _process(delta): #{
	if (!quit_touches.empty()): #{
		$fade.color.a = clamp(float(OS.get_ticks_msec() - quit_touches.front()) / _quit_delay, 0.0, 1.0);
	else: #{
		$fade.color.a = 0.0;
	#}
#}

func _input(ev): #{
	if (ev.is_pressed() and ev.is_action("ui_cancel")): #{
		get_tree().quit();
		return;
		
	elif (ev.is_pressed() and ev.is_action("ui_accept")): #} {
		if (!$chicken.laying): #{
			$chicken.lay();
		#}
		return;
		
	elif (ev is InputEventKey         && ev.is_pressed()): #} {
		move_to_loc_rand($chicken);
		return;
	#}
	
	var middle_size = (get_viewport().size / 10.0);
	var middle_min  = (get_viewport().size /  2.0) - middle_size;
	var middle_max  = (get_viewport().size /  2.0) + middle_size;
	
	if (ev is InputEventScreenTouch && ev.is_pressed()): #} {
		var chick_size = $chicken.get_scale() * $chicken.get_node("Area2D/CollisionShape2D").shape.get_extents();
		var chick_min = $chicken.position - chick_size;
		var chick_max = $chicken.position + chick_size;
		
		if (OS.is_debug_build()): print("Touching (", ev.index, "): ", ev.position);
		
		touches.insert(ev.index, OS.get_ticks_msec());
		if (
			   middle_min.x < ev.position.x
			&& middle_min.y < ev.position.y
			&& middle_max.x > ev.position.x
			&& middle_max.y > ev.position.y
		): #{
			quit_touches.insert(ev.index, OS.get_ticks_msec());
		#}
		
		if (
			   chick_min.x < ev.position.x
			&& chick_min.y < ev.position.y
			&& chick_max.x > ev.position.x
			&& chick_max.y > ev.position.y
		): #{
			if (OS.is_debug_build()): print("Chicken: (", $chicken.position - chick_size, ", ", $chicken.position + chick_size, ")");
			$chicken.lay();
			return;
		#}
		
		$chicken.move_to_loc(ev.position);
	elif (ev is InputEventScreenTouch && !ev.is_pressed()): #} {
		var heldfor = 0;
		if (!touches.empty() && touches[ev.index]): #{
			heldfor = OS.get_ticks_msec() - touches[ev.index];
			touches.remove(ev.index);
		#}
		if (OS.is_debug_build()): print("Released (", ev.index, "): ", ev.position, ", secs: ", heldfor / 1000.0);
		
		heldfor = 0;
		if (!quit_touches.empty() && quit_touches[ev.index]): #{
			heldfor = OS.get_ticks_msec() - quit_touches[ev.index];
			quit_touches.remove(ev.index);
		#}
		
		if (heldfor < _quit_delay): return;
		
		if (OS.is_debug_build()): print("Middle: ", get_viewport().size / 2.0, ", Middle Point: ", middle_min, " - ", middle_max);
		
		if (
			   middle_min.x < ev.position.x
			&& middle_min.y < ev.position.y
			&& middle_max.x > ev.position.x
			&& middle_max.y > ev.position.y
		): #{
			get_tree().quit();
		#}
	#}
#}

func _exit_tree(): #{
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
#}

func _score_set(score_new): #{
	score = score_new;
	if (OS.is_debug_build()): print("score: ", score);
	if (score % 10 == 0): _play_music();
	
	# Function is called prior to scene setup?
	if (!is_inside_tree() || !has_node("HUD/margin/hor/scorebg/score")): return;
	
	$HUD/margin/hor/scorebg/score.text = str(score);
#}

func move_to_loc_rand(node): #{
	# Get the viewport (think screen) complete size
	var win_x = int(get_viewport().size.x);
	var win_y = int(get_viewport().size.y);
	if (OS.is_debug_build()): print("win x/y: ", win_x, ", ", win_y);
	
	# No node, nothing to do
	if (!node): return;
	
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
	if (!is_inside_tree() || !has_node("musictime")): return;
	$musictime.stop();
	$musictime/music.play();
	$musictime.start();
#}

func _on_musictime_timeout(): #{
	if (!$musictime/music.playing): $musictime/music.play();
#}
