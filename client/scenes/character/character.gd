extends CharacterBody2D

@export var is_player: bool = false
@export var move_speed: float = 120.0

var character_id := -1
var target_pos: Vector2 = Vector2.ZERO
var npc_idle_time := 0.0

# NPC settings
var wander_radius := 200.0
var npc_wait_time := 3.5
var npc_timer := 0.0


func _ready():
	target_pos = global_position
	npc_timer = npc_wait_time


func _input(event):
	if is_player:
		if event is InputEventMouseButton and event.pressed:
			set_target(event.position)


func set_target(pos: Vector2):
	target_pos = pos


func logistic(x: float, k: float = 0.05) -> float:
	return 1.0 / (1.0 + exp(-k * x))


func _physics_process(delta):
	if is_player:
		move_player(delta)
	else:
		move_npc(delta)


# ---------------------------------------------------------
# PLAYER MOVEMENT
# ---------------------------------------------------------
func move_player(delta):
	var dir = target_pos - global_position
	var dist = dir.length()

	if dist < 2.0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var t := logistic(dist)
	velocity = dir.normalized() * (move_speed * t)

	move_and_slide()

func move_npc(delta):
	if npc_idle_time > 0.0:
		npc_idle_time -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	npc_timer -= delta

	var dist = global_position.distance_to(target_pos)

	if dist < 4.0:
		npc_idle_time = randf_range(0.5, 1.5)
		npc_pick_new_target()
		return

	if npc_timer <= 0.0:
		npc_pick_new_target()
		
	var dir = (target_pos - global_position).normalized()
	velocity = dir * move_speed

	move_and_slide()

	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		velocity = velocity.bounce(collision.get_normal())
		target_pos = global_position + velocity.normalized() * 50.0



func npc_pick_new_target():
	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

	target_pos = global_position + random_offset
	npc_timer = npc_wait_time + randf()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_player:
		PlayerState.station = -1
		get_tree().change_scene_to_file("res://scenes/gameplay/map.tscn")
