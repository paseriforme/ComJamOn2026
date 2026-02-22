extends Node
class_name UI
@onready var control_disco: Control = $Panel/Fondo/control_disco
@onready var dialogue_manager: DialogueManager = $Panel/DialogueManager
@onready var panel: Panel = $Panel
@onready var game_state: GameState = $".."

func _ready() -> void:
	Global.end_dialogue.connect(_end_dialogue)
	
	visible(false)

func visible(vis):
	if vis:
		dialogue_manager.visible = true
		control_disco.stop_song()
	else:
		dialogue_manager.visible = false
		panel.set_process(false)

func show_dialogue(character):
	dialogue_manager.start(0)

func _end_dialogue():
	game_state.set_state(GameState.states.PLAY)
