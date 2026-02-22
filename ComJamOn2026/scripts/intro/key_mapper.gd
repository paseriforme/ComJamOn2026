extends Control
class_name key_mapper

var key := -1

var actions := ["verde", "rojo", "amarillo", "azul", "naranja", "rasgar"]
@export var buttons : Array[Node]
@export var loop_animations : Array[Animation]
@export var pegar_animations : Array[Animation]
@onready var animator : AnimationPlayer = $AnimationPlayer
@export var animators : Array[AnimationPlayer]
@onready var flecha_confirmar : TextureRect = $Confirmar
@onready var flecha_reintentar : TextureRect = $Reintentar

var somethingpressed = false
func _ready() -> void:
	next_key()

func _input(event: InputEvent) -> void:
#	if key >= len(actions): return
	if Input.is_anything_pressed() and not somethingpressed:
		somethingpressed = true
		if key < len(actions):
			InputMap.action_add_event(actions[key], event)
			print(actions[key], event.get_class())
			next_key()
		else:
			if event.is_action_pressed("rasgar"):
				_reiniciar()
			elif event.is_action_pressed("verde"):
				_confirmar()
	else:
		somethingpressed = false

func next_key() -> void:
	if (key >= 0):
		animators[key].play("pegar")
	key += 1
	if (key < len(actions)):
		buttons[key].visible = true
		animators[key].play("loop")
	
	if key >= len(actions):
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(flecha_confirmar, "position", Vector2(-20, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
		
		var tween3 = get_tree().create_tween()
		tween3.set_ease(Tween.EASE_OUT)
		tween3.tween_property(flecha_reintentar, "position", Vector2(20, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
	
#	for c in range(get_child_count()):
#		if c == key:
#			get_child(c).self_modulate = Color(42.356, 42.356, 42.356, 1.0)
#		else:
#			get_child(c).self_modulate = Color(0.1, 0.1, 0.1, 1)
	
#	if key >= len(actions):
#		Global.change_scene(Global.Scenes.GAME)


func _confirmar():
	print_debug("CONFIRMAR")
	pass
	
func _reiniciar():
	print_debug("REPETIR")
	pass