extends Control
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

var pool_pulsos : Array[Node]= []
var actual_pulso := 0
var anterior_pulso := -1

var actual_chord := 0
var waiting_chord := -1

var last_klk_time : float = 0

@export var bien_time = 0.15
@export var perfe_time = 0.1

var pulsed = false
var enable = false
var paused = false
var acierto = false
var esperando_acierto = true

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

var pulses_to_start := 0

func _ready() -> void:
	var rot = 0
	for i in range(8):
		var pulso = PULSO.instantiate()
		pulso.scale = Vector2(0.66, 0.66)
		print(i, ": ", Global.song[i])
		pulso.rotation = deg_to_rad(rot)
		pulso.set_pulso(Global.song[i])
		rot += 45
		disco.add_child(pulso)
		pool_pulsos.push_back(pulso)
	next_pulse()

func stop_song():
	enable = false
	disco.stop()

func start_song():
	enable = true
	actual_pulso = 0
	anterior_pulso = -1
	actual_chord = 0
	waiting_chord = -1
	pulses_to_start = 0
	esperando_acierto = false
	acierto = false
	print("StartSong")
	disco.start()
	disco.rotation = deg_to_rad(-90)

func next_pulse():
	# si ha terminado la cancion
	if actual_chord >= len(Global.song):
		#print(actual_chord, " / ", len(Global.song))
		Global.end_song.emit()
		return
	
	# quita el anterior
	anterior_pulso = actual_pulso
	if Global.song[actual_chord] != null:
		# coloca el actual
		actual_pulso +=1
		if actual_pulso >= len(pool_pulsos):
			actual_pulso = 0
		
		# encender botones segun el acorde
		pool_pulsos[actual_pulso].set_pulso(Global.song[actual_chord])
		
		waiting_chord = actual_chord
		actual_chord += 1
		
		esperando_acierto = true
		acierto = false
	else:
		actual_chord += 1
		next_pulse()

func _matching_keys() -> bool:
	if waiting_chord < 0 or waiting_chord >= len(Global.song):
		return false
	for i in range(len(Global.trastes)):
		if Global.trastes[i] != Global.song[waiting_chord][i]:
			return false
	return true

func _acertado_on_time() -> bool:
	# diferencia con el tiempo anterior
	var dif_at = abs(Time.get_ticks_msec() - last_klk_time) * 0.001
	# diferencia con el tiempo siguiente
	var dif_nt = abs(Time.get_ticks_msec() - last_klk_time + (0.25/(bpm/60))) * 0.001
	#print(dif_at, " / ", dif_nt, ": ", bien_time, "-", perfe_time)
	if (dif_at < bien_time or dif_nt < bien_time/3 or paused):
		if dif_at < perfe_time:
			# PERFECTO
			print("PERFECTO")
		elif(dif_at > bien_time ):
			# MAL
			print("MAL")
		else:
			# BIEN
			print("BIEN")
		return true
	return false

func _vacio() -> bool:
	if waiting_chord < 0 or waiting_chord >= len(Global.song):
		return true
	for traste in Global.song[waiting_chord]:
		if traste:
			return false
	return true

func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	# Actualizar el tiempo del beat
	var beat_time = 60.0 / bpm
	elapsed_b_time += delta
	if elapsed_b_time >= beat_time:
		if Global.sound != null:
			Global.sound.play_sfx("metronom_klack")
		elapsed_b_time -= beat_time
		
		if pulses_to_start < 2:
			pulses_to_start += 1
	
	# Actualizar sub-beat (medio tiempo)
	elapsed_sb_time += delta
	if elapsed_sb_time >= beat_time * 0.5:
		last_klk_time = Time.get_ticks_msec()
		elapsed_sb_time -= beat_time * 0.5
		
		if pulses_to_start >= 2 and esperando_acierto and acierto:
			esperando_acierto = false
			acierto = false
			pulsed = false  # Reset para el siguiente pulso
			next_pulse()
	
	# Detectar input solo cuando estamos esperando acierto
	if pulses_to_start >= 2 and esperando_acierto:
		if _vacio():
			acierto = true
		elif not pulsed and Input.is_action_just_pressed("rasgar"):
			if _matching_keys() and _acertado_on_time():
				print("Pulsado correcto")
				pulsed = true
				correct()
			else:
				print("Fallo en la deteccion")
				pulsed = true
				fail()
	
	# Liberar pulsacion
	if Input.is_action_just_released("rasgar"):
		pulsed = false

func correct():
	print("Correct")
	acierto = true
	disco.correct()

func fail():
	#print("Fail")
	# FAIL SOUND
	disco.fail()
	acierto = false
