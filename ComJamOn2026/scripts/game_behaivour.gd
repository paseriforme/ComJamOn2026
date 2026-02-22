extends Node2D
class_name GameState

enum states {WALK, TALK, PLAY}

@onready var character: CharacterController = $Character
@onready var canvas_layer: UI = $CanvasLayer
@onready var camara: PhantomCamera2D = $PlayerPhantomCamera2D
@onready var fondo : TextureRect = $CanvasLayer/Panel/Fondo
@onready var area_camara : String = "Colisiones/Area/AreaShape"
@onready var area_camara_talk : String = "Colisiones/Area/AreaShape2"

@export var fondo_ini_x : float = -1280.0
@export var fondo_talk_x : float = -340.0
@export var fondo_play_x : float = 0

@export var fondo_tween_trans : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var fondo_tween_ease_walk : Tween.EaseType = Tween.EASE_OUT
@export var fondo_tween_ease_talk : Tween.EaseType = Tween.EASE_IN_OUT
@export var fondo_tween_ease_play : Tween.EaseType = Tween.EASE_OUT
@export var fondo_tween_time : float = 1.0

@export var tween_seguir : PhantomCameraTween
@export var tween_hablar : PhantomCameraTween

var state := states.WALK

func _ready() -> void:
	set_state(states.WALK)
	Global.end_song.connect(_end_song)
#	camara.tween_resource.duration = 20
	
func _end_song():
	print("END SONG")
	set_state(states.WALK)

func set_state(st : states):
	state = st
	match st:
		states.WALK:
			print("WALK")
			character.set_process(true)
			camara.follow_target = $Character
#			camara.tween_resource = tween_seguir
			character.canwalk = true
#			canvas_layer.visible(false)
			Global.npc_chocado = false
			camara.limit_target = area_camara
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_walk)
			tween2.tween_property(fondo, "position", Vector2(fondo_ini_x, 0), fondo_tween_time).set_trans(fondo_tween_trans)
			pass
		states.TALK:
			print("TALK")
			camara.follow_target = $Character/Segundo
			camara.limit_target = area_camara_talk
#			camara.tween_resource = tween_hablar
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			#twin
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_talk)
			tween2.tween_property(fondo, "position", Vector2(fondo_talk_x, 0), fondo_tween_time).set_trans(fondo_tween_trans)
			pass
		states.PLAY:
			print("PLAY")
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			canvas_layer.control_disco.start_song()
			var tween2 = get_tree().create_tween()
			tween2.set_ease(fondo_tween_ease_play)
			tween2.tween_property(fondo, "position", Vector2(fondo_play_x, 0), fondo_tween_time).set_trans(fondo_tween_trans)
			tween2.finished.connect(func(): set_state(states.WALK))
			pass
		_:
			pass

func _physics_process(delta: float) -> void:
	
	# VERDE
	if not Global.trastes[0]  and Input.is_action_pressed("verde",true):
		Global.trastes[0] = true;
	elif Input.is_action_just_released("verde", true):
		Global.trastes[0] = false
	# ROJO
	if not Global.trastes[1] and Input.is_action_pressed("rojo",true):
		Global.trastes[1] = true;
	elif Input.is_action_just_released("rojo", true):
		Global.trastes[1] = false
	# AMARILLO
	if not Global.trastes[2] and Input.is_action_pressed("amarillo",true):
		Global.trastes[2] = true
	elif Input.is_action_just_released("amarillo", true):
		Global.trastes[2] = false
	# AZUL
	if not Global.trastes[3] and Input.is_action_pressed("azul",true):
		Global.trastes[3] = true
	elif Input.is_action_just_released("azul", true):
		Global.trastes[3] = false
	# NARANJA
	if not Global.trastes[4] and Input.is_action_pressed("naranja",true):
		Global.trastes[4] = true
	elif Input.is_action_just_released("naranja", true):
		Global.trastes[4] = false
