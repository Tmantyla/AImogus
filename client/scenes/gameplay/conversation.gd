extends Node2D

@onready var portrait := $Sprite2D

const SPEAKER_SPRITES = {
	0: preload("res://assets/graphicsupdate/voting_stage/actor_1.png"),
	1: preload("res://assets/graphicsupdate/voting_stage/actor_2.png"),
	2: preload("res://assets/graphicsupdate/voting_stage/actor_3.png"),
	3: preload("res://assets/graphicsupdate/voting_stage/actor_4.png"),
	4: preload("res://assets/graphicsupdate/voting_stage/actor_5.png"),
	5: preload("res://assets/graphicsupdate/voting_stage/actor_6.png"),
}

func _ready():
	if PlayerState.conversation_id in SPEAKER_SPRITES:
		portrait.texture = SPEAKER_SPRITES[PlayerState.conversation_id]
	else:
		portrait.texture = null
