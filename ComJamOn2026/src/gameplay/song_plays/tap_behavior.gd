extends NoteBehavior
class_name TapBehavior

## Nota normal: un rasgueo, acorde correcto, dentro de la ventana de tiempo.
## Es la base que reutilizan Hold y Open.

func judge_strum(game, nota: Nota) -> NoteJudgment:
	# Acorde incorrecto => fallo directo.
	if not game.frets_match(nota):
		return NoteJudgment.miss()
	return _judge_timing(game, nota)

## Solo el juicio de TIMING (sin comprobar trastes). Lo reutiliza HoldBehavior
## para el inicio del sostenido, y OpenBehavior tras ignorar los trastes.
func _judge_timing(game, nota: Nota) -> NoteJudgment:
	var diff: float = game.song_time - nota.time
	var abs_diff: float = abs(diff)

	if abs_diff <= game.perfe_time:
		return NoteJudgment.perfect(1.0)
	elif diff >= -game.tiempo_anticipacion and diff <= game.tiempo_retardo:
		return NoteJudgment.good(0.5)
	else:
		return NoteJudgment.miss()
