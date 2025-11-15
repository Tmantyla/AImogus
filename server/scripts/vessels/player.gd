extends Vessel
class_name Player

var TEMP_dialogueAnswer = null
func TEMP_askDialogue(question: String):
	var edit := LineEdit.new()
	edit.placeholder_text = question
	edit.custom_minimum_size = Vector2(400, 30)
	edit.update_minimum_size()
	add_child(edit)
	edit.connect("text_submitted", func(text):
		self.TEMP_dialogueAnswer = text
		edit.queue_free()
	)

func requestQuestionToFriend() -> void:
	TEMP_dialogueAnswer = null
	TEMP_askDialogue("What do you wish to ask?")

func requestNextStation() -> void:
	TEMP_dialogueAnswer = null
	TEMP_askDialogue("Which station? (index from 0-" + str(currentPosition.connectedStations.size()-1) + ")")

func _process(delta: float) -> void:
	if id == 0: # temp for debug only control player with id 0
		match state:
			State.VOID:
				pass
			State.AT_STATION:
				if Input.is_action_just_pressed("ui_up"):
					goToChangeStation()
				if Input.is_action_just_pressed("ui_down"):
					pickupArtefact()
				if Input.is_action_just_pressed("ui_right"):
					var firstNotMe = null
					for vesselId in currentPosition.vesselsAtStation:
						if vesselId != id:
							firstNotMe = vesselId
							break
					if firstNotMe != null:
						print("Vessel " + str(id) + " initiating conversation with " + str(firstNotMe))
						initiateConversation(firstNotMe)
					else:
						print("Nobody else at station!")
			State.CHANGING_STATION:
				if TEMP_dialogueAnswer != null:
					var moveTo = int(TEMP_dialogueAnswer)
					if moveTo < 0 or moveTo > currentPosition.connectedStations.size()-1:
						print("This station doesnt exist")
						leaveChangeStation()
					else: 
						print("player moving to " + TEMP_dialogueAnswer)
						changeStation(int(TEMP_dialogueAnswer))
					TEMP_dialogueAnswer = null
			State.CHATTING_SENDER:
				if TEMP_dialogueAnswer != null:
					sendQuestion(TEMP_dialogueAnswer)
					TEMP_dialogueAnswer = null
			State.CHATTING_RECIEVER:
				pass # Buddy should call your "recieve question" function
			State.CHATTING_CONTINUE:
				if Input.is_action_just_pressed("ui_up"):
					continueChat()
				if Input.is_action_just_pressed("up_down"):
					abortChat()
			_:
				print("Bad state, changing to VOID")
				state = State.VOID
	else:
		pass
