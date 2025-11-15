extends Node2D
class_name Vessel
const State = SU.VS

var id = -1
var currentPosition: Station
var state: State = State.VOID
var server: Server = null

var recievedQuestion = null
var conversationBuddy = null

var artefacts: int = 0

func _init(_id: int, _server: Server) -> void:	
	id = _id
	server = _server
	state = State.AT_STATION
	currentPosition = server.stations[0]
	currentPosition.connectVessel(id)

func requestNextStation() -> void: 
	pass # OVERRIDE THIS

func requestQuestionToFriend() -> void:
	pass # OVERRIDE THIS
	
func requestContinue() -> void:
	pass # OVERRIDE THIS

# I wish to change station
func goToChangeStation() -> void:
	state = State.CHANGING_STATION
	requestNextStation()
	
# Nevermind, I will not change station
func leaveChangeStation() -> void:
	state = State.AT_STATION
	
# I would like to end the conversation
func abortChat() -> void:
	recievedQuestion = null
	if conversationBuddy != null:
		server.vessels[conversationBuddy].recieveAbortChat()
		conversationBuddy = null
	state = State.AT_STATION
	
# Apparently my buddy would like to end the conversation
func recieveAbortChat() -> void:
	recievedQuestion = null
	conversationBuddy = null
	state = State.AT_STATION
	
# I will continue the chat
func continueChat() -> void:
	if conversationBuddy != null:
		state = State.CHATTING_SENDER
		var buddy = server.vessels[conversationBuddy]
		buddy.recievedQuestion = null
		buddy.state = State.CHATTING_RECIEVER
		requestQuestionToFriend()
	else: 
		print("Conversation buddy disappeared??")
		state = State.AT_STATION

# Change station to index X
func changeStation(index: int) -> void:
	currentPosition.disconnectVessel(id)
	var nextPosition = currentPosition.connectedStations.get(index)
	nextPosition.connectVessel(id)
	currentPosition = nextPosition
	state = State.AT_STATION
	### SEND SIGNAL THAT I LEFT
	
# I would like to pick up an artefact
func pickupArtefact() -> void:
	if currentPosition.artefacts.size() > 0:
		currentPosition.artefacts.pop_back()
		artefacts+=1
		### SEND SIGNAL THAT I PICKED UP AN ARTEFACT
	else:
		print("No artefacts to pick up")
		
# It seems someone wants to talk to me
func recieveConversationFrom(vesselId: int) -> void:
	state = State.CHATTING_RECIEVER
	recievedQuestion = null
	conversationBuddy = vesselId
	
# Recieve Question
func recieveQuestion(text: String) -> void:
	state = State.CHATTING_CONTINUE
	print("Vessel " + str(id) + " recieved question: " + text)
	recievedQuestion = text
	requestContinue()
	
# Send Question to conversationBuddy
func sendQuestion(text: String) -> void:
	if conversationBuddy != -1:
		var buddy = server.vessels[conversationBuddy]
		buddy.recieveQuestion(text)
	state = State.CHATTING_RECIEVER

# I would like to talk with vesselId
func initiateConversation(vesselId: int) -> void:
	state = State.CHATTING_SENDER
	conversationBuddy = vesselId
	server.vessels[vesselId].recieveConversationFrom(id)
	requestQuestionToFriend()

func _process(delta: float) -> void:
	pass
