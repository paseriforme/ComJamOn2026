extends Control
class_name TelonManager

@export var telon_izq 		: Control
@export var telon_der 		: Control
@export var porcentaje 		: Control
@export var porcentaje_label: Label
@export var animPlayer 		: AnimationPlayer

var _enable = false

func _ready() -> void:
	Global.play_telon.connect(_play_teon)

func _play_teon(percent : int):
	_enable = true
	visible = true
	porcentaje.visible = true
	porcentaje_label.text = str(percent) + "%"
	
	await Global.timer(1.0)
	var anim_time := 5.0
	var ini_pos_1 := telon_izq.position
	var ini_pos_2 := telon_der.position
	var offset := 1000.0
	
	var tween1 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.tween_property(telon_izq, "position", ini_pos_1 + Vector2(offset, 0), anim_time)\
		.set_trans(Tween.TRANS_ELASTIC)
	Global.play_cardboard(0.2)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(telon_der, "position", ini_pos_2 - Vector2(offset, 0), anim_time)\
		.set_trans(Tween.TRANS_ELASTIC)
	tween2.finished.connect(func():
		SoundSystem.play_sfx("duct_tape1", 0.2)
		animPlayer.play("pegar")
	)
	Global.play_cardboard(0.2)

func _hide_telon():
	_enable = false
	visible = false
	Global.end_song.emit()

func _input(event: InputEvent) -> void:
	if _enable and _accion_de_juego_pulsada :
		_hide_telon()

func _accion_de_juego_pulsada() -> bool:
	return (
		Input.is_action_just_pressed("verde")
		or Input.is_action_just_pressed("rojo")
		or Input.is_action_just_pressed("amarillo")
		or Input.is_action_just_pressed("azul")
		or Input.is_action_just_pressed("naranja")
		or Input.is_action_just_pressed("rasgar")
	)
