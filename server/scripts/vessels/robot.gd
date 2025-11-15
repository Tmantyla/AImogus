extends Vessel
class_name Robot

var actTimer = 0

var thoughts: Array[String] = []
var context = []

var TEMP_response = null

func requestNextStation() -> void:
	TEMP_response = str(randi() % currentPosition.connectedStations.size())

func _process(delta: float) -> void:
	actTimer+=delta
	var ACT: bool = false
	if actTimer > 2:
		actTimer = 0
		ACT = true
		
	match state:
		State.VOID:
			if ACT:
				print("Robot " + str(id) + " wants to act but is VOID")
		State.AT_STATION:
			if ACT:
				goToChangeStation()
		State.CHANGING_STATION:
			if ACT:
				if TEMP_response != null:
					print("Robot " + str(id) + " moving to station " + TEMP_response)
					changeStation(int(TEMP_response))
					TEMP_response = null
		State.CHATTING_SENDER:
			sendQuestion("Response!")
		State.CHATTING_RECIEVER:
			pass # Buddy should call your "recieve question" function
		State.CHATTING_CONTINUE:
			continueChat()
		_:
			print("Bad state, changing to VOID")
			state = State.VOID
