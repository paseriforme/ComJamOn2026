extends Node
class_name DialogueManager

const DIALOGUE_BOX = preload("uid://dcenjwoarjpme")
const DECISION_BOX = preload("uid://omqusqkky5ti")

@export var charactersPath: String
@export var dialoguesPath: String
@export var audiosPath: String = "res://assets/audio/" 
@export var fontsPath: String = "res://assets/font/" 

var loader:= DialogueLoader.new()
var current_nodes
var current_node
var language = "es"

var dialogue_box
var decision_box

func _ready() -> void:
	dialogue_box = DIALOGUE_BOX.instantiate()
	self.add_child(dialogue_box)
	decision_box = DECISION_BOX.instantiate()
	self.add_child(decision_box)
	
	loader.load_all(charactersPath, dialoguesPath)
	#Descomentar para probar
	#start(0)

func start(dialogue_id):
	current_nodes = loader.dialogues[dialogue_id]
	current_node = _find_start_node()
	_show_node()

func _find_start_node():
	for n in current_nodes.values():
		if n.type == "START":
			return n

func _show_node():
	match current_node.type:
		"START", "DIALOGUE":
			show_dialogue()
		"DECISION":
			show_decision()
		"ACTION":
			do_action()
		"END":
			show_dialogue(true)

func _load_font(font_name: String) -> Font:
	if font_name == "" or font_name == "Sin fuente":
		return null

	var path := fontsPath + font_name
	if not ResourceLoader.exists(path):
		push_warning("Fuente no encontrada: " + path)
		return null

	return ResourceLoader.load(path) as Font

func _load_audio(audio_name: String):
	if not audio_name or audio_name == "" or audio_name == "Sin audio":  
		return null  
	var path := audiosPath + audio_name
	return ResourceLoader.load(path)

func show_dialogue(is_end := false):
	var text = current_node.text_key
	var character = loader.characters[current_node.character]
	var font = _load_font(character.get("font"))
	var audio = _load_audio(character.get("sound"))
	
	dialogue_box.visible = true
	decision_box.visible = false
	
	dialogue_box.display(
		text,
		current_node.character,
		character.Color,
		font,
		audio
	)
	if not is_end:
		dialogue_box.on_continue = next_node

func show_decision():
	var question = current_node.text_key
	var character = loader.characters[current_node.character]
	var font = _load_font(character.get("font"))
	var audio = _load_audio(character.get("sound"))
	
	decision_box.display(
		question,
		current_node.character,
		character.Color,
		font,
		audio
	)
	
	dialogue_box.visible = false
	decision_box.visible = true
	
	for opt in current_node.options:
		var txt = opt.text_key
		decision_box.add_option(txt, func(): choose(opt.next))

func do_action():
	# Mandar la senyal
	current_node.text_key
	pass

func next_node():
	if current_node.next == -1:
		return
	current_node = current_nodes[current_node.next]
	_show_node()

func choose(next_id):
	current_node = current_nodes[next_id]
	_show_node()
