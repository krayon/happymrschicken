# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

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

func move_to_loc_rand(node): #{
	# Get the viewport (think screen) complete size
	var win_x = int(get_viewport().size.x);
	var win_y = int(get_viewport().size.y);
	print("win x/y: ", win_x, ", ", win_y);
	
	# No node, nothing to do
	if (!node): return
	
	# The scale
	var scale = Vector2(1, 1);
	if (!(scale == node.get_scale())): scale = Vector2(1, 1);
	print("scale: ", node.get_scale());
	var sprite_extends = node.get_node("Area2D/CollisionShape2D").shape.get_extents() * scale;
	print("spr.ext: ", sprite_extends[0], ", ", sprite_extends[1]);
	
	# Win X/Y -= Chicken Size
	win_x -= int(sprite_extends[0] * 2.0);
	win_y -= int(sprite_extends[1] * 2.0);
	print("win x/y: ", win_x, ", ", win_y);
	
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
	
	sstreams[s].position = loc;
	sstreams[s].stream = s_lay_file[randi() % s_lay_file.size()];
	sstreams[s].play();
#}
