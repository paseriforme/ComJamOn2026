extends Node
class_name SoundManager  

@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var sfx: AudioStreamPlayer2D = $SFX

@export_dir var bgm_folder: String = "res://assets/audio/bgm"
@export_dir var sfx_folder: String = "res://assets/audio/sfx"

var bgm_tracks: Dictionary = {}
var sfx_tracks: Dictionary = {}

var current_bgm_name: String = ""
var bgm_volume_db: float = 0.0
var sfx_volume_db: float = 0.0


func _ready() -> void:
	_load_audio()


func _load_audio() -> void:
	bgm_tracks.clear()
	sfx_tracks.clear()

	_load_audio_resources(bgm_folder, bgm_tracks)
	_load_audio_resources(sfx_folder, sfx_tracks)
	
func _load_audio_resources(path: String, target_dict: Dictionary) -> void:
	var files = ResourceLoader.list_directory(path)

	for file in files:
		var full_path = path + "/" + file

		if ResourceLoader.exists(full_path, "AudioStream"):
			var key := file.get_basename()
			target_dict[key] = load(full_path)
		else:
			# intentar como subcarpeta
			_load_audio_resources(full_path, target_dict)



#=== MÚSICA (BGM) ===

@warning_ignore("shadowed_variable_base_class")
func play_bgm(name: String, loop: bool = true, from_position: float = 0.0) -> void:
	if not bgm_tracks.has(name):
		push_warning("SoundManager: BGM '%s' no encontrado" % name)
		return

	current_bgm_name = name
	bgm.stop()
	bgm.stream = bgm_tracks[name]
	
	# Ajustar loop
	if bgm.stream is AudioStreamOggVorbis:
		bgm.stream.loop = loop
	elif bgm.stream is AudioStreamWAV:
		bgm.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	bgm.volume_db = bgm_volume_db
	bgm.play(from_position)
#	bgm.play()
#	bgm.seek(from_position)


func stop_bgm() -> void:
	bgm.stop()
	current_bgm_name = ""


func set_bgm_volume_db(db: float) -> void:
	bgm_volume_db = db
	bgm.volume_db = db



#=== EFECTOS (SFX) ===

@warning_ignore("shadowed_variable_base_class")
func play_sfx(name: String, pitch_variation: float = 0.0) -> void:
	if not sfx_tracks.has(name):
		push_warning("SoundManager: SFX '%s' no encontrado" % name)
		return

	sfx.stream = sfx_tracks[name]
	sfx.volume_db = sfx_volume_db

	if pitch_variation > 0.0:
		var base_pitch := 1.0
		var random_delta := randf_range(-pitch_variation, pitch_variation)
		sfx.pitch_scale = base_pitch + random_delta
	else:
		sfx.pitch_scale = 1.0

	sfx.play()


func set_sfx_volume_db(db: float) -> void:
	sfx_volume_db = db
	sfx.volume_db = db
