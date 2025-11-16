extends Node2D

var station_id = -1

func _ready():
	station_id = PlayerState.station
	spawn_character(Vector2(500, 100), PlayerState.player_id, true)

func spawn_character(pos: Vector2, id, is_player):
	var char_scene = preload("res://scenes/character/character.tscn")
	var character = char_scene.instantiate()	
	character.character_id = id
	character.position = pos
	character.is_player = is_player

func _process(delta: float) -> void:
	print(station_id)
