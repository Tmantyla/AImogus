extends CharacterBody2D

@export var is_player = false
@export var move_speed := 120.0
var character_id = -1

var target_pos = Vector2(0, 0)

func _ready():
	target_pos = global_position

func _input(event):
	if is_player:
		if event is InputEventMouseButton:
			set_target(event.position)

func set_target(pos: Vector2):
	target_pos = pos
	
func logistic(x: float, k: float = 0.05) -> float:
	return 1.0 / (1.0 + exp(-k * x))

func _physics_process(delta):
	var dir = target_pos - global_position
	var dist = dir.length()

	if dist < 2.0:
		velocity = Vector2.ZERO
		return

	var t := logistic(dist)

	velocity = dir.normalized() * (move_speed * t)

	move_and_slide()
