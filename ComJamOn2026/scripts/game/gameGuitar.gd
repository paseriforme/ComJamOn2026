extends Control
var song:= [[false, false, true, false, false], [true, false, true, false, false], [false, true, true, false, true]]

const PULSO = preload("uid://dlsillfjnepba")

var pool_pulsos := []
var actual_pulso := 0
var anterior_pulso := -1
var actual_chord := 0

var last_klk_time : float = 0

@export var bien_time = 0.15
@export var perfe_time = 0.1

var pulsed = false
var enable = false
var paused = false
var acierto = false

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

var pulses_to_start := 0

func _ready() -> void:
	for i in range(1):
		var pulso = PULSO.instantiate()
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
	print("StartSong")
	disco.start()
	disco.rotation = deg_to_rad(-90)

func next_pulse():
	correct()
	
	# si ha terminado la cancion
	if actual_chord >= len(song):
		print(actual_chord, " / ", len(song))
		Global.end_song.emit()
		return
	
	# quita el anterior
	anterior_pulso = actual_pulso
	if(not song[actual_chord]): return
	# coloca el actual
	actual_pulso +=1
	if actual_pulso >= len(pool_pulsos): actual_pulso = 0
	
	# encender botones segun el acorde
	pool_pulsos[actual_pulso].set_pulso(song[actual_chord])
	actual_chord +=1
	
	# coloca el siguiente

func _matching_keys() -> bool:
	for i in len(Global.trastes):
		if Global.trastes[i] != Global.song[actual_chord][i]:
			return false
	return true

func _acertado_on_time() -> bool:
	# diferencia con el tiempo anterior
	var dif_at = abs(Time.get_ticks_msec() - last_klk_time) * 0.001
	# diferencia con el tiempo siguiente
	var dif_nt = abs(Time.get_ticks_msec() - last_klk_time + (0.25/(bpm/60))) * 0.001
	print(dif_at, " / ", dif_nt, ": ", bien_time, "-", perfe_time)
	if (dif_at < bien_time or dif_nt < bien_time/3 or paused):
		# BIEN
		print("BIEN")
		if dif_at < perfe_time:
			# PERFECTO
			print("PERFECTO")
		return true
	return false

func _pulsado_correcto() -> bool:
	var a = true
	for i in len(Global.trastes):
		if not Global.trastes[i]:
			a = false
	
	if not a and not pulsed and Input.is_action_pressed("rasgar",true) :
		pulsed = true
		return true
	
	return a

func _physics_process(delta: float) -> void:
	if not enable: return
	
	if pulses_to_start >= 2:
		# si ha acertado => siguiente
		if _matching_keys() and _acertado_on_time():
			
				print("RASGAR")
				next_pulse()
				correct()
		else: 
			fail()
		if Input.is_action_just_released("rasgar",true):
			pulsed = false
	
		if paused: 
			return
	
	elapsed_b_time += delta
	
	if elapsed_b_time >= 1/(bpm/60):
		#print(1/(bpm/60))
		if (Global.sound != null):
			Global.sound.play_sfx("metronom_klack")
		elapsed_b_time = 0
		if pulses_to_start < 2:
			pulses_to_start+= 1
	elapsed_sb_time += delta
	if elapsed_sb_time >= 0.5/(bpm/60):
		last_klk_time = Time.get_ticks_msec()
		#Global.sound.play_sfx("metronom_klack")
		elapsed_sb_time = 0

func correct():
	acierto = true
	disco.start()
	paused = false

func fail():
	# FAIL SOUND
	elapsed_b_time = 0
	elapsed_sb_time = 0
	disco.fail()
	acierto = false
	paused = true
