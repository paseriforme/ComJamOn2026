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
signal npc_hit(NPC)
@warning_ignore("unused_signal")
signal end_dialogue()
@warning_ignore("unused_signal")
signal play_telon(int) ## Indica que se lance el telon y con que porcentaje
@warning_ignore("unused_signal")
signal end_song() ## Indica que se ha acabado la cancion
@warning_ignore("unused_signal")
signal aceptar()
@warning_ignore("unused_signal")
signal negarse()

var random = RandomNumberGenerator.new()

var direccion_jugador : Vector2 = Vector2.ZERO
var trastes 	: Array[bool] = [false, false, false, false, false]

const sfx_carton: Array[String] = [ "carton1", "carton2", "carton3", "carton4", "carton5", "carton6" ]
const sfx_papel: Array[String] = [ "paper1", "paper2", "paper3"]
const ACCIONES := ["verde", "rojo", "amarillo", "azul", "naranja"]

var npc_chocado = null
var dialogo_aceptado = false;
var playing = false;

func _input(event: InputEvent) -> void:
	for i in ACCIONES.size():
		if event.is_action_pressed(ACCIONES[i]):
			trastes[i] = true
		elif event.is_action_released(ACCIONES[i]):
			trastes[i] = false

func timer(tiempo = 1.0):
	return get_tree().create_timer(tiempo).timeout

func play_cardboard(pitch):
	var ind: int = random.randi_range(0, len(sfx_carton) - 1)	
	SoundSystem.play_sfx(sfx_carton[ind], pitch)
	#$CanvasLayer/Control/Telon/Porcentaje.visible = true
	pass

func play_paper(pitch):
	var ind: int = random.randi_range(0, len(sfx_papel) - 1)	
	SoundSystem.play_sfx(sfx_papel[ind], pitch)
	pass
