extends Node2D
class_name GameState

enum states {WALK, TALK, PLAY}

@onready var character: CharacterController = $Character
@onready var canvas_layer: UI = $CanvasLayer

var state := states.WALK

func _ready() -> void:
	set_state(states.WALK)
	Global.end_song.connect(_end_song)

func _end_song():
	print("END SONG")
	set_state(states.WALK)

func set_state(st : states):
	state = st
	match st:
		states.WALK:
			print("WALK")
			character.canwalk = true
			character.set_process(true)
			canvas_layer.visible(false)
			pass
		states.TALK:
			print("TALK")
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			pass
		states.PLAY:
			print("PLAY")
			character.canwalk = false
			character.set_process(false)
			canvas_layer.visible(true)
			canvas_layer.control_disco.start_song()
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
		print_debug("NARANJA")
		Global.trastes[4] = true
	elif Input.is_action_just_released("naranja", true):
		Global.trastes[4] = false
