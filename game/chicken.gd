# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

const FRAME_MCLC   = 0;
const FRAME_MOLC   = 1;
const FRAME_MCLO   = 2;
const FRAME_MOLO   = 3;
const FRAME_OFF_LO = 2; # Number to add to frame for legs open
const FRAME_COUNT  = 2; # Number of frames total (not counting legs open)

const TIME_ANIM = 0.6;
const TIME_MOVE = 1.0;
const TIME_LAY  = 0.6;

var _lastmove   = 0.0;
var _lastanim   = 0.0;
var _donelaying = 0.0;

var laying = false;

func _ready(): #{
	self.z_index = 1;
	$AnimatedSprite.set_frame(FRAME_MCLC);
#}

func _process(delta): #{
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	if (_donelaying > 0.0): #{
		_donelaying -= delta;
		$AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1] *2)));
		if (_donelaying <= 0.0): #{
			# We'll do this on next move instead
			#self.z_index = 0;
			#$AnimatedSprite.set_position(Vector2(0, 0));
			laying = false;
			_lastmove = TIME_MOVE;
			_animate_frame_rand();
		#}
	#}
	
	if (_lastanim < TIME_ANIM): #{
		_lastanim += delta;
		
	else: #} {
		# Animate
		_lastanim -= TIME_ANIM;
		_animate_frame_rand();
	#}
	
	if (!laying): #{
		if (_lastmove < TIME_MOVE): #{
			_lastmove += delta;
			
		else: #} {
			# Move
			
			# Now always 1
			#self.z_index = 0;
			
			$AnimatedSprite.set_position(Vector2(0, 0));
			_move_to_loc_rand();
		#}
	#}
#}

func _animate_frame_rand(): #{
	var from = $AnimatedSprite.frame;
	var to   = (randi() % FRAME_COUNT);
	if (to % 2 == 1): #{
		if (!$squark.playing): $squark.play();
	#}
	if (laying): to += FRAME_OFF_LO;
	$AnimatedSprite.set_frame(to);
	var now  = $AnimatedSprite.frame;
	
	print("ANIMATE: ", from, " --> ", to, " --> ", now);
#}

func lay(): #{
	if (laying): return;
	
	laying = true;
	# Now always 1
	#self.z_index = 1;
	_animate_frame_rand();
	_donelaying = TIME_LAY;
	$AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1])));
	
	#	print(node.get_node("Area2D/CollisionShape2D"))
	#	sprite_extends = node.get_node("Area2D/CollisionShape2D").shape.get_extents();
	
	var egg = get_tree().get_root().get_node("root/egg").duplicate()
	get_tree().get_root().add_child(egg)
	if (egg.lay(self, self.global_position)): #{
		# Layed
		print("LAYED");
		get_tree().get_root().get_node("root").score += 1;
	#}
#}

func move_to_loc(location): #{
	_lastmove -= TIME_MOVE;
	self.set_position(location);
#}

func _move_to_loc_rand(): #{
	_lastmove -= TIME_MOVE;
	self.get_parent().move_to_loc_rand(self);
#}
