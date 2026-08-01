extends Node
class_name InputManager

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
