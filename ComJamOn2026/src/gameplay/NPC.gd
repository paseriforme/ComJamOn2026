extends RigidBody2D
class_name NPC

enum NPC_type {COLEGA, MUCHACHA, TRONCA, CHAVALA, MANAGER}

@export_group("Visual")
@export var TEXTURE 		:= preload("uid://dk6ux8aiesioe")
@export var selfNPC 		: NPC_type = NPC_type.MANAGER
@export var dialogue		: int = 0
@export var distance_factor : float = 0.05
@export var tween_time 		: float = 0.5

@export_group("Referencias")
#@export var gameState		: GameState
@export var sprite_2d		: Sprite2D
@export var audio_player	: AudioStreamPlayer2D

@export_group("Juego")
@export var song : Song

var _sprite_ini_pos: Vector2 

func _ready() -> void:
	_sprite_ini_pos = sprite_2d.position
	sprite_2d.texture = TEXTURE

func _on_body_entered(body: Node) -> void:
	var dir: Vector2 = Global.direccion_jugador
	var trans : Tween.TransitionType = Tween.TRANS_SINE
	var tween2: Tween = get_tree().create_tween()
	SoundSystem.play_sfx("bounce", 0.2)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(sprite_2d, "position", _sprite_ini_pos + dir * distance_factor, tween_time/2).set_trans(trans)
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property(sprite_2d, "position", _sprite_ini_pos, tween_time/2).set_trans(trans)
	Global.start_dialogue.emit(self)
	pass
#
#func _iniciar_dialogo():
	#gameState.ini = firstChord
	#gameState.fin = lastChord
	#if Global.npc_chocado and Global.npc_chocado == self: 
		#gameState.set_state(GameState.states.TALK)
		#print("START DIALOGUE: ", startDialogue)
		#if selfNPC == NPC_type.MANAGER:
			#Global.cancion = "Voces"
			#$"../CanvasLayer/Panel/Fondo".texture = preload("uid://dkjqyqi73dt1o")
		#else:
			#Global.cancion = "Instrumental"
			#$"../CanvasLayer/Panel/Fondo".texture = preload("uid://n0ob011ts0le")
	#pass
