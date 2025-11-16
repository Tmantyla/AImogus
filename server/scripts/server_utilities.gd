extends Node

enum VS {
	VOID,
	CHANGING_STATION,
	AT_STATION,
	CHATTING_SENDER,
	CHATTING_RECIEVER,
	CHATTING_CONTINUE,
	AT_VENDING_MACHINE,
	MEETING_WAITING,
	MEETING_TURN,
	MEETING_FINALSAY,
	MEETING_VOTE
}

func statename(vs: VS) -> String:
	match vs:
		VS.VOID:
			return "void"
		VS.CHANGING_STATION:
			return "changing station"
		VS.AT_STATION:
			return "at station"
		VS.CHATTING_SENDER:
			return "chatting (sender)"
		VS.CHATTING_RECIEVER:
			return "chatting (reciever)"
		VS.CHATTING_CONTINUE:
			return "chatting (continue?)"
		VS.AT_VENDING_MACHINE:
			return "at vending machine"
		VS.MEETING_WAITING:
			return "meeting (waiting)"
		VS.MEETING_TURN:
			return "meeting (your turn)"
		VS.MEETING_FINALSAY:
			return "meeting (final say)"
		VS.MEETING_VOTE:
			return "meeting (vote)"
		_:
			return "nothing"

enum ActionSignal {
	LEAVE,
	ARRIVE,
	START_CHAT,
	END_CHAT,
	GO_TO_VENDING,
	LEAVE_VENDING,
	REPAIR_VENDING,
	REFILL_VENDING,
	LOBOTOMY,
	VOTED_OUT,
	PICKUP_ARTEFACT
}

func actionString(what: ActionSignal, subject: String) -> String:
	var action = ""
	match what:
		ActionSignal.LEAVE:
			action = "Leave to " + subject
		ActionSignal.ARRIVE:
			action = "Arrive from " + subject
		ActionSignal.START_CHAT:
			action = "Start chat with " + subject
		ActionSignal.END_CHAT:
			action = "End chat with " + subject
		ActionSignal.GO_TO_VENDING:
			action = "Go to vending machine"
		ActionSignal.LEAVE_VENDING:
			action = "Leave from vending machine"
		ActionSignal.PICKUP_ARTEFACT:
			action = "Pickup artefact"
		ActionSignal.REPAIR_VENDING:
			action = "Repair vending machine"
		ActionSignal.REFILL_VENDING:
			action = "Refill vending machine"
		ActionSignal.LOBOTOMY:
			action = "Get lobotomized because of " + subject 
		ActionSignal.VOTED_OUT:
			action = "Get voted out"
		_:
			action = "Do something not accounted for in the programming"
	return action
