extends RigidBody2D
class_name CharacterController

@export var speed : float = 10

var directions := [Vector2(0,1), Vector2(0.75,0.75),Vector2(1,0), Vector2(0.75,-0.75),Vector2(0,-1), Vector2(-0.75,-0.75),Vector2(-1,0), Vector2(-0.75,0.75)]
var direction := 0

var redPressed = false;
var greenPressed = false;
var yellowPressed = false;
var bluePressed = false;
var orangePressed = false;
var strumPressed = false;
var canwalk = false;



func _physics_process(delta: float) -> void:
	if not canwalk: return
	
	# VERDE
	if not greenPressed and Input.is_action_pressed("verde",true):
		#print_debug("VERDE")
		Global.trastes[0] = true;
		greenPressed = true
		#animated_sprite_2d.play("up")
		direction += 1
		if direction >= len(directions): 
			direction = 0
		#print("TURN LEFT")
	elif Input.is_action_just_released("verde", true):
		Global.trastes[0] = false
		greenPressed = false
	# ROJO
	if not redPressed and Input.is_action_pressed("rojo",true):
		#print_debug("ROJO")
		Global.trastes[1] = true;
		redPressed = true
		#animated_sprite_2d.play("face_down")
		direction -= 1
		if direction < 0: 
			direction = len(directions) -1
		#print("TURN RIGHT")
	elif Input.is_action_just_released("rojo", true):
		Global.trastes[1] = false
		redPressed = false
	# AMARILLO
	if not yellowPressed and Input.is_action_pressed("amarillo",true):
		print_debug("AMARILLO")
		Global.trastes[2] = true
		yellowPressed = true
	elif Input.is_action_just_released("amarillo", true):
		Global.trastes[2] = false
		yellowPressed = false
	# AZUL
	if not bluePressed and Input.is_action_pressed("azul",true):
		print_debug("AZUL")
		Global.trastes[3] = true
		bluePressed = true
	elif Input.is_action_just_released("azul", true):
		Global.trastes[3] = false
		bluePressed = false	
	# NARANJA
	if not orangePressed and Input.is_action_pressed("naranja",true):
		print_debug("NARANJA")
		Global.trastes[4] = true
		orangePressed = true
	elif Input.is_action_just_released("naranja", true):
		Global.trastes[4] = false
		orangePressed = false	
	if not strumPressed and Input.is_action_pressed("rasgar",true):
		#print_debug("RASGAR")
		var velocity = directions[direction] * speed
		# ANDRES AQUI
		strumPressed = true
		apply_impulse(velocity)
		#print("MOVE: ", directions[direction])
	elif Input.is_action_just_released("rasgar", true):
		strumPressed = false
	pass
