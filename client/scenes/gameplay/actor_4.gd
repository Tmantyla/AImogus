extends Control

signal hovered(actor)
signal clicked(actor)

@export var target_actor : NodePath  # reference to the actor

func _ready():
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)
	gui_input.connect(_on_input)

func _on_enter():
	var actor = get_node(target_actor)
	emit_signal("hovered", actor)

func _on_exit():
	emit_signal("hovered", null)

func _on_input(event):
	if event is InputEventMouseButton and event.pressed:
		var actor = get_node(target_actor)
		emit_signal("clicked", actor)
