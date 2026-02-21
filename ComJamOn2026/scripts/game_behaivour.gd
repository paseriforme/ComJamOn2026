extends Node2D
class_name GameState

enum states {WALK, TALK, PLAY}

@onready var character: CharacterController = $Character
@onready var canvas_layer: UI = $CanvasLayer

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
			canvas_layer.visible(false)
			pass
		states.TALK:
			print("TALK")
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			pass
		states.PLAY:
			print("PLAY")
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			canvas_layer.control_disco.start_song()
			pass
		_:
			pass
	
