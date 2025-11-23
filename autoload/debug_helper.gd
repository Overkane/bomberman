extends Node

func _input(event: InputEvent) -> void:
	if OS.has_feature("debug"):
		if event.is_action_pressed(&"kill_all_enemies"):
			get_tree().call_group(Globals.GROUP_ENEMIES, &"explode")
		elif event.is_action_pressed(&"kill_all_boxes"):
			get_tree().call_group(Globals.GROUP_DESTRUCTIBLE_BOXES, &"explode")
