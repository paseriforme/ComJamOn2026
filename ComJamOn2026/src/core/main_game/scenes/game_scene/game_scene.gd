extends Scene
class_name GameState

enum states {WORLD, TALK, PLAY}

@export var character	: WorldPlayerController
@export var game_ui 	: GameUIManager
@export var state		:= states.WORLD

func _ready() -> void:
	Global.npc_hit.connect(func(npc) :set_state(states.TALK))
	
	set_state(state)

func set_state(st : states):
	state = st
	match st:
		states.WORLD:
			print("WALK")
			game_ui.hide_ui()
			character.canwalk = true
		states.TALK:
			print("TALK")
			game_ui.start_dialoue()
			character.canwalk = false
		states.PLAY:
			print("PLAY")
			game_ui.start_song()
			character.canwalk = false
