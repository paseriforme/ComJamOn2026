class_name Nota
extends Resource

enum Type  { TAP, HOLD, OPEN }
enum State { PENDING, ACTIVE, DONE }

@export var time: float 	#cuando suena
@export var chord: Array 	# array de acorde de bools
@export var type: Type = Type.TAP
@export var duration: float = 0.0   # segundos; solo lo usan los holds

var state: State = State.PENDING
var hold_break: float = 0.0         # timer interno del sostenido

var hit: bool = false 		# si se ha pulsado
var evaluated: bool = false # si ha sido evaluada

func _init(_time: float, _chord: Array):
	time = _time
	chord = _chord


func reset() -> void:
	state = State.PENDING
	hit = false
	evaluated = false
	hold_break = 0.0
