extends Node2D

var station_id = -1
var timer = 0
func _ready():
	station_id = PlayerState.station
	spawn_character(Vector2(200, 375), PlayerState.player_id, false)
	spawn_character(Vector2(200, 375), PlayerState.player_id, true)
	spawn_character(Vector2(200, 375), PlayerState.player_id, false)
	for character in PlayerState.visible_players:
		spawn_character(Vector2(100, 500), character.id, false)
	
	
func spawn_character(pos: Vector2, id, is_player):
	var char_scene = preload("res://scenes/character/character.tscn")
	var character = char_scene.instantiate()	
	character.character_id = id
	character.position = pos
	character.is_player = is_player
	add_child(character)


func _on_area_2d_body_entered(body):
	if "is_player" in body and body.is_player:
		Server.send_event("go_to_change_location", {})
		PlayerState.station = -1
		get_tree().change_scene_to_file("res://scenes/gameplay/map.tscn")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
