# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

const FRAME_MCLC = 0;
const FRAME_MOLC = 1;
const FRAME_MCLO = 2;
const FRAME_MOLO = 3;
const FRAME_OFF_LO = 2; # Number to add to frame for legs open
const FRAME_COUNT  = 2; # Number of frames total (not counting legs open)

const TIME_LAY  = 1.0;

var _lastmove   = 0.0;
var _lastanim   = 0.0;
var _donelaying = 0.0;

var laying = false;

func _ready(): #{
	$AnimatedSprite.set_frame(FRAME_MCLC);
#}

func _process(delta): #{
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	if (_donelaying > 0.0): #{
		_donelaying -= delta;
		$AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1])));
		if (_donelaying <= 0.0): #{
			# We'll do this on next move instead
			#self.z_index = 0;
			#$AnimatedSprite.set_position(Vector2(0, 0));
			laying = false;
		#}
	#}
	
	if (_lastanim < 0.6): #{
		_lastanim += delta;
		
	else: #} {
		# Animate
		_lastanim -= 0.6;
		_animate_frame_rand();
	#}
	
	if (!laying): #{
		if (_lastmove < 1.0): #{
			_lastmove += delta;
			
		else: #} {
			# Move
			_lastmove -= 1.0;
			self.z_index = 0;
			$AnimatedSprite.set_position(Vector2(0, 0));
			_move_location_rand();
		#}
	#}
#}

func _animate_frame_rand(): #{
	var from = $AnimatedSprite.frame;
	var to   = (randi() % FRAME_COUNT);
	if (laying): to += FRAME_OFF_LO;
	$AnimatedSprite.set_frame(to);
	var now  = $AnimatedSprite.frame;
	
	print("ANIMATE: ", from, " --> ", to, " --> ", now);
#}

func lay(): #{
	if (laying): return;
	
	laying = true;
	self.z_index = 1;
	_donelaying = TIME_LAY;
	$AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1])));

	#	print(node.get_node("Area2D/CollisionShape2D"))
	#	sprite_extends = node.get_node("Area2D/CollisionShape2D").shape.get_extents();
	
	var egg = get_tree().get_root().get_node("root/egg").duplicate()
	get_tree().get_root().add_child(egg)
	if (egg.lay(self, self.global_position)): #{
		# Layed
		print("LAYED");
	#}
#}

func _move_location_rand(): #{
	self.get_parent().move_to_loc_rand(self);
#}
