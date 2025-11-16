extends Node

var player_id = -1
var visible_players = {}
var station = -1
var conversation_id = 1

func set_id(new_id):
	player_id = new_id
	
func set_visible_players(players):
	visible_players = players
