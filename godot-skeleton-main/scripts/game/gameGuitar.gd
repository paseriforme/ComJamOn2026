extends Control
var song:= [[false, false, true, false, false], [true, false, true, false, false], [false, true, true, false, true]]

const PULSO = preload("uid://dlsillfjnepba")

var pool_pulsos := []
var actual_pulso := 0

func _ready() -> void:
	for i in range(2):
		var pulso = PULSO.instantiate()
		add_child(pulso)
		pool_pulsos.push_back(pulso)

func next_pulse():
	actual_pulso +=1
	if actual_pulso >= len(pool_pulsos): actual_pulso = 0

func _physics_process(delta: float) -> void:
	next_pulse()
