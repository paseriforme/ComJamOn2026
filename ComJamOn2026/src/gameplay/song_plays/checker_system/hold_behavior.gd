extends TapBehavior
class_name HoldBehavior

## Nota larga: se juzga el INICIO como un tap (mitad de la puntuación) y la otra
## mitad se gana manteniendo el acorde correcto hasta nota.time + nota.duration.
## El sostenido se mantiene con los TRASTES, no volviendo a rasgar (estándar en
## juegos de guitarra). Si quisieras exigir mantener rasgar, añade en process()
## un `and game.rasgar_pressed`.

const COMPLETE_SCORE := 0.5   ## puntuación al completar el sostenido
const GRACE := 0.1            ## margen (s) para un parpadeo del acorde sin romper

func spawn_visual(game, nota: Nota) -> void:
	# TODO: cola/arco para el sostenido. De momento reutiliza el pulso normal.
	game.spawn_pulse(nota)

func judge_strum(game, nota: Nota) -> NoteJudgment:
	# Reutiliza el juicio de timing del tap, pero comprobando antes el acorde.
	if not game.frets_match(nota):
		return NoteJudgment.miss()

	var j: NoteJudgment = _judge_timing(game, nota)
	if j.result == NoteJudgment.Result.MISS:
		return j

	# Acierto de inicio: vale la mitad; el resto se gana sosteniendo.
	j.score *= 0.5
	j.keep_active = true
	nota.hold_break = 0.0
	return j

func process(game, nota: Nota, delta: float) -> bool:
	# ¿Llegó al final? Sostenido completado.
	if game.song_time >= nota.time + nota.duration:
		game.add_score(COMPLETE_SCORE)
		game.feedback_hit(2)
		return false

	# ¿Sigue manteniendo el acorde?
	if game.frets_match(nota):
		nota.hold_break = 0.0
		game.guitar_player.volume_db = 0
	else:
		nota.hold_break += delta
		if nota.hold_break >= GRACE:
			game.feedback_fail()
			return false  # roto antes de tiempo

	return true
