extends TapBehavior
class_name OpenBehavior

## Nota abierta: cuenta cualquier rasgueo dentro de la ventana, SIN importar qué
## trastes pulse el jugador. Sirve de ejemplo de lo fácil que es un tipo nuevo:
## solo se sobreescribe judge_strum para saltarse la comprobación de acorde.

func judge_strum(game, nota: Nota) -> NoteJudgment:
	# Ignora los trastes: solo importa el timing.
	return _judge_timing(game, nota)
