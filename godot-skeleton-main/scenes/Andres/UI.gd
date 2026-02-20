extends Node
class_name UI
@onready var dialogue_manager: DialogueManager = $Panel/DialogueManager

func showDialogue(character):
	dialogue_manager.start(0)
