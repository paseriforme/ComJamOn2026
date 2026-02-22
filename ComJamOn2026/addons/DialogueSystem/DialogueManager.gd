extends Control
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

var dialogue_box : DialogueBox
var decision_box : DecisionBox
@onready var feedback = $Feedback

@export var tween_char_time : float = 1.0
var starting = false
var ending = false

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
	
	$DialogueBox.visible = true
	if starting: return
	starting = true
	var sprite = $DialogueBox/CharacterSprite
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(sprite, "position", Vector2(-1280,-720), tween_char_time).set_trans(Tween.TRANS_BACK)
	_show_node()
	tween2.finished.connect(func(): starting = false)

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
	
	feedback.visible = false
	
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
	else:
		dialogue_box.on_continue = end_dialogue

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
	
	feedback.visible = true
	
	dialogue_box.visible = false
	decision_box.visible = true
	
	for opt in current_node.options:
		var txt = opt.text_key
		decision_box.add_option(txt, func(): choose(opt.next))

func do_action():
	# Mandar la senyal
	match current_node.text_key:
		"negarse":
			print_debug("TE HAS NEGADO")
			Global.negarse.emit()
			pass
		"aceptar":
			print_debug("HAS ACEPTADO")
			Global.aceptar.emit()
			pass
	current_node.text_key
	next_node()

func next_node():
	if current_node.next == -1:
		return
	current_node = current_nodes[current_node.next]
	_show_node()

func end_dialogue():
	var sprite = $DialogueBox/CharacterSprite
	
	if ending: return
	ending = true
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property(sprite, "position", Vector2(-1280,0), tween_char_time).set_trans(Tween.TRANS_BACK)
	_show_node()
	tween2.finished.connect(func():  ending = false )
	await Global.timer(tween_char_time + 0.2)
	Global.end_dialogue.emit()
	

func choose(next_id):
	current_node = current_nodes[next_id]
	feedback.visible = false
	_show_node()
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("verde",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[0].next)
		pass
	if Input.is_action_pressed("rojo",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[1].next)
		pass
	pass
	
	
	
