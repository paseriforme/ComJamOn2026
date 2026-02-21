extends RigidBody2D
class_name NPC

enum NPC_type {COLEGA, MUCHACHA, TRONCA, CHAVALA, MANAGER}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var canvas_layer: UI = $"../CanvasLayer"
@export var TEXTURE := preload("uid://dk6ux8aiesioe")
@export var selfNPC : NPC_type = NPC_type.MANAGER
@export var startDialogue : int = 0
@onready var gameState: GameState = $".."

var inipos: Vector2 
@export var distance_factor : float = 0.05
@export var tween_time : float = 0.5

func _ready() -> void:
	Global.chocar_npc.connect(_iniciar_dialogo);
	inipos = $Sprite2D.position
	sprite_2d.texture = TEXTURE

func _on_body_entered(body: Node) -> void:
#	if body.linear_velocity != Vector2.ZERO:
#		var velocity = body.linear_velocity
#		print_debug(velocity)
#		velocity = velocity * -1
	var velocity: Vector2 = Global.direccion_jugador
	var trans : Tween.TransitionType = Tween.TRANS_SINE
	var tween2: Tween = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property($Sprite2D, "position", inipos + velocity * distance_factor, tween_time/2).set_trans(trans)
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property($Sprite2D, "position", inipos, tween_time/2).set_trans(trans)
	Global.npc_chocado = true
	pass
#	var newpos = ((position - body.position) * body.speed)
#	body.apply_impulse(newpos)
#	print("CHOQUE", newpos)

func _iniciar_dialogo():
	if Global.npc_chocado: 
		gameState.set_state(GameState.states.TALK)
		canvas_layer.show_dialogue(startDialogue)	
	pass