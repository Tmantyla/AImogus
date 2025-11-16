extends Vessel
class_name Player

func observe(who: int, what: ServerUtilities.ActionSignal, subject: String) -> void:
	print("PLAYER " + str(id) + " OBSERVED " + str(who) + " " + ServerUtilities.actionString(what, subject) + "!")
	### Send observation to client

func meetingForward(who: int, text: String) -> void:
	pass ### TODO: Send this to client

func requestVote() -> void:
	pass

func requestMeetingAnswerPhase1() -> void:
	pass

func requestMeetingAnswerPhase2() -> void:
	pass

func requestActionAtVendingMachine() -> void:
	pass

func requestQuestionToFriend() -> void:
	pass

func requestNextStation() -> void:
	pass

func requestContinue() -> void:
	pass

func _process(delta: float) -> void:
	interrupted = false
	match state:
		State.VOID:
			pass
		State.AT_STATION:
			if recieved_commands.has("go_to_change_location"):
				goToChangeStation()
			elif recieved_commands.has("pick_up_artefact"):
				pickupArtefact()
			elif recieved_commands.has("try_converse_with_vessel"):
				var vesselId = int(recieved_commands["try_converse_with_vessel"])
				if vesselId != null and server.vessels[vesselId].chattable():
					print("Vessel " + str(id) + " initiating conversation with " + str(vesselId))
					initiateConversation(vesselId)
				else:
					print("Unable to chat with this person!")
			elif recieved_commands.has("go_to_vending_machine"):
				goToVendingMachine()
		State.CHANGING_STATION:
			if recieved_commands.has("change_location"):
				var moveTo = recieved_commands["change_location"]
				var found = false
				for st in currentPosition.connectedStations:
					if st.id == moveTo:
						print("player moving to " + moveTo)
						changeStation(moveTo)
						found = true
				if !found:
					print("Can't go to this station!")
					leaveChangeStation()
		State.CHATTING_SENDER:
			if recieved_commands.has("send_message"):
				sendQuestion(recieved_commands["send_message"])
		State.CHATTING_RECIEVER:
			pass # Buddy should call your "recieve question" function
		State.CHATTING_CONTINUE:
			if recieved_commands.has("continue_conversation"):
				if recieved_commands["continue_conversation"] == "true":	
					continueChat()
				else:
					abortChat()
		State.AT_VENDING_MACHINE:
			if recieved_commands.has("refill_vending_machine"):
				refillVendingMachine()
			elif recieved_commands.has("repair_vending_machine"):
				repairVendingMachine()
			elif recieved_commands.has("leave_vending_machine"):
				refillVendingMachine()
		State.MEETING_WAITING:
			pass
		State.MEETING_TURN:
			if recieved_commands.has("speak_at_meeting"):
				sayInMeeting(recieved_commands["speak_at_meeting"])
		State.MEETING_FINALSAY:
			if recieved_commands.has("speak_at_meeting"):
				finalSayInMeeting(recieved_commands["speak_at_meeting"])
		State.MEETING_VOTE:
			if recieved_commands.has("vote"):
				vote(int(recieved_commands["vote"]))
		_:
			print("Bad state, changing to VOID")
			state = State.VOID
	
	recieved_commands = {}
	queue_redraw()
	
func _draw() -> void:
	pass
