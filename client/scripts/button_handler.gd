extends Node

func connect_buttons(root: Node):
	for child in root.get_children():
		if child.name == "Buttons":
			for category in child.get_children():
				for btn in category.get_children():
					btn.pressed.connect(_on_button_pressed.bind(btn, category))

func _on_button_pressed(btn, category):
	if category.name == "Stations":
		PlayerState.station = btn.name
		get_tree().change_scene_to_file("res://scenes/gameplay/station.tscn")
