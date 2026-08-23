extends RigidBody2D
class_name WorldPlayerController

@export var speed : float = 10
@export var sprite_directions 	: Array[Texture2D] 

# N, NE, E, SE, S, SW, W, NW NOOOO
# S SW W NW N NE E SE
var directions	:= [Vector2(0,1), Vector2(0.75,0.75),Vector2(1,0), 
					Vector2(0.75,-0.75),Vector2(0,-1), Vector2(-0.75,-0.75),
					Vector2(-1,0), Vector2(-0.75,0.75)]
var direction 	:= 0

# flags
var canwalk 	:= true

var init_scale;
var factor_spr_scale 	:= Vector2(0.2, 0.2)
var trans_scale 		:= Tween.TRANS_QUAD

var time_steps			: float = 0.3
var factor_steps		: float = -0.075
var ease_steps			: int = Tween.EASE_OUT
var trans_steps			: int = Tween.TRANS_CUBIC

var factor_spr_scale_2 	: float = 0.5
var time_steps_2 		: float = 0.75
var factor_steps_2 		: float = 0.75

func _ready() -> void:
	init_scale = $Sprite2D.scale
	body_entered.connect(_rebote)

func _physics_process(delta: float) -> void:
	if not canwalk: return
	
	# VERDE
	if Input.is_action_just_pressed("verde", true):
		#print("TURN LEFT")
		direction = (direction +1) % len(directions)
		$Sprite2D.texture = sprite_directions[direction]
		Global.play_paper(0.2)
	# ROJO
	if Input.is_action_just_pressed("rojo", true):
		#print("TURN RIGHT")
		direction = (direction -1) % len(directions)
		$Sprite2D.texture = sprite_directions[direction]
		Global.play_paper(0.2)
	# RASGEO
	if Input.is_action_just_pressed("rasgar",true):
		#print_debug("RASGAR")
		var velocity = directions[direction] * speed
		apply_impulse(velocity)
		Global.direccion_jugador = velocity
		SoundSystem.play_sfx("carton3", 0.2)
#		SoundSystem.play_sfx("step", 0.2)
		#print("MOVE: ", directions[direction])

func _callback_XD():
	var velocity = directions[direction] * speed
	velocity *= -0.5
	apply_impulse(velocity)
	
	# second
	var time = time_steps * time_steps_2
	# second scale
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", init_scale + factor_spr_scale * factor_spr_scale_2, time/2).set_trans(trans_scale)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "scale", init_scale, time/2).set_trans(trans_scale)
	#tween.finished.connect(func(): Global.chocar_npc.emit())
	SoundSystem.play_sfx("bounce", 0.2)

func _rebote(body: Node) -> void:
	#version por física
	var velocity = directions[direction] * speed
	velocity *= -0.5
	apply_impulse(velocity)
	
	#escalado
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", init_scale + factor_spr_scale, time_steps/2).set_trans(trans_scale)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "scale", init_scale, time_steps/2).set_trans(trans_scale)
	tween.finished.connect(_callback_XD)
	
	SoundSystem.play_sfx("bounce", 0.2)
