extends Node

#var station_scene = preload("res://client/scenes/station.tscn")

func _ready():
	for child in get_children():
		for btn in child.get_children():
			btn.pressed.connect(_on_button_pressed.bind(btn, child))

func _on_button_pressed(btn, child):
	if child.name == "Stations":
		var scene := preload("res://client/scenes/station.tscn")
		var station := scene.instantiate()
		station.setup(btn.name)

		var old_scene = get_tree().current_scene
		old_scene.queue_free()                     # safe free
		get_tree().root.add_child(station)
		get_tree().current_scene = station
