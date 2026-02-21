extends Node
class_name UI
@onready var dialogue_manager: DialogueManager = $Panel/DialogueManager
@onready var panel: Panel = $Panel
@onready var game_state: GameState = $".."

func _ready() -> void:
	Global.end_dialogue.connect(end_dialogue)
	
	panel.visible = false
	panel.set_process(false)

func show_dialogue(character):
	panel.visible = true
	panel.set_process(true)
	
	dialogue_manager.start(0)

func end_dialogue():
	panel.visible = false
	game_state.set_state(GameState.states.PLAY)
