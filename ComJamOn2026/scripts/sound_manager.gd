extends Node
class_name SoundManager  

@onready var bgm: AudioStreamPlayer2D = $BGM
#@onready var sfx: AudioStreamPlayer2D = $SFX

@export_group("Carpetas a los recursos")
@export_dir var bgm_folder: String = "res://assets/audio/bgm"
@export_dir var sfx_folder: String = "res://assets/audio/sfx"

@export_group("Parámetros de la pool de SFX")
@export var sfx_pool_initial_size := 8
@export var sfx_pool_max_size := 24
var sfx_pool: Array[AudioStreamPlayer2D] = []

@export_group("Parámetros del fundido de BGM")
@export var bgm_fade_time := 0.5
var _bgm_tween: Tween

var bgm_tracks: Dictionary = {}
var sfx_tracks: Dictionary = {}

var current_bgm_name: String = ""
var bgm_volume_db: float = 0.0
var sfx_volume_db: float = 0.0


func _ready() -> void:
	_load_audio()
	_create_sfx_pool()

func _load_audio() -> void:
	bgm_tracks.clear()
	sfx_tracks.clear()

	_load_audio_resources(bgm_folder, bgm_tracks)
	_load_audio_resources(sfx_folder, sfx_tracks)
	
func _load_audio_resources(path: String, target_dict: Dictionary) -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(path)

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
	
	if current_bgm_name == name and bgm.playing:
		return
	
	current_bgm_name = name
	
	if not bgm.playing:
		_set_bgm_stream(name, loop)
		bgm.volume_db = bgm_volume_db
		bgm.play(from_position)
		return
	
	var tween := _fade_bgm(-80.0, bgm_fade_time)
	
	tween.finished.connect(func():
		_set_bgm_stream(name, loop)
		bgm.play(from_position)
		bgm.volume_db = -80.0
		_fade_bgm(bgm_volume_db, bgm_fade_time)
	)
	
@warning_ignore("shadowed_variable_base_class")
func _set_bgm_stream(name: String, loop: bool):
	bgm.stop()
	bgm.stream = bgm_tracks[name]
	
	if bgm.stream is AudioStreamOggVorbis:
		bgm.stream.loop = loop
	elif bgm.stream is AudioStreamWAV:
		bgm.stream.loop_mode = (AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED)

func stop_bgm() -> void:
	if not bgm.playing:
		return
	
	var tween := _fade_bgm(-80.0, bgm_fade_time)
	
	tween.finished.connect(func():
		bgm.stop()
		current_bgm_name = ""
	)


func set_bgm_volume_db(db: float) -> void:
	bgm_volume_db = db
	bgm.volume_db = db



#=== EFECTOS (SFX) ===

@warning_ignore("shadowed_variable_base_class")
func play_sfx(name: String, pitch_variation := 0.0) -> void:
	if not sfx_tracks.has(name):
		push_warning("SFX '%s' no encontrado" % name)
		return
	
	var player := _get_free_sfx_player()
	if player == null:
		return
	
	player.stream = sfx_tracks[name]
	player.volume_db = sfx_volume_db
	
	if pitch_variation > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	else:
		player.pitch_scale = 1.0
	
	player.play()

func set_sfx_volume_db(db: float) -> void:
	sfx_volume_db = db

func _create_sfx_pool():
	for i in sfx_pool_initial_size:
		_add_sfx_player()

func _add_sfx_player() -> AudioStreamPlayer2D:
	var p := AudioStreamPlayer2D.new()
	p.bus = "SFX"
	p.volume_db = sfx_volume_db
	add_child(p)
	sfx_pool.append(p)
	return p
	
func _get_free_sfx_player() -> AudioStreamPlayer2D:
	for p in sfx_pool:
		if not p.playing:
			return p
	
	if sfx_pool.size() < sfx_pool_max_size:
		return _add_sfx_player()
	
	return null
	
func _fade_bgm(to_db: float, duration: float) -> Tween:
	if _bgm_tween and _bgm_tween.is_running():
		_bgm_tween.kill()
	
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(
		bgm,
		"volume_db",
		to_db,
		duration
	)
	
	return _bgm_tween