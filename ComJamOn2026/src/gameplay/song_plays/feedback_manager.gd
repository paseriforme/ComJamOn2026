extends Node
class_name FeedbackManager

@export var guitar_player	: AudioStreamPlayer
@export var animator			: AnimationPlayer
@export var pegatina			: TextureRect
@export var pegatinas 			: Array[Texture2D]

func feedback_hit(quality: int) -> void:
	guitar_player.volume_db = 0
	pegatina.visible = true
	pegatina.texture = pegatinas[quality]
	animator.play("pegar")

func feedback_fail() -> void:
	guitar_player.volume_db = -100000
	#audio_player.stream = load("res://assets/audio/sfx/detuned.wav")
	#audio_player.play()
	pegatina.visible = true
	pegatina.texture = pegatinas[0]
	animator.play("pegar")
