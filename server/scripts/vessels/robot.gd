extends Vessel
class_name Robot

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

API:
	- Each turn you will be presented with a JSON.
	- If you are not in a special event, then the JSON has the follwing form:
		{	
			location: Int # Your current location
			observations": [String], # List of observations. These will change every round. Keep them in mind.
			tasks": [ { "location": Int, "action": String, }, ], # List of tasks.
			"actions": [Various types] } # List of possible actions.
		- In this default state of the game, you need to choose an action by responding with the following JSON (example: choose 5th action):
			{ action = 4 }
			- Add the following fields depending on the type of action:
				- If the type is "machine":
					actionType = "restock" | "repair" | "withdraw"
				- If the type is "interaction":
					message = "Your message to the other player"
					- Once the interaction has started, you will get the other player's message in the format {player = playerId, message = "lorem ipsum."}.
					- Once the interaction has started, you can answer with {message = "reply"} or quit by passing {quit = true} as your next message.
	- TODO: Voting interaction

IMPORTANT: FROM NOW ON RESPOND ONLY IN JSON

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
	# if self.interrupted:
	# 	match interrupt:
	# 		"meeting":
	# 			# TODO
	# 			pass
	# 		"conversation":
	# 			# TODO
	# 			pass
	# else:
	# TODO make the match arms actually do something
	match act.type:
		"movement":
			print("Robot %s changed station to %s" % [id, act.destination])
			# TODO move to station @Zen
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
						pass
					"refill":
						pass
			else:
				# Just take from the machine (default actions)
				pass

		"interaction":
			print("Robot %s wants to talk with player %s" % [id, act.player])
			# TODO makeli @Zen
		_:
			print("Robot %s was lobotomized", id)
			# TODO kill robot


func updateState():
	playerState["location"] = self.currentPosition.id
	playerState["observations"] = [""]  # TODO
	playerState["actions"] = [  # TODO
		{"type": "movement", "destination": 1},
		{"type": "movement", "destination": 3},
		{"type": "interaction", "player": 0},
		{"type": "machine"}
	]


var idle = true


func _process(delta: float) -> void:
	actTimer += delta
	# FIXME: Instead of idle this could check if State.VOID
	if actTimer > 5 and idle:
		actTimer = 0

		# TODO playerState = getState() type shi
		# Below is a dummy state
		updateState()

		match state:
			State.VOID:
				print("Robot " + str(id) + " wants to act but is VOID")
			State.AT_STATION:
				print("acting now!")
				idle = false
				parseAction(await action(playerState))
			_:
				print("Bad state, changing to VOID")
				state = State.VOID
