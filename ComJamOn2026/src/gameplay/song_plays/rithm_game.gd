extends Control
class_name RithmGameManager

@export var feedback_manager 	: FeedbackManager
@export var taps_manager		: TapsManager

@export_group("Referencias a escenas")
@export var fondo			: TextureRect
@export var music_player	: AudioStreamPlayer
@export var instrument_player	: AudioStreamPlayer
@export var punto_spawn		: Node2D
@export var disco_parent	: Control
@export var visual_disco	: Disco

@export_group("Configuracion de cancion")
@export_subgroup("Dificultad")
@export var spawn_offset		: float = 1.5
@export var start_accept_window	: float = 0.3
@export var end_accept_window	: float = 0.2
@export var perfect_time			: float = 0.08
@export var resync_threshold	: float = 0.05
@export var time_offset				: float = 1.0

@export_subgroup("Visual de pulsos")
@export var rotacion_inicial: float = -180.0
@export var rotacion_final	: float = 90.0

var pulse_time		: float = 0.0

var _current_song	: Song = null
var _dificulty		: String = "Easy"
var _clock			: SongClock

var spawn_chord := 0

var enable 			:= false
var ending 			:= false

var _active: Array[Note] = []
var _runtime: Array[Note] = []

var calculo: float = 1.0
var notas_acertadas: float = 0.0

func _ready() -> void:
	if music_player and not music_player.finished.is_connected(end):
		music_player.finished.connect(end)

func start_song(song: Song, dificulty: String = "Easy") -> void:
	visible = true
	_current_song = song
	_dificulty = dificulty
	
	if _current_song == null or not _current_song.difficulties.has(_dificulty):
		push_error("FALLO GUARD: song=" + str(_current_song) + " dif=" + str(_dificulty) + " claves=" + str(_current_song.difficulties.keys() if _current_song else []))
		enable = false
		return
	
	pulse_time = spawn_offset * (60.0 / _current_song.bpm)
	visual_disco.set_vel((rotacion_final - rotacion_inicial) / pulse_time)
	spawn_chord = 0
	
	calculo = 1.0
	notas_acertadas = 0.0
	
	enable = true
	ending = false
	
	taps_manager.start_rotation = rotacion_inicial
	taps_manager.end_rotation = rotacion_final
	
	Note.perfect_window = perfect_time
	Note.early_window   = start_accept_window
	Note.late_window    = end_accept_window
	
	_runtime.clear()
	_active.clear()
	for d: NoteData in _current_song.difficulties[_dificulty]:
		_runtime.append(Note.create(d))
	
	music_player.stream = load(_current_song.song_path)
	if _current_song.guitar_path:
		instrument_player.stream = load(_current_song.guitar_path)
	
	_clock = SongClock.new(music_player, instrument_player, resync_threshold)
	_clock.start(time_offset)
	print(">>> start_song: enable=", enable, " clock=", _clock, " notas=", _runtime.size())


# --- Helpers de pulsos --------------------------------------------------------
func spawn_pulse(nota: Note) -> void:
	taps_manager.spawn_pulse(nota, _clock.time if _clock else 0.0, pulse_time)

func add_score(amount: float) -> void:
	notas_acertadas += amount


# --- Juicio de input ----------------------------------------------------------
func get_judgeable_note() -> Note:
	var t := _clock.time
	var best_note: Note = null
	var best_diff := 999.0
	for nota: Note in _runtime:
		if nota.state != Note.State.PENDING:
			continue
		var abs_diff: float = abs(t - nota.time)
		if abs_diff <= start_accept_window and abs_diff < best_diff:
			best_diff = abs_diff
			best_note = nota
	return best_note

func check_input() -> void:
	var nota: Note = get_judgeable_note()
	if nota == null:
		return
	var q := nota.judge_strum(_clock.time if _clock else 0.0, Global.trastes)
	if q == 0:
		feedback_manager.feedback_fail()
		return
	var s := 1.0 if q == 2 else 0.5
	if nota.state == Note.State.ACTIVE:   # se sostiene -> el inicio vale la mitad
		s *= 0.5
		_active.append(nota)
	add_score(s)
	feedback_manager.feedback_hit(q)

func _mark_done(nota: Note) -> void:
	nota.state = Note.State.DONE


# --- Bucle --------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if not enable:
		return
	if _clock == null or _clock.in_preroll():
		return
	if event.is_action_pressed("rasgar"):
		check_input()


func _process(delta: float) -> void:
	#print(">>> process: enable=", enable, " ending=", ending, " clock=", _clock, " time=", song_time)
	if not enable or ending or _clock == null:
		return

	_clock.update(delta)
	# Spawn de pulsos con antelacion
	while spawn_chord < _runtime.size():
		var nota: Note = _runtime[spawn_chord]
		if (_clock.time if _clock else 0.0) >= nota.time - pulse_time:
			spawn_pulse(nota)
			spawn_chord += 1
		else:
			break
	
	if _clock.in_preroll():
		return
		
	for i in range(_active.size() - 1, -1, -1):
		var nota: Note = _active[i]
		match nota.process(_clock.time if _clock else 0.0, Global.trastes, delta):
			1: 
				add_score(0.5); 
				feedback_manager.feedback_hit(2);
				_active.remove_at(i)
			2: 
				feedback_manager.feedback_fail()   
				_active.remove_at(i)
	
	_check_missed_notes()

func _check_missed_notes() -> void:
	for i in range(spawn_chord):
		var nota: Note = _runtime[i]
		if nota.state == Note.State.PENDING and nota.is_missed(_clock.time if _clock else 0.0):
			_mark_done(nota)
			feedback_manager.feedback_fail()

func end() -> void:
	SoundSystem.bgm.volume_db = 0
	ending = true
	enable = false
	SoundSystem.stop_bgm()

	calculo = 0.0
	if _runtime.size() > 0:
		calculo = notas_acertadas / _runtime.size()
	visual_disco.end(int(calculo * 100))
