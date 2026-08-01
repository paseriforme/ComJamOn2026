extends Node2D
class_name Pensamiento

@export var control_feedback_time 	: float = 1.0
@export var animator				: AnimationPlayer

var mostrando : bool = false
var control_current_time : float = 0.0

func _ready() -> void:
	control_current_time = control_feedback_time
	animator.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	control_current_time += delta
	
	if (Input.is_anything_pressed()):
		control_current_time = 0.0
		mostrando = false
	
	if control_current_time >= control_feedback_time and not mostrando:
		control_current_time = 0.0
		animator.play("pensamiento")
		mostrando = true
		Global.play_paper(0.1)
		pass

func _on_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "pensamiento"):
		animator.play("loop")
