extends Node2D
class_name GameBehaivour

enum states {WALK, TALK, PLAY}

@export var character			: WorldPlayerController
@export var canvas_layer		: GameUIManager
@export var dialogue_man		: DialogueManager
@export var camara				: PhantomCamera2D
@export var fondo 				: TextureRect
@export var area_camara 		: String = "../Colisiones/Area/AreaShape"
@export var area_camara_talk : String = "../Colisiones/Area/AreaShape2"

@export var fondo_ini_x : float = -1600.0
@export var fondo_talk_x : float = -860.0
@export var fondo_play_x : float = -320.0

@export var fondo_tween_trans : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var fondo_tween_ease_walk : Tween.EaseType = Tween.EASE_OUT
@export var fondo_tween_ease_talk : Tween.EaseType = Tween.EASE_IN_OUT
@export var fondo_tween_ease_play : Tween.EaseType = Tween.EASE_OUT
@export var fondo_tween_time_walk : float = 2.0
@export var fondo_tween_time_talk : float = 2.0
@export var fondo_tween_time_play : float = 2.0

@export var tween_seguir : PhantomCameraTween
@export var tween_hablar : PhantomCameraTween

var state := states.WALK

# cacho que dura la cancion a reproducir
var ini := 0
var fin := len(Global.song)

func _ready() -> void:
	set_state(states.WALK)
	Global.aceptar.connect(_aceptar_dialogo)
	Global.negarse.connect(_rechazar_dialogo)
	Global.end_dialogue.connect(_end_dialogo)
	Global.end_song.connect(_end_song)
#	camara.tween_resource.duration = 20

func _aceptar_dialogo():
	Global.dialogo_aceptado = true
	
func _rechazar_dialogo():
#	set_state(states.WALK)	
	Global.dialogo_aceptado = false
	pass
	
func _end_dialogo():
	if not Global.dialogo_aceptado and not dialogue_man.starting:
#		print_debug("ESTOY FALLANDO AQUI")
		set_state(states.WALK)	

func _end_song():
	print("END SONG")
	set_state(states.WALK)

func set_state(st : states):
	state = st
	match st:
		states.WALK:
			print("WALK")
			character.set_process(true)
			canvas_layer.visible(false)
			Global.npc_chocado = null
			dialogue_man.set_process(false)
			Global.dialogo_aceptado = false
			Global.playing = false
			camara.follow_target = $Character
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_walk)
			tween2.tween_property(fondo, "position", Vector2(fondo_ini_x, 0), fondo_tween_time_walk).set_trans(fondo_tween_trans)
			Global.play_paper(0.2)
			tween2.finished.connect(func(): await Global.timer(0.1); if state == states.WALK: camara.set_limit_target(area_camara))
			await Global.timer(0.1)
			#character.canwalk = true
			pass
		states.TALK:
			print("TALK")
			#character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			dialogue_man.set_process(true)
			#twin
			camara.follow_target = $Character/Segundo
			camara.set_limit_target(area_camara_talk);
#			camara.set_limit_left(-10000000);
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_talk)
			tween2.tween_property(fondo, "position", Vector2(fondo_talk_x, 0), fondo_tween_time_talk).set_trans(fondo_tween_trans)
			Global.play_paper(0.2)
			pass
		states.PLAY:
			print("PLAY")
			dialogue_man.set_process(false)
			#character.canwalk = false
			character.set_process(false)	
			canvas_layer.visible(true)
			Global.playing = true
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_play)
			tween2.tween_property(fondo, "position", Vector2(fondo_play_x, 0), fondo_tween_time_play).set_trans(fondo_tween_trans)
			Global.play_paper(0.2)
			if (Global.cancion == "Voces"):
				Global.sound.play_sfx("cheer")
			tween2.finished.connect(func(): canvas_layer.control_disco.start_song())
			#tween2.finished.connect(func(): set_state(states.WALK))
