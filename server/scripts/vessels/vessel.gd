extends Node2D
class_name Vessel
const State = ServerUtilities.VS

var id = -1
var currentPosition: Station
var state: State = State.VOID
var server: Server = null

var recievedQuestion = null
var conversationBuddy = null

var artefacts: int = 0
var interrupted: bool = false

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

func requestActionAtVendingMachine() -> void:
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
	if conversationBuddy != null:
		currentPosition.shout(id, ServerUtilities.ActionSignal.END_CHAT, str(conversationBuddy))
	recievedQuestion = null
	conversationBuddy = null
	state = State.AT_STATION
	
# Someone did something! 
func observe(who: int, what: ServerUtilities.ActionSignal, subject: String) -> void:
	pass # OVERRIDE THIS
	
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

# Change station to the one with id sid
func changeStation(sid: int) -> void:
	currentPosition.disconnectVessel(id)
	var nextPosition = null
	for station in currentPosition.connectedStations:
		if station.id == sid:
			nextPosition = station
	if nextPosition == null:
		print("Station not connected to current")
	else:
		currentPosition.shout(id, ServerUtilities.ActionSignal.LEAVE, str(nextPosition.id))
		nextPosition.shout(id, ServerUtilities.ActionSignal.ARRIVE, str(currentPosition.id))
		
		nextPosition.connectVessel(id)
		currentPosition = nextPosition
	state = State.AT_STATION
	
	
func refillVendingMachine() -> void:
	print("refilled")
	currentPosition.shout(id, ServerUtilities.ActionSignal.REFILL_VENDING, "")
	leaveVendingMachine()

func repairVendingMachine() -> void:
	print("repaired")
	currentPosition.shout(id, ServerUtilities.ActionSignal.REPAIR_VENDING, "")
	leaveVendingMachine()

func leaveVendingMachine() -> void:
	state = State.AT_STATION
	currentPosition.shout(id, ServerUtilities.ActionSignal.LEAVE_VENDING, "")
	
# I would like to pick up an artefact
func pickupArtefact() -> void:
	if currentPosition.artefacts.size() > 0:
		currentPosition.artefacts.pop_back()
		artefacts+=1
		currentPosition.shout(id, ServerUtilities.ActionSignal.PICKUP_ARTEFACT, "")
	else:
		print("No artefacts to pick up")
		
# It seems someone wants to talk to me
func recieveConversationFrom(vesselId: int) -> void:
	state = State.CHATTING_RECIEVER
	interrupted = true
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
	if conversationBuddy != null:
		var buddy = server.vessels[conversationBuddy]
		buddy.recieveQuestion(text)
	state = State.CHATTING_RECIEVER

# I would like to act at the vending machine
func goToVendingMachine() -> void:
	state = State.AT_VENDING_MACHINE
	requestActionAtVendingMachine()
	currentPosition.shout(id, ServerUtilities.ActionSignal.GO_TO_VENDING, "")

# I would like to talk with vesselId
func initiateConversation(vesselId: int) -> void:
	state = State.CHATTING_SENDER
	conversationBuddy = vesselId
	server.vessels[vesselId].recieveConversationFrom(id)
	requestQuestionToFriend()
	currentPosition.shout(id, ServerUtilities.ActionSignal.START_CHAT, str(conversationBuddy))

func _process(delta: float) -> void:
	pass
