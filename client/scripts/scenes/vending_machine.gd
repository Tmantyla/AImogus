extends Node2D

var label_text = ""
@onready var back_button := $Buttons/Back/Back

func setup(data):
	label_text = data
	_apply_data()

func _ready():
	_apply_data()

func _apply_data():
	if is_inside_tree():
		back_button.name = label_text
		
