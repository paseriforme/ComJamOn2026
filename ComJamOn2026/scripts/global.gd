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

## maquina de estados y variables de flujo
var sm # state machine
var current_scene = Scenes.CONTEXT 
var next_scene = Scenes.CONTEXT
## MUY IMPORTANTE: MISMO ORDEN QUE EN EL SERIALIZED ARRAY DE LA STATEMACHINE
enum Scenes { CONTEXT, GAME, NULL}

## sonido
var sfx
var bgm
var sound

var coolDown = 0.5
var startCoolDown = false
var random = RandomNumberGenerator.new()

var trastes: Array[int] = [false, false, false, false, false];

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
