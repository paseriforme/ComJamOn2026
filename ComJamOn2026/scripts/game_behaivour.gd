extends Node2D
class_name GameState

enum states {WALK, TALK, PLAY}

@onready var character: CharacterController = $Character
@onready var canvas_layer: UI = $CanvasLayer

var state := states.WALK

func _ready() -> void:
	set_state(states.WALK)

func set_state(st : states):
	state = st
	match st:
		states.WALK:
			character.canwalk = true
			pass
		states.TALK:
			character.canwalk = false
			pass
		states.PLAY:
			character.canwalk = false
			pass
		_:
			pass
	
