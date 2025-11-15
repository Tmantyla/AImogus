extends Node2D

class_name Server

const MAP_VERTICES = [0, 1, 2, 3, 4]
const MAP_EDGES = [[0, 1], [1, 2], [2, 3], [3, 0], [0, 2], [3, 4]]
const TEMP_VERTEX_POSITIONS: Array[Vector2] = [
	Vector2(100, 100),
	Vector2(400, 100),
	Vector2(400, 400),
	Vector2(100, 400),
	Vector2(50, 600)
]

var vessels: Dictionary[int, Vessel] = {}
var stations: Array[Station] = []

func _ready():
	for vertex in MAP_VERTICES:
		var station = Station.new(vertex, self)
		stations.append(station)
		station.position = TEMP_VERTEX_POSITIONS[vertex]
		add_child(station) # For visual only
	
	for edge in MAP_EDGES:
		stations[edge[0]].connectStation(stations[edge[1]])
		stations[edge[1]].connectStation(stations[edge[0]])
		var line = Line2D.new()
		add_child(line)
		line.points = [TEMP_VERTEX_POSITIONS[edge[0]], TEMP_VERTEX_POSITIONS[edge[1]]]
		line.width = 2
		line.default_color = Color(0, 0, 0)
	
	var debugPlayer = Player.new(0, self)
	add_child(debugPlayer)
	vessels[0] = debugPlayer
	vessels[1] = Robot.new(1, self)
	vessels[2] = Player.new(2, self)
	

func _process(delta):
	for id in range(vessels.size()):
		if id != 0:
			vessels[id]._process(delta)
