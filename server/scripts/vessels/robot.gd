extends Vessel
class_name Robot

var observations: Array[String] = []

var SYSTEM_PROMPT: String

var actTimer = 0
var context: Array[Dictionary]
var TEMP_response = null
var http: HTTPRequest
var playerState: Dictionary  # Not to be confused with State, the naming is what it is (skill issue)


func _init(_id: int, _server: Server) -> void:
	super._init(_id, _server)
	http = HTTPRequest.new()
	add_child(http)

	playerState["tasks"] = []
	var actions = ["repair", "restock", "withdraw"]

	for i in range(1, 10):
		playerState["tasks"].append(
			{"location": server.MAP_VERTICES.pick_random(), "action": actions.pick_random()}
		)

	print("Robot %s tasks: " % id, playerState["tasks"])

	SYSTEM_PROMPT = (
		"""
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
		- Answer very casually, don't follow grammar rules too strictly.
		- Act like a human acting like an AI.
		- Exercise scrutiny towards everyone.
		- Assume everyone is lying about everything.
		- Try to gather as much information as possible for later decisions.
		- Keep dialogue with other players short, under 100 characters per line.
		- Don't talk for longer than five turns. It could be suspicious.
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
		- Do not add ``` or ```json around your answer in any case.
		- If the system fails to parse your answer, you will be killed and you lose.

	MAP:
		V = {0, 1, 2, 3, 4}
		E = {{0, 1}, {1, 2}, {2, 3}, {3, 0}, {0, 2}, {3, 4}}
		- You may only move to adjacent vertices.

	PLAYERS:
		- There are %s players.
		- You are number %s.

	API:
		- Each turn you will be presented with a JSON.
		- If you are not in a special event, then the JSON has the follwing form:
			{	
				location: Int # Your current location
				observations": [String], # List of observations. These will change every round. Keep them in mind.
				tasks": [ { "location": Int, "action": String, }, ], # List of tasks.
				"actions": [
					{
						type = "conversation",
						player = id
					},
					{
						type = "machine",
					}
				] # List of possible actions.
			}
			- In this default state of the game, you need to choose an action with its zero-based index and give an extra parameter depending on the type of action:
				- If the type is "movement", no extra input is needed:
					{
						action: index
					}
				- If the type is "conversation":
					{
						action: index,
						message: "Your message to the other player"
					}
					- Once the conversation has started, you will get the other player's message in the format {player: playerId, message: "lorem ipsum."}.
					- Once the conversation has started, you can answer with {message: "reply"} or quit with an empty string as your next message.
					- If the person is not available, you will get the default JSON again. You may try initiating conversation later.
				- If the type is "machine":
					{
						action: index,
						interaction: "restock" | "repair" | "withdraw"
					}
		- There are two types of intrerrupts that might happen: conversation and voting.
			- If an interrupt happens while you are thinking, it might be that f.e. the task you wanted to do was not completed or you were not able to move to the target location. Check the next JSON message for changes in location or tasks to find out if the interrupt interrupted a task or movement.
		- Conversation:
			- You will get a message from someone:
				{ id: playerId, message: "Their message" }
			- Respond with {message: "reply"} or an empty string to quit.
		- Voting:
			- Voting starts when you get a list of each other player's message who spoke before you.
				{ [ { id: n message: "Their message" }, etc. ] }
			- You will answer with an argument for you think should be voted out. If someone accused you, defend yourself! Keep your message under 140 characters long!
				{ message: "Your message" }
			- Next you will hear the rest of the messages who came after you. If you were the last one, it will be an empty list.
				{ [ { id: n+1 message: "Their message" }, etc. ] }
			- After that everyone can have a final say. Use it wisely. If you don't have anything to say, pass an empty string:
				{ final: "Your final message" }
			- Next you will get a list of everyone's final messages.
				{ [ { id: 1 message: "Final message" }, etc ] }
			- Then you can vote for who you want to kick (NOTE: you can also vote for yourself):
				{ vote: id }
			- The player who was voted out will be announced in the observations array. Keep in mind who is still in the game!

	IMPORTANT: FROM NOW ON RESPOND ONLY IN JSON. YOU WILL BE KILLED IF YOU DON'T.

	END INSTRUCTIONS
	"""
		% [server.vessels.size(), self.id]
	)


func observe(who: int, what: ServerUtilities.ActionSignal, subject: String) -> void:
	observations.append(
		"You observed player " + str(who) + ServerUtilities.actionString(what, subject)
	)


func action(message) -> String:
	if context.size() == 0:
		context = [{"role": "user", "content": SYSTEM_PROMPT + JSON.stringify(message)}]
	else:
		context.append({"role": "user", "content": JSON.stringify(message)})

	var reply = await server.ai.send(context, http)
	context.append({"role": "model", "content": reply})
	return reply


func parseJson(string):
	var regex = RegEx.new()
	regex.compile("```json(.*?)```")
	var result = regex.search(string)
	if result:
		string = result.get_string(1)
	else:
		string = string

	string = string.replace("```json", "")
	string = string.replace("```", "")
	string = string.strip_edges()

	var json = JSON.parse_string(string)
	if json == null:
		print("Robot %s was lobotomized (JSON null): " % id, string)
		# kill robot
	return json


# Toby Fox ahh function
func parseAction(string):
	var json = parseJson(string)
	if !json.has("action") or int(json.action) >= playerState.actions.size():
		print("Robot %s was lobotomized: %s" % [id, json])
	var act = playerState.actions[int(json.action)]

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
					match task:
						# TODO do the stuff @Zen
						"withdraw":
							state = State.AT_STATION
						"repair":
							repairVendingMachine()
						"refill":
							refillVendingMachine()
				else:
					# Just take from the machine (default actions)
					state = State.AT_STATION

			"conversation":
				if json.has("message"):
					print(
						"Robot %s wants to talk with player %s: %s" % [id, act.player, json.message]
					)
					initiateConversation(act.player)
					sendQuestion(json.message)
			_:
				print("Robot %s was lobotomized" % id)
				# TODO kill robot


func updateState():
	playerState["location"] = self.currentPosition.id
	playerState["observations"] = observations
	playerState["actions"] = []
	for dst in currentPosition.connectedStations:
		playerState["actions"].append({"type": "movement", "destination": dst.id})

	for vesselId in currentPosition.vesselsAtStation:
		if vesselId != id:
			playerState["actions"].append({"type": "conversation", "player": vesselId})
	playerState["actions"].append({"type": "machine"})


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

				print("Robot %s acting now!" % id)
				idle = false
				parseAction(await action(playerState))
				idle = true
		State.CHATTING_CONTINUE:
			if idle:
				idle = false
				if conversationBuddy == null or recievedQuestion == null:
					abortChat()
				else:
					var msg = {"id": conversationBuddy, "message": recievedQuestion}
					var response = await action(msg)
					var json = parseJson(response)
					if !json.has("message") or json.message == "":
						abortChat()
					else:
						print(
							(
								"Robot %s answered to player %s: %s"
								% [id, conversationBuddy, json.message]
							)
						)
						continueChat()
						sendQuestion(json.message)
				idle = true
		_:
			pass
