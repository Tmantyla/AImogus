extends Node2D

var http: HTTPRequest

var timer = 0
var tick_interval = 1.0  # seconds

var rantest = false


func _process(delta):
	if !rantest:
		rantest = true

		var state = {
			"location": 0,
			"observations": ["The game has started"],
			"tasks":
			[
				{
					"location": 0,
					"action": "fix",
				},
				{
					"location": 1,
					"action": "restock",
				}
			],
			"actions":
			[
				{"type": "movement", "destination": 1},
				{"type": "movement", "destination": 3},
				{"type": "interaction", "player": 0},
				{"type": "machine"}
			]
		}

		var context = [
			{
				"role": "user",
				"content":
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
					- They will present all available actions clearly.
					- Answer using JSON only.
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
									quit = true | false
							- Once an interaction is initiated, you will get the player's response as your next prompt.
								- The "quit" field will indicate whether you want to quit the conversation after sending the message.
					- TODO: Voting interaction

				IMPORTANT: FROM NOW ON RESPOND ONLY IN JSON

				END INSTRUCTIONS
				"""
			},
			{"role": "user", "content": JSON.stringify(state)}
		]
		http = HTTPRequest.new()
		add_child(http)

		var reply = await AiApi.send(context)
		print(reply)
