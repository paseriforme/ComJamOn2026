class_name Note
extends RefCounted

## Nota base generica, nace en start_song, muere al acabar la partida
## Envuelve un NoteData inmutable y le anyade el estado que cambia al jugar

enum State { PENDING, ACTIVE, DONE }
## Resultado de procesar una nota viva (hold) en un frame.
enum Tick { SUSTAINING, COMPLETED, BROKEN }

# Config de dificultad unico, (start_song)
static var perfect_window := 0.08
static var early_window   := 0.3
static var late_window    := 0.2

var data	: NoteData
var state	: int = State.PENDING

# Solo lectura
var time: float:
	get: return data.time
var chord: Array:
	get: return data.chord
var duration: float:
	get: return data.duration

static func configure(perfect_time, start_accept_window, end_accept_window):
	perfect_window 	= perfect_time
	early_window 	= start_accept_window
	late_window		= end_accept_window

## Factoria de notas
static func create(d: NoteData) -> Note:
	match d.type:
		NoteData.Type.HOLD: 
			return HoldNote.new(d)
		NoteData.Type.OPEN: 
			return OpenNote.new(d)
		_:                  
			return TapNote.new(d)

func _init(d: NoteData) -> void:
	data = d


# --- Comun
## Devuelve calidad: 0 fallo / 1 good / 2 perfect
func judge_strum(song_time: float, frets: Array) -> int:
	if not _check_chord(frets):
		state = State.DONE
		return 0
	var q := _timing_quality(song_time)
	if q == 0:
		state = State.DONE
		return 0
	_after_hit()
	return q

func _timing_quality(song_time: float) -> int:
	var diff := song_time - time
	if absf(diff) <= perfect_window:
		return 2
	if diff >= -early_window and diff <= late_window:
		return 1
	return 0

func _frets_match(frets: Array) -> bool:
	for i in frets.size():
		if chord[i] != frets[i]:
			return false
	return true


# --- Huecos sobrescribibles
## Solo HoldNote lo aprovecha ahora mismo
func process(_song_time: float, _frets: Array, _delta: float) -> Tick:
	return 0

func is_missed(song_time: float) -> bool:
	return song_time > time + late_window

## Puntuacion del golpe inicial segun calidad
func score_for(quality: int) -> float:
	match quality:
		1: return 0.5
		2: return 1.0
	return 0.0

## Puntuacion extra al completar (solo notas con duracion)
func score_on_complete() -> float:
	return 0.0

func _check_chord(frets: Array) -> bool:
	return _frets_match(frets)

func _after_hit() -> void:
	state = State.DONE # Sobreescribir para notas de mantener
