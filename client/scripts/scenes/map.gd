extends Node2D

func _on__input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var clicked_button = get_child(shape_idx)
		PlayerState.station = clicked_button.name

		Server.send_event("change_location", {"location": PlayerState.station})
		get_tree().change_scene_to_file("res://scenes/gameplay/station.tscn")
