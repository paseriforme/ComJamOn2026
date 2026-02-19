extends Control

class_name DecisionBox

@onready var question_label = $Panel/LabelQuestion
@onready var label_character = $Panel/LabelCharacter
@onready var options_container = $Panel/OptionsContainer
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

const OPTION_BUTTON = preload("uid://t2vgexpt2fwv")

func display(question, character, color, font, audio):
	if font:
		question_label.add_theme_font_override("normal_font", font)
		# Label y otros Controls usan la clave "font"
		label_character.add_theme_font_override("font", font)
	if audio:
		audio_player.stream = audio
		audio_player.play()
	question_label.text = question
	label_character.modulate = Color(color)
	label_character.text = character
	clear_options()
	show()

func add_option(text, callback: Callable):
	var btn = OPTION_BUTTON.instantiate()
	btn.set_text(text)
	btn.pressed.connect(func():
		hide()
		callback.call()
	)
	options_container.add_child(btn)

func clear_options():
	for c in options_container.get_children():
		c.queue_free()
