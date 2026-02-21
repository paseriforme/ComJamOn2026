extends Node2D
class_name GameState

enum states {WALK, TALK, PLAY}

@onready var character: CharacterController = $Character
@onready var ui: UI = $CanvasLayer

var state := states.WALK

func _ready() -> void:
	set_state(states.WALK)
	Global.end_song.connect(_end_song)

func _end_song():
	print("END SONG")
	set_state(states.WALK)

func set_state(st : states):
	state = st
	match st:
		states.WALK:
			print("WALK")
			character.canwalk = true
			character.set_process(true)
			ui.visible(false)
			pass
		states.TALK:
			print("TALK")
			character.canwalk = false
			character.set_process(false)
			ui.visible(true)
			pass
		states.PLAY:
			print("PLAY")
			character.canwalk = false
			character.set_process(false)
			ui.visible(true)
			pass
		_:
			pass
	
