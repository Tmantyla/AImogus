extends Node2D

var label_text := ""

func setup(data):
	print(data)
	label_text = data
	print("hello!" + label_text)
	
func _process(delta):
	var my_label = $Label
	my_label.text = label_text
