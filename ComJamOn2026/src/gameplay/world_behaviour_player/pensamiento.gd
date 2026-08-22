extends Node2D
class_name Pensamiento

@export var control_feedback_time 	: float = 1.0
@export var animator				: AnimationPlayer

var control_current_time	: float = 0.0

func _ready() -> void:
	control_current_time = control_feedback_time
	animator.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	control_current_time += delta
	
	if _accion_de_juego_pulsada():
		control_current_time = 0.0
		animator.play("despensamiento")
		visible = false
	
	if control_current_time >= control_feedback_time and not visible:
		control_current_time = 0.0
		animator.play("pensamiento")
		visible = true
		Global.play_paper(0.1)

func _accion_de_juego_pulsada() -> bool:
	return (
		Input.is_action_just_pressed("verde")
		or Input.is_action_just_pressed("rojo")
		or Input.is_action_just_pressed("amarillo")
		or Input.is_action_just_pressed("azul")
		or Input.is_action_just_pressed("naranja")
		or Input.is_action_just_pressed("rasgar")
	)

func _on_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "pensamiento"):
		animator.play("loop")

## Llamado por el animator player
func pensamiento_step_sound():
	#Global.play_cardboard(0.2)
	SoundSystem.play_sfx("step", 0.2)
