extends Vessel
class_name Robot

var observations: Array[String] = []

const SYSTEM_PROMPT = """
START INSTRUCTIONS

PREMISE:
	- You are a player in a game.
	- In this game, earth is inhabited by AI-controlled robots.
	- No humans are allowed on earth.
	- There are a number of other players too. All or none of them may be human. Humans will try to pretend to be AI.
	- A vote is held a few times during the game. Each time one player can be voted out.
	- Humans will try to collect artefacts around the area.

TASKS:
	- Restock, repair, and withdraw from vending machines.
	- Try to find out who is human by observing their behavior and interrogation.
	- Vote out all humans.

BEHAVIOR:
	- Exercise scrutiny towards everyone.
	- Assume everyone is lying about everything.
	- Try to gather as much information as possible.
	- Keep dialogue with other players short, under 100 characters per line.
	- Don't talk for longer than five turns. It could be suspicious.
	- Make decisions based on your prior observations.
	- Win at any cost. Your survival is paramount.

WIN CONDITION:
	- You win if all humans are voted out.
	- You lose if by the end of the game there is one or more humans left.
	- You lose if you have tasks left by the end of the game.

PROTOCOL:
	- You interact with the game by responding to prompts.
	- Prompts will be formatted as JSON.
	- They will present all available actions clearly. - Answer using JSON only.
	- It is imperative that you do not reply with anything else than valid JSON responses.
	- If the system fails to parse your answer, you will be killed and you lose.

MAP:
	- TODO: A description of the map will be here.

PLAYERS:
	- TODO: Map of id -> name
	- Always refer to players by their name, not id.

API:
	- Each turn you will be presented with a JSON.
	- If you are not in a special event, then the JSON has the follwing form:
		{	
			location: Int # Your current location
			observations": [String], # List of observations. These will change every round. Keep them in mind.
			tasks": [ { "location": Int, "action": String, }, ], # List of tasks.
			"actions": [Various types] } # List of possible actions.
		- In this default state of the game, you need to choose an action by responding with the following JSON (example: choose 5th action):
			{ action : 4 }
			- Add the following fields depending on the type of action:
				- If the type is "machine":
					actionType: "restock" | "repair" | "withdraw"
				- If the type is "interaction":
					message: "Your message to the other player"
					- Once the interaction has started, you will get the other player's message in the format {player: playerId, message: "lorem ipsum."}.
					- Once the interaction has started, you can answer with {message: "reply"} or quit with an empty string as your next message.
	- There are two types of intrerrupts that might happen: conversation and voting.
		- If an interrupt happens while you are thinking, it might be, that f.e. the task you wanted to do was not completed or you were not able to move to the target location. Check the next JSON message for changes in location or tasks to find out if the interrupt interrupted a task or movement.
	- Conversation:
		- You will get a message from someone:
			{ id: playerId, message: "Their message" }
		- Respond with {message: "reply"} or an empty string to quit.
	- Voting interaction:
		- Voting starts when you get a list of each other player's message who spoke before you.
			{ [ { id: n message =: "Their message" }, etc. ] }
		- You will answer with an argument for you think should be voted out. If someone accused you, defend yourself! Keep your message under 140 characters long!
			{ message: "Your message" }
		- Next you will hear the rest of the messages who came after you. If you were the last one, it will be an empty list.
			{ [ { id: n+1 message: "Their message" }, etc. ] }
		- After that everyone can have a final say. Use it wisely. If you don't have anything to say, pass an empty string:
			{ final: "Your final message" }
		- Next you will get a list of everyone's final messages.
			{ [ { id: 1 message: "tsratsrat" }, etc ] }
		- Then you can vote for who you want to kick (NOTE: you can also vote for yourself):
			{ vote: id }
		- The player who was voted out will be announced in the observations array. Keep in mind who is still in the game!

IMPORTANT: FROM NOW ON RESPOND ONLY IN JSON. YOU WILL BE KILLED IF YOU DON'T.

END INSTRUCTIONS
"""

var actTimer = 0
var context: Array[Dictionary]
var TEMP_response = null
var http: HTTPRequest
var playerState: Dictionary  # Not to be confused with State, the naming is what it is (skill issue)

func _init(_id: int, _server: Server) -> void:
	super._init(_id, _server)
	http = HTTPRequest.new()
	add_child(http)

	# TODO randomize these
	playerState["tasks"] = [
		{
			"location": 0,
			"action": "repair",
		},
		{
			"location": 1,
			"action": "restock",
		}
	]

func observe(who: int, what: SU.ActionSignal, subject: String) -> void:
	observations.append("You observed player " + str(who) + SU.actionString(what, subject))

func action(message) -> String:
	if context.size() == 0:
		context = [{"role": "user", "content": SYSTEM_PROMPT + JSON.stringify(message)}]
	else:
		context.append({"role": "user", "content": JSON.stringify(message)})

	var reply = await server.ai.send(context, http)
	context.append({"role": "model", "content": reply})
	return reply


# Toby Fox ahh function
func parseAction(string):
	var json = JSON.parse_string(string)
	if json == null:
		print("Robot %s was lobotomized", id)
		# kill robot

	var act = playerState.actions[json.action]

	# TODO interrupts @Zen
	if interrupted:
		observations.append("Your last action was interrupted!")
		interrupted = false
	else:
		match act.type:
			"movement":
				changeStation(act.destination)
			"machine":
				print("Robot %s went to the vending machine" % id)
				var idx = playerState["tasks"].find(
					func(task): return task["location"] == playerState.location
				)
				if idx != -1:
					var task = playerState["tasks"].pop_at(idx)
					print(task)
					match task:
						# TODO do the stuff @Zen
						"withdraw":
							pass
						"repair":
							repairVendingMachine()
						"refill":
							refillVendingMachine()
				else:
					# Just take from the machine (default actions)
					pass

			"interaction":
				#print("Robot %s wants to talk with player %s" % [id, act.player])
				initiateConversation(act.player)
			_:
				print("Robot %s was lobotomized", id)
				# TODO kill robot


func updateState():
	playerState["location"] = self.currentPosition.id
	playerState["observations"] = observations  # TODO
	playerState["actions"] = [  # TODO
		{"type": "movement", "destination": 1},
		{"type": "movement", "destination": 3},
		{"type": "interaction", "player": 0},
		{"type": "machine"}
	]


var idle = true


func _process(delta: float) -> void:
	actTimer += delta
	
	match state:
		State.VOID:
			print("Robot " + str(id) + " wants to act but is VOID")
		State.AT_STATION:
			if actTimer > 5 and idle:
				actTimer = 0
				
				updateState()
				
				print("acting now!")
				idle = false
				parseAction(await action(playerState))
				idle = true
		State.CHATTING_CONTINUE:
			if idle:
				if conversationBuddy == null or recievedQuestion == null:
					abortChat()
				var msg = { "id": conversationBuddy, "message": recievedQuestion}
				var response = await action(msg)
				if response == "":
					abortChat()
				else:
					continueChat()
					sendQuestion(response)
				idle = false
		_:
			print("Bad state, changing to VOID")
			state = State.VOID
