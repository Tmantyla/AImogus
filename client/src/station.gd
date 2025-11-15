extends Node2D

func _ready():
	ButtonHandler.connect_buttons(self)
	
var label_text := ""

func setup(data):
	label_text = data
	
func _process(delta):
	var my_label = $Label
	my_label.text = label_text
