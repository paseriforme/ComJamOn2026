extends Node
class_name SceneManager

## MUY IMPORTANTE: MISMO ORDEN QUE EN EL SERIALIZED ARRAY DE LA STATEMACHINE
#enum Scenes {SELECTION, CONTEXT, GAME, LIBRE, NULL}

@export_group("Game")
@export var scene_root	: Node
@export var first_scene	: StringName = ""
@export var scenes		: Array[PackedScene] = [] 

@export_group("UI")
@export var pause_layer			: CanvasLayer
@export var transition_layer	: Transition
@export var post_process_layer	: CanvasLayer
@export var debug_layer			: CanvasLayer

@export_group("Audio")
@export var sound	: Node
@export var bgm		: AudioStreamPlayer2D
@export var sfx		: AudioStreamPlayer2D

## Diccionario de escenas para guardarlas con su nombre como id O(1)
var _packed_scenes	: Dictionary
var _next_scene		: StringName = ""
var _actual_scene	: Scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## CONECTAR SEÑALES
	Global.on_transition_end.connect(_on_fade_end)
	Global.on_game_end.connect(_on_game_end)
	
	# Procesado de escenas para guardarlas por su nombre
	for s: PackedScene in scenes:
		# Cogemos el nombre del la packedscene como clave
		var pack_name = s.resource_path.get_file().get_basename()
		_packed_scenes[pack_name] = s
	
	## PRIMER CAMBIO DE ESCENA
	change_scene(first_scene)
	pass 

func _input(event):
	# DEBUG
	var scene:StringName = ""
	if event.is_action_pressed("0"):
		scene = "selection_scene"
	if event.is_action_pressed("1"):
		scene = "context_scene"
	if event.is_action_pressed("2"):
		scene = "game_scene"
	if event.is_action_pressed("escape"):
		get_tree().quit()
	if (scene != ""):
		change_scene(scene)

func change_scene(next : StringName, speed = 1.0):
	_next_scene = next
	#print(">> Changing from ", _actual_scene.name, " to ", _next_scene)
	if (not _actual_scene || _actual_scene.scene_id != next):
		transition_layer.transition(speed)

func _on_fade_end() -> void: #justo antes del fadeout, la idea es que esto sea un switch
	# escena a apagar
	if _actual_scene:
		_actual_scene.on_disable()
		_actual_scene.queue_free()
		_actual_scene = null
	# No existe esa escena
	if not _packed_scenes.has(_next_scene) :
		printerr("[SceneManager] no existe ", _next_scene)
		return;
	# escena a encender
	_actual_scene = _packed_scenes[_next_scene].instantiate()
	_actual_scene.scene_id = _next_scene
	scene_root.add_child(_actual_scene)
	_actual_scene.on_enable()

func _on_game_end():
	pass
