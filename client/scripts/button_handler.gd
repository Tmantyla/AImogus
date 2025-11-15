extends Node

func connect_buttons(root: Node):
	for child in root.get_children():
		if child.name == "Buttons":
			for category in child.get_children():
				for btn in category.get_children():
					btn.pressed.connect(_on_button_pressed.bind(btn, category))

func _on_button_pressed(btn, category):
	if category.name == "Stations":
		_swap_scene("res://scenes/gameplay/station.tscn", btn.name)
	if category.name == "Map":
		_swap_scene("res://scenes/gameplay/map.tscn")
	if category.name == "Vending":
		_swap_scene("res://scenes/gameplay/vending_machine.tscn", btn.name)
	if category.name == "Back":
		_swap_scene("res://scenes/gameplay/station.tscn", btn.name)
	if category.name == "VendingMachineActions":
		if btn.name == "Fix":
			var scene := preload("res://scenes/ui/minigame_fix.tscn")
			var inst := scene.instantiate()
			add_child(inst)
		if btn.name == "Restock":
			var scene := preload("res://scenes/ui/minigame_restock.tscn")
			var inst := scene.instantiate()
			add_child(inst)

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
