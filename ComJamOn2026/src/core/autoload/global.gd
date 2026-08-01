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
@warning_ignore("unused_signal")
signal startSong(song: String, dificulty: String)

var coolDown = 0.5
var startCoolDown = false
var random = RandomNumberGenerator.new()

var direccion_jugador : Vector2 = Vector2.ZERO
var trastes: Array[bool] = [false, false, false, false, false];
var sfx_carton: Array[String] = [ "carton1", "carton2", "carton3", "carton4", "carton5", "carton6" ]
var sfx_papel: Array[String] = [ "paper1", "paper2", "paper3"]

var npc_chocado = null
var dialogo_aceptado = false;
var playing = false;

func _ready() -> void:
	pass

func timer(tiempo = 1.0):
	return get_tree().create_timer(tiempo).timeout


func play_cardboard(pitch):
	var ind: int = random.randi_range(0, len(sfx_carton) - 1)	
	#sound.play_sfx(sfx_carton[ind], pitch)
	$CanvasLayer/Control/Telon/Porcentaje.visible = true
	pass

func play_paper(pitch):
	var ind: int = random.randi_range(0, len(sfx_papel) - 1)	
	#sound.play_sfx(sfx_papel[ind], pitch)
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
