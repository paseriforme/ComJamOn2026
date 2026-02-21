extends Control
var song:= [[false, false, true, false, false], [true, false, true, false, false], [false, true, true, false, true]]

const PULSO = preload("uid://dlsillfjnepba")

var pool_pulsos := []
var actual_pulso := 0
var anterior_pulso := -1
var actual_compass := 0

var pulsed = false
var enable = false

func _ready() -> void:
	for i in range(4):
		var pulso = PULSO.instantiate()
		add_child(pulso)
		pool_pulsos.push_back(pulso)
	
	next_pulse()

func stop_song():
	enable = false

func start_song():
	enable = true
	actual_pulso = 0
	anterior_pulso = -1
	actual_compass = 0
	print("StartSong")

func next_pulse():
	
	# if not correcto: return
	
	# si ha acertado => siguiente
	
	# si ha terminado la cancion
	if actual_compass >= len(song):
		print(actual_compass, " / ", len(song))
		Global.end_song.emit()
		return
		
	# quita el anterior
	if (anterior_pulso != -1):
		var tween2 = pool_pulsos[anterior_pulso].create_tween()
		tween2.tween_property(pool_pulsos[anterior_pulso], "position", Vector2(300, 0.0), 0.00001)
		tween2.tween_property(pool_pulsos[anterior_pulso], "position", Vector2(-300, 720.0), 0.00001)
	anterior_pulso = actual_pulso
	
	# coloca el actual
	var tween1 = pool_pulsos[actual_pulso].create_tween()
	tween1.tween_property(pool_pulsos[actual_pulso], "position", Vector2(300, 720.0), 0.1)
	actual_pulso +=1
	if actual_pulso >= len(pool_pulsos): actual_pulso = 0
	
	# encender botones segun el compas
	pool_pulsos[actual_pulso].set_pulso(song[actual_compass])
	actual_compass +=1
	
	# coloca el siguiente
	var tween2 = pool_pulsos[actual_pulso].create_tween()
	tween2.tween_property(pool_pulsos[actual_pulso], "position", Vector2(0,720.0), 0.5)

func _physics_process(delta: float) -> void:
	if not enable: return
	
	if not pulsed and Input.is_action_pressed("rasgar",true):
		pulsed = true
		next_pulse()
	elif Input.is_action_just_released("rasgar",true):
		pulsed = false
