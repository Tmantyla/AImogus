extends Node

enum VS {
	VOID,
	CHANGING_STATION,
	AT_STATION,
	CHATTING_SENDER,
	CHATTING_RECIEVER,
	CHATTING_CONTINUE,
	AT_VENDING_MACHINE,
	MEETING_NOTURN,
	MEETING_TURN,
	MEETING_END
}

enum ActionSignal {
	LEAVE,
	ARRIVE,
	START_CHAT,
	END_CHAT,
	GO_TO_VENDING,
	LEAVE_VENDING,
	REPAIR_VENDING,
	REFILL_VENDING,
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
		_:
			action = "Do something not accounted for in the programming"
	return action
