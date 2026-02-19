extends CanvasLayer

@onready var player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.on_transition_begin.connect(transition)
	pass

## Iniciar fade in
func transition(speed = 1.0):
	player.play("fade_in", -1, speed)

## Lo que sea que ocurra cuando acaba una animacion
## o sea, justo al acabar ambas partes del fundido 
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in": # la pantalla se acaba de fundir a negro
		Global.on_transition_end.emit() # señal 
		player.play("fade_out") # se inicia el fade out
	elif anim_name == "fade_out": # la pantalla acaba de volver a mostrarse
		pass # no pasa nada
