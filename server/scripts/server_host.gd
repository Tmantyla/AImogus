extends Node

func _ready():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("server running on port 9000")

@rpc("any_peer")
func handle_message(type: String, payload: Dictionary):
	if type == "went_to_vending_machine":
		pass
	
func _on_peer_connected(peer_id):
	print("Client connected:", peer_id)

func _on_peer_disconnected(peer_id):
	print("Client disconnected:", peer_id)
