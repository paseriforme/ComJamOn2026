extends RigidBody2D
class_name NPC

enum NPC_type {COLEGA, MUCHACHA, TRONCA, CHAVALA, MANAGER}

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var selfNPC : NPC_type = NPC_type.MANAGER
@export var TEXTURE := preload("uid://dk6ux8aiesioe")

func _ready() -> void:
	#Sprite2D.Texture = TEXTURE
	pass

func _on_body_entered(body: Node) -> void:
	var newpos = ((position - body.position) * body.speed)
	body.apply_impulse(newpos)
	print("CHOQUE", newpos)
