extends CanvasLayer

var timer = 0

func _physics_process(delta):
	timer += delta
	if timer > 1:
		queue_free()
