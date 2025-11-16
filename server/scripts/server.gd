extends Node2D

class_name Server

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

	var debugPlayer = Player.new(0, self)
	add_child(debugPlayer)
	vessels[0] = debugPlayer
	vessels[1] = Robot.new(1, self)
	for i in range(3, 10):
		vessels[i] = Robot.new(i, self)
		add_child(vessels[i])

	add_child(vessels[1])

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
	timeToNextMeeting = 20.0

func broadcastLobotomy(id: int, reason: String) -> void:
	for vs in vessels:
		vessels[vs].observe(id, ServerUtilities.ActionSignal.LOBOTOMY, reason)

func voteOut(id: int) -> void:
	finalSayDictionary = {}
	voteDictionary = {}
	resetTimeToNextMeeting()
	vessels[id].death()
	for vs in vessels:
		vessels[vs].observe(id, ServerUtilities.ActionSignal.VOTED_OUT, "")
		vessels[vs].releaseFromVoting()

func concludeVoting() -> void:
	howManyReady = 0
	meetingPhase = 0
	meetingSpeakerIndex = 0
	speaksList = []
	inMeeting = false
	
	var votes = voteDictionary.values()
	var voted: Dictionary = {}
	for vote in votes:
		var c = votes.count(vote)
		if voted[c] == null:
			voted[c] = []
		voted[c].append(vote)
	var mostVoted: Array[int] = voted[voted.keys().max()]
	
	if mostVoted.size() == 1 and vessels.keys().has(mostVoted[0]):
		voteOut(mostVoted[0])

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
	if !inMeeting:
		timeToNextMeeting -= delta
		if timeToNextMeeting < 0:
			startMeeting()
	else:
		pass
	queue_redraw()
	
func _draw() -> void:
	if inMeeting:
		for i in range(speaksList.size()):
			draw_string(ThemeDB.fallback_font, Vector2(500, 40 + 20*i), speaksList[i], HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
		var fs = finalSayDictionary.values()
		for i in range(fs.size()):
			draw_string(ThemeDB.fallback_font, Vector2(600, 40 + 20*i), fs[i], HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
	draw_string(ThemeDB.fallback_font, Vector2(30, 30), "Time to next meeting: " + str(int(timeToNextMeeting)), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(1, 1, 0))
