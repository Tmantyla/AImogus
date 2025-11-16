extends Node2D

class_name Server

var GAME_ON = false
var clientPlayer: Dictionary[int, int] = {}


const MAP_VERTICES = [0, 1, 2, 3, 4]
const MAP_EDGES = [[0, 1], [1, 2], [2, 3], [3, 0], [0, 2], [3, 4]]
const TEMP_VERTEX_POSITIONS: Array[Vector2] = [
	Vector2(100, 100), Vector2(400, 100), Vector2(400, 400), Vector2(100, 400), Vector2(50, 600)
]

var vessels: Dictionary[int, Vessel] = {}
var stations: Array[Station] = []

var ai = AiApi.new()

var inMeeting = false
var timeToNextMeeting: float = 5.0
var meetingSpeakerIndex = null
var meetingSpeakerOrder: Array[int] = []
var meetingPhase = 0
var finalSayDictionary: Dictionary[int, String] = {}
var howManyReady = 0
var voteDictionary: Dictionary[int, int] = {}
var speaksList: Array[String] = []


func _ready():
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("server running on port 9000")
	

func start_game():
	
	var humans = clientPlayer.size()
	var bots = 5
	var total = humans + bots
	var IDs: Array[int] = []
	for i in range(total):
		IDs.append(i)
	IDs.shuffle()
	var botIDs: Array[int] = []
	for i in range(total):
		if i < humans:
			clientPlayer[clientPlayer.keys()[i]] = IDs[i]
		else:
			botIDs.append(IDs[i])
	
	
	GAME_ON = true
	add_child(ai)
	for vertex in MAP_VERTICES:
		var station = Station.new(vertex, self)
		stations.append(station)
		station.position = TEMP_VERTEX_POSITIONS[vertex]
		add_child(station)  # For visual only

	for edge in MAP_EDGES:
		stations[edge[0]].connectStation(stations[edge[1]])
		stations[edge[1]].connectStation(stations[edge[0]])
		var line = Line2D.new()
		add_child(line)
		line.points = [TEMP_VERTEX_POSITIONS[edge[0]], TEMP_VERTEX_POSITIONS[edge[1]]]
		line.width = 2
		line.default_color = Color(0, 0, 0)

	for client in clientPlayer.keys():
		var player = Player.new(clientPlayer[client], self)
		add_child(player)
		vessels[clientPlayer[client]] = player
		
	for bot in botIDs:
		vessels[bot] = Robot.new(bot, self)
		add_child(vessels[bot])

func startMeetingPhase2() -> void:
	meetingPhase = 2
	meetingSpeakerIndex = null
	for id in vessels:
		vessels[id].meetingPhase2()

func startVoting() -> void:
	meetingPhase = 3
	howManyReady = 0
	for id in vessels:
		vessels[id].startVoting()

func recieveFinalSay(id: int, text: String) -> void:
	howManyReady += 1
	finalSayDictionary[id] = text
	if howManyReady >= meetingSpeakerOrder.size():
		startVoting()

func resetTimeToNextMeeting() -> void:
	timeToNextMeeting = 100.0

func broadcastLobotomy(id: int, reason: String) -> void:
	for vs in vessels:
		vessels[vs].observe(id, ServerUtilities.ActionSignal.LOBOTOMY, reason)

func voteOut(id: int) -> void:
	for vs in vessels:
		vessels[vs].observe(id, ServerUtilities.ActionSignal.VOTED_OUT, "")
	vessels[id].death()

func concludeVoting() -> void:
	howManyReady = 0
	meetingPhase = 0
	meetingSpeakerIndex = 0
	speaksList = []
	
	var vote_counts := {}

	# Count votes each player received
	for voter_id in voteDictionary.keys():
		var voted_player_id = voteDictionary[voter_id]
		vote_counts[voted_player_id] = vote_counts.get(voted_player_id, 0) + 1

	# Determine the highest vote count
	var max_votes := 0
	for count in vote_counts.values():
		if count > max_votes:
			max_votes = count

	# Find all players with this max count
	var winners := []
	for player_id in vote_counts.keys():
		if vote_counts[player_id] == max_votes:
			winners.append(player_id)

	# Output
	if winners.size() == 1:
		print("Voting out: ", winners[0])
		voteOut(winners[0])
	else:
		print("Tie, nobody was voted out")
	
	finalSayDictionary = {}
	voteDictionary = {}
	resetTimeToNextMeeting()
	for vs in vessels:
		vessels[vs].releaseFromVoting()
	inMeeting = false
	

func recieveVote(id: int, vote: int):
	howManyReady += 1
	voteDictionary[id] = vote
	if howManyReady >= meetingSpeakerOrder.size():
		concludeVoting()

func recieveTalkFromSpeaker(text: String) -> void:
	speaksList.append(text)
	for id in vessels:
		if id != currentSpeaker().id:
			vessels[id].meetingForward(currentSpeaker().id, text)
	if meetingSpeakerIndex != meetingSpeakerOrder.size()-1:
		meetingSpeakerIndex += 1
		currentSpeaker().recieveMeetingTurn()
	else:
		startMeetingPhase2()
		

func currentSpeaker() -> Vessel:
	if inMeeting and meetingSpeakerOrder.size() > 0 and meetingSpeakerIndex != null:
		return vessels[meetingSpeakerOrder[meetingSpeakerIndex]]
	else:
		print("ERROR: There is no meeting at the moment, meeting:" + str(inMeeting) + " Speakers: " + str(meetingSpeakerOrder.size()) + " Speaker: " + str(meetingSpeakerIndex))
		return vessels[0]

func startMeeting():
	print("Meeting starting")
	meetingPhase = 1
	timeToNextMeeting = 0
	inMeeting = true
	meetingSpeakerOrder = vessels.keys()
	
	for vessel in vessels:
		vessels[vessel].goToMeeting()
	
	meetingSpeakerOrder.shuffle()
	meetingSpeakerIndex = 0
	
	currentSpeaker().recieveMeetingTurn()
	

func _process(delta):
	if GAME_ON:
		if !inMeeting:
			timeToNextMeeting -= delta
			if timeToNextMeeting < 0:
				startMeeting()
				resetTimeToNextMeeting()
		else:
			pass
	else:
		if Input.is_action_just_pressed("ui_accept"):
			start_game()
	queue_redraw()
	
func _draw() -> void:
	if GAME_ON:
		if inMeeting:
			draw_string(ThemeDB.fallback_font, Vector2(600, 40), "Meeting Ongoing!", HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(0, 1, 1))
		for i in range(speaksList.size()):
			draw_string(ThemeDB.fallback_font, Vector2(500, 40 + 20*i), speaksList[i], HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
		var fs = finalSayDictionary.values()
		for i in range(fs.size()):
			draw_string(ThemeDB.fallback_font, Vector2(600, 40 + 20*i), fs[i], HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
		draw_string(ThemeDB.fallback_font, Vector2(30, 30), "Time to next meeting: " + str(int(timeToNextMeeting)), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(100, 100), "Press enter to start game, connected clients:", HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
		var keys = clientPlayer.keys()
		for i in range(keys.size()):
			draw_string(ThemeDB.fallback_font, Vector2(100, 120 + 20*i), "Client: " + str(keys[i]), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))


@rpc("any_peer")
func handle_message(type: String, payload: Dictionary):
	if type == "went_to_vending_machine":
		pass
	
func _on_peer_connected(peer_id):
	print("Client connected:", peer_id)
	if !clientPlayer.keys().has(peer_id):
		clientPlayer[peer_id] = -1

func _on_peer_disconnected(peer_id):
	print("Client disconnected:", peer_id)
	if clientPlayer.keys().has(peer_id):
		if vessels.has(clientPlayer[peer_id]):
			vessels[clientPlayer[peer_id]].lobotomy("Client disconnected")
		clientPlayer.erase(peer_id)
