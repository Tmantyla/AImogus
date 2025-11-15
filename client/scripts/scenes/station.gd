extends Node2D

var label_text := ""
@onready var machine_button := $Buttons/Vending/Machine
@onready var label := $Label

func _ready():
	ButtonHandler.connect_buttons(self)
	_apply_data()

func setup(data):
	label_text = data
	_apply_data()

func _apply_data():
	if is_inside_tree():
		machine_button.name = label_text
		label.text = label_text
