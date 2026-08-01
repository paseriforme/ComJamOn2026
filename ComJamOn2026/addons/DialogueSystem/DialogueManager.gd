extends Control
class_name DialogueManager

const DIALOGUE_BOX = preload("uid://dcenjwoarjpme")
const DECISION_BOX = preload("uid://omqusqkky5ti")

@export_dir var charactersPath	: String
@export_dir var dialoguesPath	: String
@export_dir var audiosPath		: String = "res://assets/audio/" 
@export_dir var fontsPath		: String = "res://assets/font/" 

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
	$Feedback/AnimationPlayer.play("loop")
	
	Global.start_dialogue.connect(start)

func pegar_rojo():
	$Feedback/ARojo.play("pegar")
	Global.sound.play_sfx("duct_tape1", 0.3)
	pass
	
func pegar_verde():
	$Feedback/AVerde.play("pegar")
	Global.sound.play_sfx("duct_tape1", 0.3)
	pass

func start(npc: NPC):
	current_nodes = loader.dialogues[npc.dialogue]
	current_node = _find_start_node()
	
	$DialogueBox.visible = true
	if starting: return
	starting = true
	_show_node()
	
	var sprite1 = $DialogueBox/Triangulo
	var sprite2 = $DialogueBox/Fondo
	var sprite3 = $DialogueBox/CharacterSprite
	var pos : Vector2 = Vector2(-1280,-720)
	# triangulito
	Global.play_cardboard(0.2)
	var tween1 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.tween_property(sprite1, "position", pos, tween_char_time).set_trans(Tween.TRANS_BACK)
	await Global.timer(0.2)
	
	# mensaje
	Global.play_cardboard(0.2)
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(sprite2, "position", pos, tween_char_time * 1.2 ).set_trans(Tween.TRANS_BACK)
	await Global.timer(0.5)
	
	# sprite
	Global.play_paper(0.2)
	var tween3 = get_tree().create_tween()
	tween3.set_ease(Tween.EASE_OUT)
	tween3.tween_property(sprite3, "position", pos, tween_char_time * 1.5).set_trans(Tween.TRANS_BACK)
	
	tween3.finished.connect(func(): starting = false)

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
#			print_debug("TE HAS NEGADO")
			Global.negarse.emit()
			pass
		"aceptar":
#			print_debug("HAS ACEPTADO")
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
	if ending: return
	ending = true
	
	
	
	var sprite3 = $DialogueBox/Triangulo
	var sprite2 = $DialogueBox/Fondo
	var sprite1 = $DialogueBox/CharacterSprite
	var pos : Vector2 =  Vector2(-1280,400)
	_show_node()

#	var tween2 = get_tree().create_tween()
#	tween2.set_ease(Tween.EASE_IN)
#	tween2.tween_property(sprite1, "position", pos, tween_char_time).set_trans(Tween.TRANS_BACK)
#	tween2.finished.connect(func():  ending = false; Global.end_dialogue.emit())
	
	# sprite
	Global.play_paper(0.2)
	var tween1 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_IN)
	tween1.tween_property(sprite1, "position", pos, tween_char_time).set_trans(Tween.TRANS_BACK)
	await Global.timer(0.5)
#	
#	# mensaje
	Global.play_cardboard(0.2)	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property(sprite2, "position", pos, tween_char_time * 1.2 ).set_trans(Tween.TRANS_BACK)
	await Global.timer(0.2)
#	
#	# triangulito
	Global.play_cardboard(0.2)
	var tween3 = get_tree().create_tween()
	tween3.set_ease(Tween.EASE_IN)
	tween3.tween_property(sprite3, "position", pos, tween_char_time * 1.5).set_trans(Tween.TRANS_BACK)
	
	tween3.finished.connect(func():  ending = false; Global.end_dialogue.emit())
	

func choose(next_id):
	current_node = current_nodes[next_id]
	feedback.visible = false
	_show_node()
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("verde",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[0].next)
		Global.sound.play_sfx("click", 0.5)
#		pegar_verde()
		pass
	if Input.is_action_pressed("rojo",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[1].next)
		Global.sound.play_sfx("click", 0.5)
#		pegar_rojo()
		pass
	pass
	
	
	
