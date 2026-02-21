extends RigidBody2D
class_name NPC

enum NPC_type {COLEGA, MUCHACHA, TRONCA, CHAVALA, MANAGER}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var canvas_layer: UI = $"../CanvasLayer"
@export var TEXTURE := preload("uid://dk6ux8aiesioe")
@export var selfNPC : NPC_type = NPC_type.MANAGER
@export var startDialogue : int = 0
@onready var gameState: GameState = $".."

func _ready() -> void:
	sprite_2d.texture = TEXTURE

func _on_body_entered(body: Node) -> void:
	gameState.set_state(GameState.states.TALK)
	var newpos = ((position - body.position) * body.speed)
	body.apply_impulse(newpos)
	print("CHOQUE", newpos)
	canvas_layer.show_dialogue(startDialogue)
