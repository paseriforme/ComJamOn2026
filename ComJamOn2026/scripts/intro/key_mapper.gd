extends Control
class_name key_mapper

var key := -1

var actions := ["verde", "rojo", "amarillo", "azul", "naranja", "rasgar"]
@export var buttons : Array[Node]
@export var loop_animations : Array[Animation]
@export var pegar_animations : Array[Animation]
@onready var animator : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	next_key()

func _input(event: InputEvent) -> void:
	if key >= len(actions): return
	if event.is_pressed():
		InputMap.action_add_event(actions[key], event)
		print(actions[key], event.get_class())
		next_key()

func next_key() -> void:
	if (key > 0):
		print_debug("pegada ", key)
		animator.play(pegar_animations[key].resource_name)
	key += 1
	if (key < len(actions)):
		print_debug("enseñada ", key)
		animator.stop()
		animator.play(loop_animations[key].resource_name)
		buttons[key].visible = true
	
#	for c in range(get_child_count()):
#		if c == key:
#			get_child(c).self_modulate = Color(42.356, 42.356, 42.356, 1.0)
#		else:
#			get_child(c).self_modulate = Color(0.1, 0.1, 0.1, 1)
	
#	if key >= len(actions):
#		Global.change_scene(Global.Scenes.GAME)
