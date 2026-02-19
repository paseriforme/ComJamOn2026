extends CharacterBody2D
class_name CharacterController

@export var speed : float = 10

var directions := [Vector2(0,1), Vector2(0.75,0.75),Vector2(1,0), Vector2(0.75,-0.75),Vector2(0,-1), Vector2(-0.75,-0.75),Vector2(-1,0), Vector2(-0.75,0.75)]
var direction := 0

var redPressed = false;
var greenPressed = false;

func _physics_process(delta: float) -> void:
	if not greenPressed and Input.is_action_pressed("verde",true):
		greenPressed = true
		#animated_sprite_2d.play("up")
		direction -= 1
		if direction < 0: 
			direction = len(directions) -1
		print("TURN LEFT")
	elif Input.is_action_just_released("verde", true):
		greenPressed = false
	if not redPressed and Input.is_action_pressed("rojo",true):
		redPressed = true
		#animated_sprite_2d.play("face_down")
		direction += 1
		if direction >= len(directions): 
			direction = 0
		print("TURN RIGHT")
	elif Input.is_action_just_released("rojo", true):
		redPressed = false
	if Input.is_action_pressed("rasgar",true):
		velocity = directions[direction] * speed
		move_and_slide()
		print("MOVE: ", directions[direction])
	pass
