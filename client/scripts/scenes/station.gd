extends Node2D

var label_text := ""
@onready var machine_button := $Buttons/Vending/Machine
@onready var label := $Label

func _ready():
	ButtonHandler.connect_buttons(self)
	spawn_character(Vector2(500, 100), PlayerState.player_id, true)
	_apply_data()

func setup(data):
	label_text = data
	_apply_data()


func _apply_data():
	if is_inside_tree():
		machine_button.name = label_text
		label.text = label_text

func spawn_character(pos: Vector2, id, is_player):
	var char_scene = preload("res://scenes/character/character.tscn")
	var character = char_scene.instantiate()	
	character.character_id = id
	character.position = pos
	character.is_player = is_player
