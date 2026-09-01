extends Node
class_name GameUIManager

@export var rithm_game_manager	: RithmGameManager
@export var dialogue_manager	: DialogueManager
@export var telon 				: Control
@export var fondo				: TextureRect

@export_group("Fondo por estado")
@export var fondo_walk_x : float = -1600.0
@export var fondo_talk_x : float = -860.0
@export var fondo_play_x : float = -320.0
@export var fondo_trans   : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var fondo_ease_walk : Tween.EaseType = Tween.EASE_OUT
@export var fondo_ease_talk : Tween.EaseType = Tween.EASE_IN_OUT
@export var fondo_ease_play : Tween.EaseType = Tween.EASE_OUT
@export var fondo_time_walk : float = 2.0
@export var fondo_time_talk : float = 2.0
@export var fondo_time_play : float = 2.0

var _npc : NPC = null
var _fondo_tween : Tween          # el tween activo, para poder matarlo

func _ready() -> void:
	Global.npc_hit.connect(_npc_hit)

func _npc_hit(npc : NPC):
	_npc = npc
	## ANDRES AQUI, CAMBIAR VISUALES

func start_dialoue():
	fondo_a_talk()
	dialogue_manager.start_dialogue(_npc)

func start_song():
	fondo_a_play()
	rithm_game_manager.start_song(_npc.song, _npc.difficulty)

func hide_ui():
	fondo_a_walk()


# --- Fondo -------------------------------------------------------------------
func fondo_a_walk() -> void:
	_mover_fondo(fondo_walk_x, fondo_ease_walk, fondo_time_walk)

func fondo_a_talk() -> void:
	_mover_fondo(fondo_talk_x, fondo_ease_talk, fondo_time_talk)

func fondo_a_play() -> void:
	_mover_fondo(fondo_play_x, fondo_ease_play, fondo_time_play)

func _mover_fondo(destino_x: float, ease: Tween.EaseType, tiempo: float) -> void:
	if _fondo_tween and _fondo_tween.is_running():
		_fondo_tween.kill()          # mata el anterior: nada de callbacks huérfanos
	_fondo_tween = create_tween()
	_fondo_tween.set_ease(ease)
	_fondo_tween.tween_property(fondo, "position", Vector2(destino_x, 0), tiempo) \
		.set_trans(fondo_trans)
	Global.play_paper(0.2)
