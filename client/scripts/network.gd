extends Node

func _ready():
	print("CLIENT: starting network")

	# Create ENet client peer
	var peer := ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 9000)  # change IP if needed
	multiplayer.multiplayer_peer = peer

	# Signals (connection status)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_disconnected)

func _on_connected():
	print("CLIENT: connected to server")

func _on_connection_failed():
	print("CLIENT: connection FAILED")

func _on_disconnected():
	print("CLIENT: disconnected from server")

# RPC handler for events sent from server → client
@rpc("authority")
func handle_message(type: String, payload: Dictionary):
	print("CLIENT RECEIVED EVENT:", type, payload)
	if type == "game_started":
		print("GAME STARTED")
		send_event("affirmative")
		

# Send event to server
func send_event(name: String, payload: Dictionary = {}):
	if multiplayer.is_server() or multiplayer.get_unique_id() != 0:
		rpc_id(1, "handle_message", name, payload)
		print("CLIENT SENT:", name, payload)
	else:
		print("CLIENT: not connected, can't send")
