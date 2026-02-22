extends Node
class_name UI
@onready var control_disco: Control = $Panel/Fondo/control_disco
@onready var dialogue_manager: DialogueManager = $Panel/DialogueManager
@onready var panel: Panel = $Panel
@onready var game_state: GameState = $".."

func _ready() -> void:
	Global.end_dialogue.connect(_end_dialogue)
#	visible(false)

func visible(vis):
	if vis:
		dialogue_manager.visible = true
	else:
		dialogue_manager.visible = false
#		panel.set_process(false)
		control_disco.stop_song()

func stop_song():
	control_disco.stop_song()

func show_dialogue(character):
	dialogue_manager.start(0)
	
#func continue_dialogue(character):
func _process(delta: float) -> void:
	if Global.playing: return 
	if Input.is_action_just_pressed("rasgar",true) and dialogue_manager.dialogue_box.visible and not dialogue_manager.ending and not dialogue_manager.starting:
		dialogue_manager.dialogue_box.pressed()

func _end_dialogue():
	if (Global.dialogo_aceptado):
		game_state.set_state(GameState.states.PLAY)
