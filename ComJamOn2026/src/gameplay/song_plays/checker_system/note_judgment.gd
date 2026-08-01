extends RefCounted
class_name NoteJudgment

## Resultado de juzgar un rasgueo sobre una nota.
## Es un objeto de datos: lo rellena el behavior y lo aplica Game_Guitar.

enum Result { NONE, PERFECT, GOOD, MISS }

var result: int = Result.NONE
var score: float = 0.0          ## cuánto suma al porcentaje (0..1)
var keep_active: bool = false   ## true => la nota pasa a estado ACTIVE (p.ej. holds)

## Constructores cortos para no repetir 3 líneas en cada behavior.
static func perfect(s: float = 1.0) -> NoteJudgment:
	var j := NoteJudgment.new()
	j.result = Result.PERFECT
	j.score = s
	return j

static func good(s: float = 0.5) -> NoteJudgment:
	var j := NoteJudgment.new()
	j.result = Result.GOOD
	j.score = s
	return j

static func miss() -> NoteJudgment:
	var j := NoteJudgment.new()
	j.result = Result.MISS
	return j
