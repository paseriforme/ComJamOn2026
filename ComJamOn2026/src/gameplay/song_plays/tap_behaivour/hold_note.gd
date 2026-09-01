extends Note
class_name HoldNote
## Nota a mantener

## margen (s) para un parpadeo del acorde sin romper
const GRACE := 0.1
## la otra mitad, se gana sosteniendo hasta el final
const COMPLETE_SCORE := 0.5

var _hold_break := 0.0

## El inicio vale la mitad
func score_for(quality: int) -> float:
	return super(quality) * 0.5
## El resto se gana sosteniendo
func score_on_complete() -> float:
	return COMPLETE_SCORE

## Al acertar el inicio se sostiene en vez de terminar
func _after_hit() -> void:
	state = State.ACTIVE
	_hold_break = 0.0

func process(song_time: float, frets: Array, _delta: float) -> Tick:
	if song_time >= data.time + data.duration:
		state = State.DONE
		return Tick.COMPLETED
	if _frets_match(frets):
		_hold_break = 0.0
		return Tick.SUSTAINING
	_hold_break += _delta
	if _hold_break >= GRACE:
		state = State.DONE
		return Tick.BROKEN
	return Tick.SUSTAINING
