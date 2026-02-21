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

var init_scale;
var factor_spr_scale : Vector2 = Vector2(0.2, 0.2);
var trans_scale = Tween.TRANS_QUAD

var time_steps: float = 0.3
var factor_steps: float = -0.075
var ease_steps: int = Tween.EASE_OUT
var trans_steps: int = Tween.TRANS_CUBIC

var factor_spr_scale_2 : float = 0.5
var time_steps_2 : float = 0.75
var factor_steps_2 : float = 0.75

func _ready() -> void:
	init_scale = $Sprite2D.scale;


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
		
	# RASGEO
	if not strumPressed and Input.is_action_pressed("rasgar",true):
		#print_debug("RASGAR")
		var velocity = directions[direction] * speed
		# ANDRES AQUI
		strumPressed = true
		apply_impulse(velocity)
		#print("MOVE: ", directions[direction])
	elif Input.is_action_just_released("rasgar", true):
		strumPressed = false
		
	var colisiones: Array[Node2D] = get_colliding_bodies();
	if colisiones.size() > 0:
		_rebote()
		pass
	pass

func _callback_XD():
	# second
	var time = time_steps * time_steps_2
	# second scale
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", init_scale + factor_spr_scale * factor_spr_scale_2, time/2).set_trans(trans_scale)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "scale", init_scale, time/2).set_trans(trans_scale)

	# second steps
	var velocity = directions[direction] * speed * factor_steps_2 * factor_steps
	var tween2 = get_tree().create_tween()
	tween2.set_ease(ease_steps)
	tween2.tween_property(self, "position", position + velocity, time).set_trans(trans_steps)
	pass


func _on_body_entered(body: Node) -> void:
	_rebote();
	pass # Replace with function body.

func _rebote():
	print_debug("COLISION")
	
	#version por física
#		var velocity = directions[direction] * speed
#		velocity *= -0.5
#		apply_impulse(velocity)
	
	#escalado
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", init_scale + factor_spr_scale, time_steps/2).set_trans(trans_scale)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "scale", init_scale, time_steps/2).set_trans(trans_scale)
	
	#rebote
	var velocity = directions[direction] * speed * factor_steps
	var tween2 = get_tree().create_tween()
	tween2.set_ease(ease_steps)
	tween2.tween_property(self, "position", position + velocity, time_steps).set_trans(trans_steps)
	tween2.finished.connect(_callback_XD)
