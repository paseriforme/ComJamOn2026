extends Control
class_name RithmGameManager

@export var feedback_manager 	: FeedbackManager
@export var taps_manager		: TapsManager

@export_group("Referencias a escenas")
@export var music_player		: AudioStreamPlayer
@export var instrument_player	: AudioStreamPlayer
@export var visual_disco		: Disco

@export_group("Configuracion de cancion")
@export_subgroup("Dificultad")
## Offset de tiempo con el que spawnea una nota (beats) esto universaliza para canciones con diferentes BPM
@export var spawn_offset_beats		: float = 1.5
## Diferencia maxima que puede haber entre audio y visuales para resincronizar
@export var resync_threshold	: float = 0.05
## Offset de tiempo con el que empieza una cancion
@export var time_offset			: float = 1.0
## Inicio de la ventana de tiempo que acepta el acorde como valido
@export var start_accept_window	: float = 0.3
## Final de la ventana de tiempo que acepta el acorde como valido
@export var end_accept_window	: float = 0.2
## Margen de tiempo que considera un acorde como perfecto
@export var perfect_time		: float = 0.08

@export_subgroup("Visual de pulsos")
@export var start_tap_angle	: float = -90.0
@export var end_tap_angle	: float = 90.0

## Verdad absoluta del tiempo de la cancion
var _clock			: SongClock
## Getter del tiempo actual
var _time: float:
	get: return _clock.time if _clock else 0.0

## Cuanto tiempo antes tiene que spawnear una nota (segundos)
var _spawn_offset_seconds		: float = 0.0
## Siguiente tap a spawnear
var _next_tap 		:= 0
## Numero de taps correctos
var _correct_taps	: float = 0.0

## Flags de control
var _enable := false
var _ending := false

## Taps de la cancion
var _runtime: Array[Note] = []
## Taps de mantener pulsado
var _active: Array[Note] = []


func _ready() -> void:
	if music_player and not music_player.finished.is_connected(_end_song):
		music_player.finished.connect(_end_song)

func _input(event: InputEvent) -> void:
	if not _enable:
		return
	if _clock == null or _clock.in_preroll():
		return
	if event.is_action_pressed("rasgar"):
		_check_input()

func _process(delta: float) -> void:
	#print(">>> process: _enable=", _enable, " _ending=", _ending, " clock=", _clock, " time=", song_time)
	if not _enable or _ending or _clock == null:
		return

	_clock.update(delta)
	
	# Cacheo de time
	var t := _time
	
	# Spawn de pulsos con antelacion,
	# puede haber canciones en las que queramos que se vea antes de que empiece la musica,
	# por eso se hace antes del preroll
	while _next_tap < _runtime.size():
		var nota: Note = _runtime[_next_tap]
		if (t) >= nota.time - _spawn_offset_seconds:
			_spawn_pulse(nota)
			_next_tap += 1
		else:
			break
	
	# Preroll es el offset antes de que empiece la cancion
	if _clock.in_preroll():
		return
	
	# mantiene vivas las notas de mantener
	for i in range(_active.size() - 1, -1, -1):
		var nota: Note = _active[i]
		match nota.process(t, Global.trastes, delta):
			Note.Tick.COMPLETED:
				_add_score(nota.score_on_complete())
				feedback_manager.feedback_hit(2)
				_active.remove_at(i)
			Note.Tick.BROKEN:
				feedback_manager.feedback_fail()
				_active.remove_at(i)
			# SUSTAINING: sigue viva, no se toca
	
	_check_missed_notes()


# --- PRIVATE 
func _check_input() -> void:
	var nota: Note = _get_judgeable_note()
	if nota == null:
		return
	var q := nota.judge_strum(_time, Global.trastes)
	if q == 0:
		feedback_manager.feedback_fail()
		return
	_add_score(nota.score_for(q))
	if nota.state == Note.State.ACTIVE:
		_active.append(nota)
	feedback_manager.feedback_hit(q)

func _check_missed_notes() -> void:
	for i in range(_next_tap):
		var nota: Note = _runtime[i]
		if nota.state == Note.State.PENDING and nota.is_missed(_time):
			_mark_done(nota)
			feedback_manager.feedback_fail()

func _end_song() -> void:
	SoundSystem.bgm.volume_db = 0
	_ending = true
	_enable = false
	SoundSystem.stop_bgm()
	
	var calculo = 0.0
	if _runtime.size() > 0:
		calculo = _correct_taps / _runtime.size()
	visual_disco.end(int(calculo * 100))
	print(int(calculo * 100), " %")


# --- PUBLIC
func start_song(song: Song, dificulty: String = "Easy") -> void:
	visible = true
	
	if song == null or not song.difficulties.has(dificulty):
		push_error("FALLO GUARD: song=" + str(song) + " dif=" + str(dificulty) + " claves=" + str(song.difficulties.keys() if song else []))
		_enable = false
		return
	
	_spawn_offset_seconds = spawn_offset_beats * (60.0 / song.bpm)
	visual_disco.set_vel((end_tap_angle - start_tap_angle) / _spawn_offset_seconds)
	_next_tap = 0
	
	_correct_taps = 0.0
	
	_enable = true
	_ending = false
	
	taps_manager.start_rotation = start_tap_angle
	taps_manager.end_rotation = end_tap_angle
	
	# configuracion estatica para todas las notas
	Note.configure(perfect_time, start_accept_window, end_accept_window)
	_runtime.clear()
	_active.clear()
	for d: NoteData in song.difficulties[dificulty]:
		_runtime.append(Note.create(d))
	
	music_player.stream = load(song.song_path)
	if song.guitar_path:
		instrument_player.stream = load(song.guitar_path)
	else: instrument_player.stream = null
	
	_clock = SongClock.new(music_player, instrument_player, resync_threshold)
	_clock.start(time_offset)
	print(">>> start_song: _enable=", _enable, " clock=", _clock, " notas=", _runtime.size())


# --- Helpers
func _spawn_pulse(nota: Note) -> void:
	taps_manager.spawn_pulse(nota, _time, _spawn_offset_seconds)

func _add_score(amount: float) -> void:
	_correct_taps += amount

## Busca la nota mas cercana al tiempo que llevamos de cancion para juzgarla (la siguiente en la lista)
func _get_judgeable_note() -> Note:
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

func _mark_done(nota: Note) -> void:
	nota.state = Note.State.DONE
