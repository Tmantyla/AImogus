extends Node2D

class_name Station

var connectedStations: Array[Station] = []
var vesselsAtStation: Array[int] = []
var artefacts: Array[String] = []
var id: int
var server: Server

var spawnArefactTimer = 0
const ARTEFACT_SPAWN_RATE = 3000

func _init(_id: int, _server: Server) -> void:
	id = _id
	server = _server

func connectVessel(id: int) -> void:
	vesselsAtStation.append(id)

func disconnectVessel(id: int) -> void:
	vesselsAtStation.erase(id)

func connectStation(station: Station) -> void:
	connectedStations.append(station)
	
# Don't know why you'd ever need this but oh well
func disconnectStation(station: Station) -> void:
	connectedStations.erase(station)

func spawnArtefact() -> void:
	artefacts.append("Duck")

func shout(who: int, what: ServerUtilities.ActionSignal, subject: String) -> void:
	for vessel in vesselsAtStation:
		if vessel != who:
			server.vessels[vessel].observe(who, what, subject)

func _process(delta: float) -> void:
	spawnArefactTimer += delta
	var probabilityOfSpawn = spawnArefactTimer/ARTEFACT_SPAWN_RATE
	if randf() < probabilityOfSpawn:
		spawnArefactTimer = 0
		spawnArtefact()
	
	queue_redraw()
	

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color(1, 0, 0))
	for i in range(vesselsAtStation.size()):
		draw_string(ThemeDB.fallback_font, Vector2(0, 20*i), str(vesselsAtStation[i]), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size)
	draw_string(ThemeDB.fallback_font, Vector2(-30, 0), str(artefacts.size()), HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size, Color(0, 1, 0))
	
