extends Control
class_name RithmGameManager

@export_group("Referencias a escenas")
@export var audio_player		: AudioStreamPlayer2D
@export var animator			: AnimationPlayer
@export var pegatina			: TextureRect
@export var pegatinas 			: Array[Texture2D]
@export var trastes				: Control
@export var porcentaje_animator	: AnimationPlayer
@export var porcentaje_label	: Label

@export var music_player: AudioStreamPlayer2D
@export var guitar_player: AudioStreamPlayer2D
@export var disco: Disco
const PULSO = preload("uid://dlsillfjnepba")

@export_group("Configuracion de cancion")
@export_subgroup("Dificultad")
@export var spawn_offset: float = 1.5         # en beats
var pulse_time: float = 0.0
@export var tiempo_anticipacion: float = 0.3 	# 300ms antes
@export var tiempo_retardo: float = 0.2			# 200ms despues
@export var perfe_time: float = 0.08			# +-80ms del beat exacto
@export var resync_threshold: float = 0.05		# 50ms: si el audio se desvia mas, recolocamos
@export var pre_roll: float = 1.0   			# segundos que el disco gira antes de sonar la cancion
@export var dificulty: String = "Easy"
@export_subgroup("Visual de pulsos")
@export var rotacion_inicial: float = -180.0
@export var rotacion_final: float = 0.0
@export var scale_pulsos: Vector2 = Vector2(0.66, 0.66)
@export var off_position_pulsos: Vector2 = Vector2(0, 0)

# Cancion activa
var current_song: Song = null

var song_time := 0.0
var _clock := 0.0      # reloj continuo de la cancion (suave, no a saltos)
var spawn_chord := 0   # indice de la proxima nota a spawnear

var enable := false
var ending := false
var rasgar_pressed := false

var calculo: float = 1.0
var notas_acertadas: float = 0.0
var notas_totales: float = 0.0

# --- Sistema de tipos de nota -------------------------------------------------
# Registry: tipo de nota -> behavior (singleton). Para anadir un tipo nuevo,
# crea un NoteBehavior y mete una linea aqui. NADA MAS del bucle cambia.
var _behaviors := {}
var _tap: TapBehavior                  # cache del fallback
var _active: Array[Nota] = []          # notas en curso (holds, etc.)


func _ready() -> void:
	Global.startSong.connect(start_song)

	_tap = TapBehavior.new()
	_behaviors = {
		Nota.Type.TAP:  _tap,
		Nota.Type.HOLD: HoldBehavior.new(),
		Nota.Type.OPEN: OpenBehavior.new(),
	}


## Devuelve el behavior del tipo de la nota; si no hay, cae a TAP.
func behavior_for(nota: Nota) -> NoteBehavior:
	return _behaviors.get(nota.type, _tap)


func _notes() -> Array:
	return current_song.difficulties[dificulty]


func start_song(song: String = "", _dificulty: String = "expert") -> void:
	if song == "" or song not in SongLoader.songs:
		print("Cancion: [", song, "] no es valida")
		return
	Global.sound.bgm.volume_db = -10000
	current_song = SongLoader.songs[song]
	dificulty = _dificulty
	pulse_time = spawn_offset * (60.0 / current_song.bpm)
	disco.set_vel((rotacion_final - rotacion_inicial) / pulse_time)
	spawn_chord = 0

	# porcentaje de perfeccion
	calculo = 1.0
	notas_acertadas = 0.0
	notas_totales = 0.0

	# banderas
	rasgar_pressed = false
	enable = true
	ending = false
	_active.clear()

	# Resetear estado de todas las notas
	for nota: Nota in _notes():
		nota.reset()

	music_player.stream = load(current_song.song_path)
	guitar_player.stream = load(current_song.guitar_path)
	music_player.play()
	guitar_player.play()
	_clock = 0.0
	song_time = 0.0
	print("Cancion: [", song, "] EMPIEZA")


# --- Reloj de cancion ---------------------------------------------------------

## Reloj continuo: corre con delta y solo se recoloca contra el audio si se
## desvia mas de resync_threshold. Mata los brincos de get_playback_position()
## (que causan spawns multiples en un frame) y compensa la latencia de salida.
func _update_clock(delta: float) -> void:
	_clock += delta
	if music_player.is_playing():
		var audio_pos: float = music_player.get_playback_position() \
			+ AudioServer.get_time_since_last_mix() \
			- AudioServer.get_output_latency()
		if audio_pos > 0.0 and abs(audio_pos - _clock) > resync_threshold:
			_clock = audio_pos
	song_time = _clock


# --- Helpers que usan los behaviors (el "contexto") ---------------------------

## Crea el pulso rotatorio estandar. Arranca en el angulo donde DEBERIA estar
## segun el tiempo que queda hasta el golpe, y aterriza exactamente en nota.time,
## a la misma velocidad angular que el disco. Asi una nota que spawnea tarde no
## viaja de mas ni se desincroniza, y varias en el mismo frame se abren en abanico.
func spawn_pulse(nota: Nota) -> void:
	var puls: Tap = PULSO.instantiate()
	puls.set_pulso(nota.chord)
	add_child(puls)
	puls.global_position = global_position + off_position_pulsos
	puls.scale = scale_pulsos

	var lead: float = nota.time - song_time   # tiempo real hasta el golpe
	var progress: float = clamp(1.0 - lead / pulse_time, 0.0, 1.0)
	puls.rotation = deg_to_rad(lerp(rotacion_inicial, rotacion_final, progress))

	var tween = puls.create_tween()
	tween.tween_property(puls, "rotation", deg_to_rad(rotacion_final), max(lead, 0.01))
	tween.finished.connect(func(): puls.queue_free())


## Coinciden los trastes pulsados con el acorde de la nota?
func frets_match(nota: Nota) -> bool:
	for i in Global.trastes.size():
		if nota.chord[i] != Global.trastes[i]:
			return false
	return true


func is_chord_empty(nota: Nota) -> bool:
	for c in nota.chord:
		if c:
			return false
	return true


func add_score(amount: float) -> void:
	notas_acertadas += amount


## Feedback de acierto. quality: 2 = perfecto, 1 = bien.
func feedback_hit(quality: int) -> void:
	guitar_player.volume_db = 0
	pegatina.visible = true
	pegatina.texture = pegatinas[quality]
	animator.play("pegar")


func feedback_fail() -> void:
	print("FALLO")
	guitar_player.volume_db = -100000
	audio_player.stream = load("res://assets/audio/sfx/detuned.wav")
	audio_player.play()
	pegatina.visible = true
	pegatina.texture = pegatinas[0]
	animator.play("pegar")


# --- Juicio de input ----------------------------------------------------------

func get_judgeable_note() -> Nota:
	# Nota PENDING no evaluada mas cercana al tiempo actual dentro de rango.
	var best_note: Nota = null
	var best_diff := 999.0

	for nota: Nota in _notes():
		if nota.state != Nota.State.PENDING:
			continue
		var abs_diff: float = abs(song_time - nota.time)
		if abs_diff <= tiempo_anticipacion and abs_diff < best_diff:
			best_diff = abs_diff
			best_note = nota

	return best_note


func check_input() -> void:
	var nota: Nota = get_judgeable_note()
	if nota == null:
		return

	var judgment: NoteJudgment = behavior_for(nota).judge_strum(self, nota)
	_apply_judgment(nota, judgment)


func _apply_judgment(nota: Nota, j: NoteJudgment) -> void:
	match j.result:
		NoteJudgment.Result.PERFECT:
			nota.hit = true
			add_score(j.score)
			feedback_hit(2)
		NoteJudgment.Result.GOOD:
			nota.hit = true
			add_score(j.score)
			feedback_hit(1)
		_:  # MISS o NONE
			nota.hit = false
			feedback_fail()

	if j.keep_active and j.result != NoteJudgment.Result.MISS:
		nota.state = Nota.State.ACTIVE
		_active.append(nota)
	else:
		_mark_done(nota)


func _mark_done(nota: Nota) -> void:
	nota.state = Nota.State.DONE
	nota.evaluated = true  # compat con codigo viejo que lea evaluated


# --- Bucle --------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if not enable:
		return
	if event.is_action_pressed("rasgar") and not rasgar_pressed:
		rasgar_pressed = true
		check_input()
	if event.is_action_released("rasgar"):
		rasgar_pressed = false


func _process(delta: float) -> void:
	if not enable or ending:
		return

	_update_clock(delta)

	# Spawn de pulsos con antelacion
	while spawn_chord < _notes().size():
		var nota: Nota = _notes()[spawn_chord]
		if song_time >= nota.time - pulse_time:
			behavior_for(nota).spawn_visual(self, nota)
			spawn_chord += 1
		else:
			break

	# Actualizar notas en curso (holds). Iteramos al reves para borrar seguro.
	for i in range(_active.size() - 1, -1, -1):
		var nota: Nota = _active[i]
		if not behavior_for(nota).process(self, nota, delta):
			_active.remove_at(i)
			_mark_done(nota)

	_check_missed_notes()
	_check_song_finished()


func _check_missed_notes() -> void:
	for i in range(spawn_chord):
		var nota: Nota = _notes()[i]
		if nota.state != Nota.State.PENDING:
			continue
		if behavior_for(nota).check_missed(self, nota):
			nota.hit = false
			audio_player.volume_db = -10
			_mark_done(nota)
			feedback_fail()

func _check_song_finished() -> void:
	if spawn_chord < _notes().size():
		return
	for nota: Nota in _notes():
		if nota.state != Nota.State.DONE:
			return
	end()

# --- Fin de cancion -----------------------------------------------------------
func end() -> void:
	if ending:
		return
	Global.sound.bgm.volume_db = 0
	ending = true
	enable = false
	disco.end()
	Global.sound.stop_bgm()
	
	calculo = 0.0
	if _notes().size() > 0:
		calculo = notas_acertadas / _notes().size()
	#print("RESULTADO: ", int(calculo * 100), "%")
	Global.end_song.emit(int(calculo * 100))
