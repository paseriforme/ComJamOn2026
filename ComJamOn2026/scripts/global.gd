extends Node

## SEÑALES
# flujo
@warning_ignore("unused_signal")
signal on_transition_begin(speed)
@warning_ignore("unused_signal")
signal on_transition_end
@warning_ignore("unused_signal")
signal on_enable(scene)
@warning_ignore("unused_signal")
signal on_disable(scene)
@warning_ignore("unused_signal")
signal on_game_end()
@warning_ignore("unused_signal")
signal end_dialogue()
@warning_ignore("unused_signal")
signal end_song()
@warning_ignore("unused_signal")
signal chocar_npc()
@warning_ignore("unused_signal")
signal aceptar()
@warning_ignore("unused_signal")
signal negarse()

## maquina de estados y variables de flujo
var sm # state machine
var current_scene = Scenes.CONTEXT 
var next_scene = Scenes.CONTEXT
## MUY IMPORTANTE: MISMO ORDEN QUE EN EL SERIALIZED ARRAY DE LA STATEMACHINE
enum Scenes { CONTEXT, GAME, NULL}

## sonido
var sfx
var bgm
var sound : SoundManager
var cancion := "Instrumental"


var coolDown = 0.5
var startCoolDown = false
var random = RandomNumberGenerator.new()

var direccion_jugador : Vector2 = Vector2.ZERO
var trastes: Array[bool] = [false, false, false, false, false];
var sfx_carton: Array[String] = [ "carton1", "carton2", "carton3", "carton4", "carton5", "carton6" ]
var sfx_papel: Array[String] = [ "paper1", "paper2", "paper3"]


enum acordes {DO, RE, MI, SOL, NONE}
const DO  = [true, false, true, false, false]
const RE  = [false, true, false, false, false]
const FA  = [true, true, false, false, false]
const MI  = [false, false, true, false, false]
const SOL  = [false, false, false, true, false]
const LA  = [false, false, false, true, true]
const NONE  = [false, false, false, false, false]

var song := [
	#prueba
	#DO, DO, DO, DO, DO, DO, DO, DO,
	#intro
	NONE, NONE,
	# estrofa 1
	SOL, RE,
	RE, NONE,
	MI, DO,
	DO, NONE,
		
	SOL, RE,
	RE, NONE,
	MI, DO,
	DO, NONE,
	# pre-estribillo
	MI, NONE,
	DO, NONE,
	SOL, NONE,
	RE, NONE,
	
	# estribillo
	SOL, SOL,
	RE, RE,
	MI, MI,
	DO, DO,
	
	SOL, SOL,
	RE, RE,
	MI, MI,
	DO, DO,
	
	# estrofa 2
	SOL, RE,
	RE, NONE,
	MI, DO,
	DO, NONE,
		
	SOL, RE,
	RE, NONE,
	MI, DO,
	DO, NONE,
	
	# estribillo 2
	SOL, SOL,
	RE, RE,
	MI, MI,
	DO, DO,
	
	SOL, SOL,
	RE, RE,
	MI, MI,
	DO, DO,
	]
	
var npc_chocado = null
var dialogo_aceptado = false;
var playing = false;

func _ready() -> void:
	pass

func  _process(delta: float) -> void:
	if startCoolDown:
		if coolDown <= 0:
			startCoolDown = false
			coolDown = 0.5
		else:
			coolDown-= delta
	pass

func change_scene(next : Global.Scenes, speed = 1.0, force = true):
	Global.next_scene = next
	#print(">> Changing from ", Global.current_scene, " to ", Global.next_scene)
	if ((current_scene != next || force) and not startCoolDown):
		#startCoolDown = true
		Global.on_transition_begin.emit(speed)

func timer(tiempo = 1.0):
	return get_tree().create_timer(tiempo).timeout


func play_cardboard(pitch):
	var ind: int = random.randi_range(0, len(sfx_carton) - 1)	
	sound.play_sfx(sfx_carton[ind], pitch)
	pass
	
func play_paper(pitch):
	var ind: int = random.randi_range(0, len(sfx_papel) - 1)	
	sound.play_sfx(sfx_papel[ind], pitch)
	pass