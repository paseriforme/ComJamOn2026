extends Control

class_name DialogueBox

@onready var label_character = $Panel/LabelCharacter
@onready var label_text = $Panel/LabelText
@onready var continue_btn = $ButtonContinue
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

var on_continue: Callable

func _ready():
	hide()
	continue_btn.pressed.connect(_pressed)

func display(text, character, color, font, audio):
	if font:
		label_text.add_theme_font_override("normal_font", font)
		# Label y otros Controls usan la clave "font"
		label_character.add_theme_font_override("font", font)
	if audio:
		audio_player.stream = audio
		audio_player.play()
	label_text.text = text
	label_character.modulate = Color(color)
	label_character.text = character
	show()

func _pressed():
	hide()
	if on_continue:
		on_continue.call()
