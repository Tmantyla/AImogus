extends Sprite2D

func _on_vote_click(event):
	if event is InputEventMouseButton and event.pressed:
		get_parent().vote()
