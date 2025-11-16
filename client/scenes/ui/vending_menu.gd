extends CanvasLayer

var vending_machine: Node = null

func open(vm: Node):
	vending_machine = vm
	visible = true

func _on_refill_button_pressed():
	Server.send_event("refill_vending_machine")
	visible = false

func _on_repair_button_pressed():
	Server.send_event("repair_vending_machine")
	visible = false

func _on_close_button_pressed():
	Server.send_event("leave_vending_machine")
	visible = false
