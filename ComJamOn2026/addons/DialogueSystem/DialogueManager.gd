extends Control
class_name DialogueManager

const DIALOGUE_BOX = preload("uid://dcenjwoarjpme")
const DECISION_BOX = preload("uid://omqusqkky5ti")

@export_file var charactersPath	: String
@export_file var dialoguesPath	: String
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
	set_process(false)

func pegar_rojo():
	$Feedback/ARojo.play("pegar")
	Global.sound.play_sfx("duct_tape1", 0.3)
	pass
	
func pegar_verde():
	$Feedback/AVerde.play("pegar")
	Global.sound.play_sfx("duct_tape1", 0.3)
	pass

func start_dialogue(npc: NPC):
	if starting: return
	starting = true
	set_process(true)
	
	visible = true
	current_nodes = loader.dialogues[npc.dialogue]
	current_node = _find_start_node()
	$DialogueBox.visible = true
	_show_node() 
	
	var pasos := [
		{ "sprite": $DialogueBox/Triangulo,      "sonido": "cardboard", "espera": 0.2 },
		{ "sprite": $DialogueBox/Fondo,          "sonido": "cardboard", "espera": 0.5 },
		{ "sprite": $DialogueBox/CharacterSprite,"sonido": "paper",     "espera": 0.0 },
	]
	_dialogue_animation(Vector2(-1280, -720), Tween.EASE_OUT, pasos, func(): starting = false)


func end_dialogue():
	if ending: return
	ending = true
	set_process(false)
	
	var pasos := [
		{ "sprite": $DialogueBox/CharacterSprite,"sonido": "paper",     "espera": 0.5 },
		{ "sprite": $DialogueBox/Fondo,          "sonido": "cardboard", "espera": 0.2 },
		{ "sprite": $DialogueBox/Triangulo,      "sonido": "cardboard", "espera": 0.0 },
	]
	_dialogue_animation(Vector2(-1280, 400), Tween.EASE_IN, pasos, func():
		ending = false
		Global.end_dialogue.emit())

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

func _dialogue_animation(pos: Vector2, ease: Tween.EaseType, steps: Array, at_end: Callable) -> void:
	var factores := [1.0, 1.2, 1.5]
	var ultimo: Tween
	
	for i in steps.size():
		var step: Dictionary = steps[i]
		
		if step["sonido"] == "cardboard":
			Global.play_cardboard(0.2)
		else:
			Global.play_paper(0.2)
		
		ultimo = get_tree().create_tween()
		ultimo.set_ease(ease)
		ultimo.tween_property(step["sprite"], "position", pos, tween_char_time * factores[i]) \
			.set_trans(Tween.TRANS_BACK)
		
		if step["espera"] > 0.0:
			await Global.timer(step["espera"])
	ultimo.finished.connect(at_end)

func choose(next_id):
	current_node = current_nodes[next_id]
	feedback.visible = false
	_show_node()

func _process(delta: float) -> void:
	if Input.is_action_pressed("verde",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[0].next)
		SoundSystem.play_sfx("click", 0.5)
#		pegar_verde()
	if Input.is_action_pressed("rojo",true) and decision_box.visible and not dialogue_box.visible:
		choose(current_node.options[1].next)
		SoundSystem.play_sfx("click", 0.5)
#		pegar_rojo()
	if Input.is_action_just_pressed("rasgar",true) and dialogue_box.visible and not ending and not starting:
		SoundSystem.play_sfx("click", 0.2)
		dialogue_box.pressed()
