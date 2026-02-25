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
var trans : bool = false
var ini_map
var somethingpressed = false

var initial_input_map := {}

func _ready() -> void:
	next_key()
	Global.sound.set_bgm_volume_db(7)
	Global.sound.set_sfx_volume_db(7)
#	Global.sound.play_bgm("ambience", true)
	if not OS.is_debug_build(): # si es release queremos que no haya nada mapeado pero en debug si para debugear
		for a in actions:
			InputMap.action_erase_events(a)
	_save_initial_inputmap()

func _input(event: InputEvent) -> void:
#	if key >= len(actions): return
#	print_debug(event)
	if event.is_pressed(): # para html que suene pq en el ready no funciona siempre
		if not Global.sound.bgm.playing:
			Global.sound.play_bgm("ambience")
	var raw_val = Input.get_joy_axis(0, 5)
	if (event.is_pressed() or raw_val != 0.0 and event is InputEventJoypadMotion) and not somethingpressed:
		somethingpressed = true
		if key < len(actions): # estás mapeando
			if not _event_used_before(event): # estas intentando mapear algo ya mapeado
				InputMap.action_add_event(actions[key], event)
				print(actions[key], event.get_class())
				next_key()
			else:
				# TODO: mostrar qué está mapeado a lo que estás pulsando
				pass
		else: # cuando has acabado de mapear, cuales son tus siguientes acciones?
			if event.is_action_pressed("rasgar"):
				_reiniciar()
			elif event.is_action_pressed("verde"):
				_confirmar()
	else:
		somethingpressed = false

func next_key() -> void:
	if (key >= 0):
		animators[key].play("pegar")
		Global.sound.play_sfx("duct_tape1", 0.3)
	key += 1
	if (key < len(actions)): 
		buttons[key].visible = true
		animators[key].play("loop")
	
	if key >= len(actions): # has mapeado la última
		# animar flechas
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(flecha_confirmar, "position", Vector2(-20, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
		Global.play_cardboard(0.2)
		
		var tween3 = get_tree().create_tween()
		tween3.set_ease(Tween.EASE_OUT)
		tween3.tween_property(flecha_reintentar, "position", Vector2(20, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
		Global.play_cardboard(0.2)


func _confirmar():
	print_debug("CONFIRMAR")
	Global.change_scene(Global.Scenes.GAME)
	trans = true
	Global.sound.play_sfx("click", 0.2)
	pass
	
func _reiniciar():
	if trans: return
	for a in actions:
		InputMap.action_erase_events(a)
#		for e in InputMap.action_get_events(a):
#			InputMap.action_erase_event(a, e)
	_restore_initial_inputmap()
	
	key = -1
	for button in buttons:
		button.visible = false
	next_key()
	
	# devolver flechas adónde estaban
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(flecha_confirmar, "position", Vector2(-450.0, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
	Global.play_cardboard(0.2)
	
	var tween3 = get_tree().create_tween()
	tween3.set_ease(Tween.EASE_OUT)
	tween3.tween_property(flecha_reintentar, "position", Vector2(760, 0), 1.0).set_trans(Tween.TRANS_ELASTIC)
	print_debug("REPETIR")
	Global.play_cardboard(0.2)
	pass

func _event_used_before(new_event: InputEvent) -> bool:
	for action in actions:
		for e in InputMap.action_get_events(action):
			if e.is_match(new_event):
				return true
	return false
	
func _save_initial_inputmap():
	initial_input_map.clear()

	for action in actions:
		initial_input_map[action] = []
		for e in InputMap.action_get_events(action):
			initial_input_map[action].append(e.duplicate())
	
func _restore_initial_inputmap():
	for action in actions:
		InputMap.action_erase_events(action)

		for e in initial_input_map[action]:
			InputMap.action_add_event(action, e)