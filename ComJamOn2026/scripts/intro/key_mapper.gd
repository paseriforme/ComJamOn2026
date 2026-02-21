extends HBoxContainer
class_name key_mapper

var key := -1

var actions := ["verde", "rojo", "amarillo", "azul", "naranja", "rasgar"]


func _ready() -> void:
	next_key()

func _input(event: InputEvent) -> void:
	if key >= len(actions): return
	if event.is_pressed():
		InputMap.action_add_event(actions[key], event)
		print(actions[key], event.get_class())
		next_key()

func next_key() -> void:
	key += 1
	for c in range(get_child_count()):
		if c == key:
			get_child(c).self_modulate = Color(42.356, 42.356, 42.356, 1.0)
		else:
			get_child(c).self_modulate = Color(0.1, 0.1, 0.1, 0.5)
	
	if key >= len(actions):
		Global.change_scene(Global.Scenes.GAME)
