# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

func _ready(): #{
	randomize();
	
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

#func _process(delta): #{
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass;
##}

func move_to_loc_rand(node): #{
	#	 36         assert((randi() % 100) == 23)                                            
	#var projectResolution=Vector2(Globals.get("display/width"),Globals.get("display/height"))
	# get_viewport().get_rect().size
	# - Godot 3: get_viewport().size.y
	# OS.get_windows_size()
	
	var win_x = int(get_viewport().size.x);
	var win_y = int(get_viewport().size.y);
	
	print("win x/y: ", win_x, ", ", win_y);
	
	var sprite_extends = null; # Vector2

	if (node and node.get_scale()): #{
		print("scale: ", node.get_scale());
		sprite_extends = node.get_node("Area2D/CollisionShape2D").shape.get_extents() * node.get_scale();
		print("spr.ext: ", sprite_extends[0], ", ", sprite_extends[1]);
		
		win_x -= int(sprite_extends[0] * 2.0);
		win_y -= int(sprite_extends[1] * 2.0);
		
		print("win x/y: ", win_x, ", ", win_y);
		
	node.set_position(Vector2(
		int((sprite_extends[0] * 0.5) + (randi() % win_x))
		,int((sprite_extends[1] * 0.5) + (randi() % win_y))
	));

#	var safe_x = win_x - s
#
#		print("SPRITE: ", $chicken.get_transform(), $chicken/Area2D/CollisionShape2D.shape.get_extents().x)
#
#	print("MOVE (", win_x, ", ", win_y, ")");
#}



#}
