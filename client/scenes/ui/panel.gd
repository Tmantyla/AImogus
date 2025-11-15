extends Panel

@onready var messages = $MarginContainer/ScrollContainer/VBoxContainer
@onready var scroll = $MarginContainer/ScrollContainer

var timer = 0
func add_message(text: String):
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	messages.add_child(label)

	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

func _process(delta):
	if timer < 100:
		timer += 1
		add_message("asd")
