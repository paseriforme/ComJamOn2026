extends RigidBody2D
class_name CharacterController

@export var speed : float = 10

# N, NE, E, SE, S, SW, W, NW NOOOO
# S SW W NW N NE E SE
var directions := [Vector2(0,1), Vector2(0.75,0.75),Vector2(1,0), Vector2(0.75,-0.75),Vector2(0,-1), Vector2(-0.75,-0.75),Vector2(-1,0), Vector2(-0.75,0.75)]
@export var sprite_directions : Array[Texture2D] 
var direction := 0
	
var redPressed = false;
var greenPressed = false;
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

var colision = false

var control_current_time : float = 0.0
@export var control_feedback_time : float = 1.0
@onready var animator : AnimationPlayer = $AnimationPlayer 
var mostrando : bool = false

func _ready() -> void:
	control_current_time = control_feedback_time
	init_scale = $Sprite2D.scale;

func _physics_process(delta: float) -> void:
	
	colision = false
	if not canwalk: return
	
	control_current_time += delta
#	if (Input.is_anything_pressed()): # se ha pulsado algo
	if not strumPressed and Input.is_action_pressed("rasgar",true): 
		animator.play("despensamiento")
#		print_debug(">>> HAS PULSADO ALGO")
		control_current_time = 0.0
		mostrando = false
#		Global.play_paper(0.1)
	if control_current_time >= control_feedback_time and not mostrando and canwalk:
		control_current_time = 0.0
#		print_debug(">>> PENSAMIENTO")
		animator.play("pensamiento")
		mostrando = true
#		Global.play_paper(0.1)
		pass
		
	# VERDE
	if not greenPressed and Input.is_action_pressed("verde",true):
		greenPressed = true
		#animated_sprite_2d.play("face_down")
		direction += 1
		if direction >= len(directions): 
			direction = 0
		$Sprite2D.texture = sprite_directions[direction]
#		Global.play_paper(0.2)
		#print("TURN LEFT")
	if Input.is_action_just_released("verde", true): greenPressed = false
		
	# ROJO
	if not redPressed and Input.is_action_pressed("rojo",true):
		redPressed = true
		#animated_sprite_2d.play("face_down")
		direction -= 1
		if direction < 0: 
			direction = len(directions) -1
		$Sprite2D.texture = sprite_directions[direction]
#		Global.play_paper(0.2)
		#print("TURN RIGHT")
	if Input.is_action_just_released("rojo", true): redPressed = false
	# RASGEO
	if not strumPressed and Input.is_action_pressed("rasgar",true):
		#print_debug("RASGAR")
		var velocity = directions[direction] * speed
		# ANDRES AQUI
		strumPressed = true
		apply_impulse(velocity)
		Global.direccion_jugador = velocity
		Global.sound.play_sfx("carton3", 0.2)
#		Global.sound.play_sfx("step", 0.2)
		#print("MOVE: ", directions[direction])
	elif Input.is_action_just_released("rasgar", true):
		strumPressed = false
		
	var colisiones: Array[Node2D] = get_colliding_bodies();
	if colisiones.size() > 0:
		colision = true
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
	tween2.finished.connect(func(): Global.chocar_npc.emit())
	Global.sound.play_sfx("bounce", 0.2)
	
	pass


func _on_body_entered(body: Node) -> void:
	_rebote();
	pass # Replace with function body.

func _rebote():
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
	Global.sound.play_sfx("bounce", 0.2)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "pensamiento"):
		animator.play("loop")
	pass # Replace with function body.


func _pensamiento_step_sound():
	Global.sound.play_sfx("step", 0.2)
	pass
