extends Control
var song:= [[false, false, true, false, false], [true, false, true, false, false], [false, true, true, false, true]]

const PULSO = preload("uid://dlsillfjnepba")

var pool_pulsos := []
var actual_pulso := 0

func _ready() -> void:
	for i in range(3):
		var pulso = PULSO.instantiate()
		add_child(pulso)
		pool_pulsos.push_back(pulso)

func next_pulse():
	var tween1 = pool_pulsos[actual_pulso].create_tween()
	tween1.tween_property(pool_pulsos[actual_pulso], "rotation_degrees", 220, 0.5)
	actual_pulso +=1
	
	if actual_pulso >= len(pool_pulsos): actual_pulso = 0
	
	var tween2 = pool_pulsos[actual_pulso].create_tween()
	tween2.tween_property(pool_pulsos[actual_pulso], "rotation_degrees", 45, 0.5)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rasgar",true):
		next_pulse()
