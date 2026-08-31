extends Note
class_name HoldNote
## Nota a mantener

const GRACE := 0.1

var _hold_break := 0.0

## Al acertar el inicio se sostiene en vez de terminar.
func _after_hit() -> void:
	state = State.ACTIVE
	_hold_break = 0.0

## 0 sigue / 1 completado / 2 roto.
func process(song_time: float, frets: Array, delta: float) -> int:
	if song_time >= data.time + data.duration:
		state = State.DONE
		return 1
	if _frets_match(frets):
		_hold_break = 0.0
	else:
		_hold_break += delta
		if _hold_break >= GRACE:
			state = State.DONE
			return 2
	return 0
