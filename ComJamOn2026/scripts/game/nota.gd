class_name Nota
extends Resource

@export var time: float 	#cuando suena
@export var chord: Array 	#array de acorde de global
var hit: bool = false 		# si se ha pulsado
var evaluated: bool = false # si ha sido evaluada

func _init(_time: float, _chord: Array):
	time = _time
	chord = _chord
