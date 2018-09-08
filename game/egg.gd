# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

var mummy = null;
var dead  = true;

func _ready(): #{
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
#}

func _process(delta): #{
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	if (dead): return;
#}

func lay(owner, pos): #{
	if (dead == false): return false;
	dead = false;
	
	# Egg is lay(ed/ing), find an audio stream
	get_tree().get_root().get_node("root").play_lay_sound_at_loc(pos);
	
	self.mummy = owner;
	self.visible = true;
	self.position = pos;
	
	return true;
#}
