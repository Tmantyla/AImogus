extends Node

func connect_buttons(root: Node):
	for child in root.get_children():
		if child.name == "Buttons":
			for category in child.get_children():
				for btn in category.get_children():
					btn.pressed.connect(_on_button_pressed.bind(btn, category))

func _on_button_pressed(btn, category):
	if category.name == "Stations":
		_swap_scene("res://client/scenes/station.tscn", btn.name)
	if category.name == "Map":
		_swap_scene("res://client/scenes/map.tscn")
	if category.name == "Vending":
		_swap_scene("res://client/scenes/vending_machine.tscn", btn.name)
	if category.name == "Back":
		_swap_scene("res://client/scenes/station.tscn", btn.name)

func _swap_scene(path: String, data := ""):
	var scene := load(path)
	var inst = scene.instantiate()

	if data != "" and inst.has_method("setup"):
		inst.setup(data)

	var old_scene = get_tree().current_scene
	old_scene.queue_free()

	get_tree().root.add_child(inst)
	get_tree().current_scene = inst

	connect_buttons(inst)
