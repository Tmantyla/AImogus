extends Node

var hovered_actor: Node = null
var selected_actor: Node = null

func _ready():
	for actor in get_children():
		if actor.has_node("Hitbox"):
			# store original transforms
			actor.set_meta("orig_scale", actor.scale)
			actor.set_meta("orig_pos", actor.position)

			var hb = actor.get_node("Hitbox")
			hb.mouse_entered.connect(_on_hover_enter.bind(actor))
			hb.mouse_exited.connect(_on_hover_exit.bind(actor))
			hb.gui_input.connect(_on_click.bind(actor))


func _on_hover_enter(actor):
	if hovered_actor and hovered_actor != actor:
		_set_hover(hovered_actor, false)

	hovered_actor = actor
	_set_hover(actor, true)


func _on_hover_exit(actor):
	if hovered_actor == actor:
		_set_hover(actor, false)
		hovered_actor = null


func _on_click(event, actor):
	if event is InputEventMouseButton and event.pressed:

		# undo selection on previous
		if selected_actor and selected_actor != actor:
			_unset_selected(selected_actor)

		selected_actor = actor
		_set_selected(actor)
		print("Selected actor:", actor.name)


func _set_hover(actor, state):
	var orig_scale = actor.get_meta("orig_scale")
	var orig_pos = actor.get_meta("orig_pos")

	if state:
		actor.scale = orig_scale * 1.10
		actor.position = orig_pos + Vector2(0, -10)
	else:
		actor.scale = orig_scale
		actor.position = orig_pos


func _set_selected(actor):
	actor.modulate = Color(2, 2, 2, 1)


func _unset_selected(actor):
	actor.modulate = Color(1, 1, 1, 1)
