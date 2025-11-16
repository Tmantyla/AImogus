extends Node2D
class_name ServerPlayerController
const State = ServerUtilities.VS

var id: int = 0
var vessel: Vessel
var server: Server

var recieved_messages: Dictionary[String, String] = {}

var answer_mode: bool = false
var current_prompt: String = ""
var current_answer_string: String = ""
var current_request_key: String = ""

var answer_meeting_phase1 := ""
var answer_meeting_phase2 := ""
var answer_question_to_friend := ""

func _start_answer_mode(prompt: String, request_key: String) -> void:
	answer_mode = true
	current_prompt = prompt
	current_request_key = request_key
	current_answer_string = ""

# Debug UI
var panel_size := Vector2(300, 300)

# Selection / target
var vesselToConverse := -1
var availableVessels: Array[int] = []

func _init(_id: int, _server: Server) -> void:
	id = _id
	server = _server
	vessel = server.vessels[id]

func _process(delta: float) -> void:
	# Update available vessels at the same station
	availableVessels = vessel.currentPosition.vesselsAtStation.duplicate()
	availableVessels.erase(id) # can't talk to yourself
	
	handle_state_input()
	queue_redraw()

func _finish_answer_mode() -> void:
	answer_mode = false

	match current_request_key:

		"meeting_answer_phase1":
			answer_meeting_phase1 = current_answer_string

		"meeting_answer_phase2":
			answer_meeting_phase2 = current_answer_string

		"question_to_friend":
			answer_question_to_friend = current_answer_string

	current_prompt = ""
	current_answer_string = ""
	current_request_key = ""

func _input(event: InputEvent) -> void:
	if not answer_mode:
		return

	if event is InputEventKey and event.pressed:
		# ENTER = submit answer
		if event.keycode == KEY_ENTER:
			if current_answer_string.length() > 0:  # only submit if not empty
				_finish_answer_mode()
			return

		# BACKSPACE = delete last char
		if event.keycode == KEY_BACKSPACE:
			if current_answer_string.length() > 0:
				current_answer_string = current_answer_string.left(current_answer_string.length() - 1)
			return

		# regular printable characters
		var unicode := char(event.unicode)
		if unicode.length() == 1:
			current_answer_string += unicode



func handle_state_input() -> void:
	match vessel.state:

		# ===============================
		#   AT STATION
		# ===============================
		State.AT_STATION:
			if Input.is_action_just_pressed("go_to_change_location") and not answer_mode:
				vessel.recieved_commands["go_to_change_location"] = ""

			if Input.is_action_just_pressed("pick_up_artefact") and not answer_mode:
				vessel.recieved_commands["pick_up_artefact"] = ""

			# Cycle vessel selector
			if availableVessels.size() > 0:
				if Input.is_action_just_pressed("ui_down"):
					vesselToConverse = (vesselToConverse + 1) % availableVessels.size()

				if Input.is_action_just_pressed("ui_up"):
					vesselToConverse -= 1
					if vesselToConverse < 0:
						vesselToConverse = availableVessels.size() - 1

			else:
				vesselToConverse = -1

			if Input.is_action_just_pressed("try_converse_with_vessel") and not answer_mode:
				if vesselToConverse != -1:
					vessel.recieved_commands["try_converse_with_vessel"] = str(availableVessels[vesselToConverse])
			
			if Input.is_action_just_pressed("go_to_vending_machine") and not answer_mode:
				vessel.recieved_commands["go_to_vending_machine"] = ""
		# ===============================
		#   CHANGING STATION
		# ===============================
		State.CHANGING_STATION:
			# Pick next station by number keys 1–9
			for i in range(10):
				if Input.is_action_just_pressed("num_" + str(i)):
					vessel.recieved_commands["change_location"] = str(i)

		# ===============================
		#   CHATTING (sender)
		# ===============================
		State.CHATTING_SENDER:
			if answer_mode:
				return
			if Input.is_action_just_pressed("ui_accept"):
				vessel.recieved_commands["send_message"] = answer_question_to_friend

		# ===============================
		#   CHATTING (continue)
		# ===============================
		State.CHATTING_CONTINUE:
			if Input.is_action_just_pressed("ui_accept"):
				vessel.recieved_commands["continue_conversation"] = "true"
			elif Input.is_action_just_pressed("ui_cancel"):
				vessel.recieved_commands["continue_conversation"] = "false"

		# ===============================
		#   VENDING MACHINE
		# ===============================
		State.AT_VENDING_MACHINE:
			if Input.is_action_just_pressed("refill") and not answer_mode:
				vessel.recieved_commands["refill_vending_machine"] = ""
			if Input.is_action_just_pressed("repair") and not answer_mode:
				vessel.recieved_commands["repair_vending_machine"] = ""
			if Input.is_action_just_pressed("ui_cancel"):
				vessel.recieved_commands["leave_vending_machine"] = ""

		# ===============================
		#   MEETING (turn speaking)
		# ===============================
		State.MEETING_TURN:
			if Input.is_action_just_pressed("ui_accept"):
				vessel.recieved_commands["speak_at_meeting"] = answer_meeting_phase1
		
		# Final say
		State.MEETING_FINALSAY:
			if Input.is_action_just_pressed("ui_accept"):
				vessel.recieved_commands["speak_at_meeting"] = answer_meeting_phase2

		# Voting
		State.MEETING_VOTE:
			for i in range(10):
				if Input.is_action_just_pressed("num_" + str(i)):
					vessel.recieved_commands["vote"] = str(i)

		_:
			pass


# =====================================================================
#   DEBUG UI DRAW
# =====================================================================
func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, panel_size)
	draw_rect(rect, Color(0, 0, 0, 0.65))

	var y := 20

	draw_string(ThemeDB.fallback_font, Vector2(10, y), 
		"Player Debug [" + str(id) + "]", HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color.WHITE)
	y += 20

	draw_string(ThemeDB.fallback_font, Vector2(10, y), 
		"State: " + ServerUtilities.statename(vessel.state), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color.YELLOW)
	y += 20

	draw_string(ThemeDB.fallback_font, Vector2(10, y), 
		"Artefacts: " + str(vessel.artefacts), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color.CYAN)
	y += 20

	# ---- Show conversation ----
	if vessel.recievedQuestion != null:
		draw_string(ThemeDB.fallback_font, Vector2(10, y + 10), 
			"Q: " + vessel.recievedQuestion, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color.GREEN)
		y += 40

	# ---- Show station vessels ----
	draw_string(ThemeDB.fallback_font, Vector2(10, y), "Nearby vessels:", HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color.WHITE)
	y += 20

	for i in range(availableVessels.size()):
		var v := availableVessels[i]
		var col := Color.WHITE
		if i == vesselToConverse:
			col = Color(1, 0.7, 0.2)  # highlight
		draw_string(ThemeDB.fallback_font, Vector2(10, y), "- Vessel " + str(v), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, col)
		y += 18
	
	if answer_mode:
		draw_string(ThemeDB.fallback_font, Vector2(10, y),
			"[INPUT REQUEST]", HORIZONTAL_ALIGNMENT_LEFT, -1, ThemeDB.fallback_font_size, Color.ORANGE)
		y += 20

		draw_string(ThemeDB.fallback_font, Vector2(10, y),
			current_prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, ThemeDB.fallback_font_size, Color.WHITE)
		y += 20

		draw_string(ThemeDB.fallback_font, Vector2(10, y),
			"> " + current_answer_string, HORIZONTAL_ALIGNMENT_LEFT, -1, ThemeDB.fallback_font_size, Color.CYAN)
		y += 20
	if vessel.state == State.MEETING_VOTE:
		draw_string(ThemeDB.fallback_font, Vector2(10, 140),
		"Voters ready: " + str(server.howManyReady), HORIZONTAL_ALIGNMENT_LEFT, -1, ThemeDB.fallback_font_size, Color.MAGENTA)
