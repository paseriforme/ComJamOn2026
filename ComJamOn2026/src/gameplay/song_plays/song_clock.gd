class_name SongClock
extends RefCounted

# El manager lo tickea a mano (clock.update(delta)) para garantizar el orden:
# primero avanza el reloj, luego el manager lee clock.time. Nada de _process propio.

var time: float = 0.0            # tiempo de canción; arranca negativo (pre-roll)
var audio_started: bool = false

var _music: AudioStreamPlayer
var _guitar: AudioStreamPlayer
var _resync_threshold: float

func _init(music: AudioStreamPlayer, guitar: AudioStreamPlayer, resync_threshold: float) -> void:
	_music = music
	_guitar = guitar
	_resync_threshold = resync_threshold

## Arranca el reloj en -offset. El audio NO suena aún: se dispara al cruzar 0.
func start(offset: float) -> void:
	time = -offset
	audio_started = false

func update(delta: float) -> void:
	time += delta

	# cruce por cero: dispara el audio una sola vez
	if time >= 0.0 and not audio_started:
		audio_started = true
		print(">>> AUDIO ARRANCA, music=", _music, " stream=", _music.stream)
		_music.play()
		_guitar.play()

	# resync contra el audio real, solo cuando ya suena
	if _music.is_playing():
		var audio_pos: float = _music.get_playback_position() \
			+ AudioServer.get_time_since_last_mix() \
			- AudioServer.get_output_latency()
		if audio_pos > 0.0 and abs(audio_pos - time) > _resync_threshold:
			time = audio_pos

## True mientras estamos en el pre-roll (reloj negativo, canción aún no empezó).
func in_preroll() -> bool:
	return time < 0.0
