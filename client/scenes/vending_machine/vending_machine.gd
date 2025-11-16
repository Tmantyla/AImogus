extends CharacterBody2D

enum State { FULL, BROKEN, EMPTY }

const TEXTURES = {
	State.FULL: preload("res://assets/graphics/full_vending_machine.png"),
	State.BROKEN: preload("res://assets/graphics/broken_vending_machine.png"),
	State.EMPTY: preload("res://assets/graphics/empty_vending_machine.png")
}

var current_state = State.FULL

func _ready():
	update_sprite()
	
func update_sprite():
	$Sprite2D.texture = TEXTURES[current_state]

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		Server.send_event("go_to_vending_machine")
		VendingMenu.open(self)
