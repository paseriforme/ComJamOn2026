extends RefCounted
class_name NoteBehavior

## Estrategia de un TIPO de nota. Es un SINGLETON sin estado:
## se crea una instancia por tipo y se comparte entre todas las notas de ese tipo.
## Todo el estado mutable (timers, flags) vive en la propia Nota.
##
## El parámetro `game` es el Game_Guitar y actúa de "contexto": expone los pocos
## helpers que un behavior necesita (song_time, ventanas, frets_match, spawn_pulse,
## feedback_*, add_score...). Es el ÚNICO punto de acoplamiento con la escena.
##
## Para añadir un tipo de nota nuevo: heredar de esta clase, sobreescribir lo que
## cambie, y registrarlo en Game_Guitar._behaviors. El bucle del juego no se toca.

## Crea el/los visuales de la nota cuando le toca aparecer.
func spawn_visual(game, nota: Nota) -> void:
	game.spawn_pulse(nota)

## Se llama cuando el jugador rasguea y ESTA nota es la juzgable.
## Devuelve un NoteJudgment. Por defecto: no hace nada.
func judge_strum(game, nota: Nota) -> NoteJudgment:
	return NoteJudgment.new()

## Se llama cada frame mientras la nota está en estado ACTIVE (p.ej. holds).
## Devuelve true si sigue activa, false si terminó (el juego la marca DONE).
func process(game, nota: Nota, _delta: float) -> bool:
	return false

## ¿Esta nota (aún PENDING) se considera perdida en este instante?
func check_missed(game, nota: Nota) -> bool:
	return game.song_time > nota.time + game.tiempo_retardo
