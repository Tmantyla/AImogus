extends Node
class_name AiApi

# REPLACE THIS WITH YOUR OWN KEY
var GOOGLE_API_KEY = "API_KEY_HERE"
var GEMINI_CHAT_URL = (
	"https://aiplatform.googleapis.com/v1/publishers/google/models/gemini-2.5-flash-lite:generateContent?key=%s"
	% GOOGLE_API_KEY
)


func transform_history_for_gemini(history):
	var gemini_history = []
	for message in history:
		var transformed = {"role": message.role, "parts": [{"text": message.content}]}  # Typically "user" or "model"
		gemini_history.append(transformed)
	return gemini_history


func send(messages: Array, http) -> String:
	var history = transform_history_for_gemini(messages)
	var payload = {"contents": history, "generationConfig": {"candidateCount": 1}}
	var json_body = JSON.stringify(payload)
	var error = http.request(
		GEMINI_CHAT_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_body
	)
	if error != OK:
		push_error("HTTP request failed to start")
		return ""
	var result = await http.request_completed

	var response_code = result[1]
	var body = result[3]
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var data = JSON.parse_string(response_text)
		if data:
			return data.candidates[0].content.parts[0].text
		else:
			return ""
	else:
		push_error("Gemini API request failed with code: %s" % response_code)
		return ""
