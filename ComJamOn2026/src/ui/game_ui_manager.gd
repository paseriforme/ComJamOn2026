extends Node
class_name GameUIManager

@export var rithm_game_manager	: RithmGameManager
@export var dialogue_manager	: DialogueManager
@export var telon 				: Control

var _npc : NPC = null

func _ready() -> void:
	Global.npc_hit.connect(_npc_hit)

func _npc_hit(npc : NPC):
	_npc = npc
	## ANDRES AQUI, CAMBIAR VISUALES

func start_dialoue():
	dialogue_manager.start_dialogue(_npc)

func start_song():
	rithm_game_manager.visible = true

func hide_ui():
	#dialogue_manager.visible = false
	rithm_game_manager.visible = false
	telon.visible = false
