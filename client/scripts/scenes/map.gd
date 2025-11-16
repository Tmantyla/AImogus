extends Node2D

func _on__input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		PlayerState.station = self.name
		get_tree().change_scene_to_file("res://scenes/gameplay/station.tscn")
		
