# vim:ts=4:tw=80:sw=4:ai:si

extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(ev):
	if (ev.is_pressed() and ev.is_action("ui_cancel")):
		get_tree().quit()
		return

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
