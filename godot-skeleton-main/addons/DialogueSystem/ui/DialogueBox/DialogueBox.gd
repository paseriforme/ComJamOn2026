extends Control

class_name DialogueBox

@onready var label_character = $Panel/LabelCharacter
@onready var label_text = $Panel/LabelText
@onready var continue_btn = $ButtonContinue
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var character_sprite: TextureRect = $CharacterSprite

const CHAVALA = preload("uid://dj02lwf6l4f2e")
const COLEGA = preload("uid://gfqahy7t6mer")
const MUCHACHA = preload("uid://dxsa65o3sqinu")
const TRONCA = preload("uid://dexgxxmnymcwk")
const ICON = preload("uid://dk6ux8aiesioe")

var on_continue: Callable

func _ready():
	hide()
	continue_btn.pressed.connect(_pressed)

func display(text, character, color, font, audio):
	# TWEEN de entrada
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
	match character:
		"Chavala":
			character_sprite.texture = CHAVALA
		"Colega":
			character_sprite.texture = COLEGA
		"Muchacha":
			character_sprite.texture = MUCHACHA
		"Tronca":
			character_sprite.texture = TRONCA
		_:
			character_sprite.texture = ICON
	show()

func _pressed():
	hide()
	if on_continue:
		on_continue.call()
