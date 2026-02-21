extends RigidBody2D
class_name CharacterController

@export var speed : float = 10

var directions := [Vector2(0,1), Vector2(0.75,0.75),Vector2(1,0), Vector2(0.75,-0.75),Vector2(0,-1), Vector2(-0.75,-0.75),Vector2(-1,0), Vector2(-0.75,0.75)]
var direction := 0

var redPressed = false;
var greenPressed = false;
var strumPressed = false;
var canwalk = false;



func _physics_process(delta: float) -> void:
	if not canwalk: return
	
	if not greenPressed and Input.is_action_pressed("verde",true):
		#print_debug("VERDE")
		greenPressed = true
		#animated_sprite_2d.play("up")
		direction += 1
		if direction >= len(directions): 
			direction = 0
		#print("TURN LEFT")
	elif Input.is_action_just_released("verde", true):
		greenPressed = false
	if not redPressed and Input.is_action_pressed("rojo",true):
		#print_debug("ROJO")
		redPressed = true
		#animated_sprite_2d.play("face_down")
		direction -= 1
		if direction < 0: 
			direction = len(directions) -1
		#print("TURN RIGHT")
	elif Input.is_action_just_released("rojo", true):
		redPressed = false
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
