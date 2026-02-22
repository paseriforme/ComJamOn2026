extends Control
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

var pool_pulsos : Array[Node]= []
var actual_pulso := 0  
var actual_chord := 0
var last_chord := len(Global.song)
var last_klk_time : float = 0

@onready var audio_player: AudioStreamPlayer2D = $"../AudioPlayer"

@export var bien_time = 0.15
@export var perfe_time = 0.1
@export var hit_zone_angle = -30.0

var pulsed = false
var enable = false
var paused = false
var acierto = false
var failed_this_beat = false
var correct_this_beat = false

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

var pulses_to_start := 2

func _ready() -> void:
	for i in range(8):
		var pulso = PULSO.instantiate()
		pulso.scale = Vector2(0.66, 0.66)
		disco.add_child(pulso)
		pool_pulsos.push_back(pulso)

func stop_song():
	enable = false

func _get_pulso_en_hit_zone() -> int:
	var disco_rot = fmod(rad_to_deg(disco.rotation) + 360, 360)
	
	var closest = 0
	var min_diff = 360.0
	
	for i in range(len(pool_pulsos)):
		var pulso_rot = fmod(rad_to_deg(pool_pulsos[i].rotation) + 360, 360)
		var pulso_angle = fmod(pulso_rot + disco_rot + 360, 360)
		var diff = abs(pulso_angle - hit_zone_angle)
		if diff > 180:
			diff = 360 - diff
		if diff < min_diff:
			min_diff = diff
			closest = i
	
	return closest

func start_song(start, fin):
	enable = true
	paused = false
	
	# limpiar pulsos y establecer rotaciones fijas
	var rot = 0
	for i in len(pool_pulsos):
		pool_pulsos[i].scale = Vector2(0.66, 0.66)
		pool_pulsos[i].rotation = deg_to_rad(rot)
		pool_pulsos[i].set_pulso([false,false,false,false,false])
		rot -= 45
	
	# reset de indices
	actual_chord = start
	last_chord = fin
	
	# reset estados
	pulsed = false
	acierto = false
	failed_this_beat = false
	correct_this_beat = false
	pulses_to_start = 2
	
	# reset tiempos
	elapsed_b_time = 0
	elapsed_sb_time = 0
	last_klk_time = 0
	
	# reset visual
	disco.rotation = deg_to_rad(-90 + 150)
	
	# Calcular que pulso esta en la zona de hit al inicio (SOLO UNA VEZ)
	actual_pulso = _get_pulso_en_hit_zone()
	
	# pre-cargar 3 pulsos visibles desde ese punto
	for i in range(3):
		var pulso_idx = (actual_pulso + i) % len(pool_pulsos)
		if i < len(Global.song):
			pool_pulsos[pulso_idx].set_pulso(Global.song[i])
	
	print("START")

func next_pulse():
	# apagar el pulso que ya paso (1 atras del actual)
	var pulso_atras = (actual_pulso - 1 + len(pool_pulsos)) % len(pool_pulsos)
	pool_pulsos[pulso_atras].set_pulso([false,false,false,false,false])
	#print("Apagando pulso: ", pulso_atras)
	
	# avanzar el acorde
	actual_chord += 1
	
	# AVANZAR actual_pulso
	actual_pulso = (actual_pulso + 1) % len(pool_pulsos)
	
	# encender el pulso que entra
	var pulso_adelante = (actual_pulso + 3) % len(pool_pulsos)
	var chord_adelante = actual_chord + 2  # 2 acordes adelante del nuevo actual
	
	if chord_adelante < len(Global.song):
		pool_pulsos[pulso_adelante].set_pulso(Global.song[chord_adelante])
		#print("Generando pulso: ", pulso_adelante, " con acorde: ", chord_adelante, " | Acorde actual: ", actual_chord, " | Pulso actual: ", actual_pulso)
	
	acierto = false
	failed_this_beat = false
	correct_this_beat = false

func _matching_keys() -> bool:
	if actual_chord >= len(Global.song):
		return false
	for i in range(len(Global.trastes)):
		if Global.trastes[i] != Global.song[actual_chord][i]:
			print("_matching_keys: FALSE")
			return false
	return true

func _acertado_on_time() -> bool:
	if paused:
		print("MAL")
		return true
	var dif_at = abs(Time.get_ticks_msec() - last_klk_time) * 0.001
	var dif_nt = abs(Time.get_ticks_msec() - last_klk_time + (0.25/(bpm/60))) * 0.001
	if (dif_at < bien_time or dif_nt < bien_time/3):
		if dif_at < perfe_time:
			print("PERFECTO")
		elif(dif_at > bien_time ):
			print("MAL")
		else:
			print("BIEN")
		return true
	return false

func _vacio() -> bool:
	if actual_chord >= len(Global.song):
		return false
	for traste in Global.song[actual_chord]:
		if traste:
			return false
	return true

func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	if actual_chord >= last_chord:
		disco.end()
		return
	
	if not paused:
		var beat_time = 60.0 / bpm
		elapsed_b_time += delta
		if elapsed_b_time >= beat_time:
			if Global.sound != null:
				Global.sound.play_sfx("metronom_klack")
			elapsed_b_time -= beat_time
			if pulses_to_start < 2 : 
				print("A")
				pulses_to_start += 1
	
		elapsed_sb_time += delta
		if elapsed_sb_time >= beat_time * 0.5:
			last_klk_time = Time.get_ticks_msec()
			elapsed_sb_time -= beat_time * 0.5
		
			if pulses_to_start >= 2 and acierto:
				acierto = false
				pulsed = false
				next_pulse()
				print("next")
	
	# Detectar input solo cuando estamos esperando acierto
	if pulses_to_start >= 2:
		if _vacio():
			correct()
		elif not pulsed and Input.is_action_just_pressed("rasgar", true):
			pulsed = true
			if _matching_keys() and _acertado_on_time():
				correct()
			else:
				fail()
		elif not failed_this_beat and not pulsed:
			fail()
	
	if Input.is_action_just_released("rasgar"):
		pulsed = false

func correct():
	if correct_this_beat:
		return
		
	correct_this_beat = true
	acierto = true
	paused = false
	print("CORRECTO, ", Global.song[actual_chord])
	match Global.song[actual_chord]:
		Global.DO:
			audio_player.stream = load("res://audio/sfx/DO.wav")
			audio_player.play()
		Global.RE:
			audio_player.stream = load("res://audio/sfx/RE.wav")
			audio_player.play()
		Global.MI:
			audio_player.stream = load("res://audio/sfx/MI.wav")
			audio_player.play()
		Global.SOL:
			audio_player.stream =  load("res://audio/sfx/SOL.wav")
			audio_player.play()
	failed_this_beat = false
	disco.correct()

func fail():
	if failed_this_beat:
		return
		
	failed_this_beat = true
	#if Global.sound != null:
		#Global.sound.play_sfx("detuned")
	
	# Pasar el indice del pulso actual y su rotacion
	disco.fail(pool_pulsos[actual_pulso].rotation)
	correct_this_beat = false
	elapsed_sb_time = (60.0 / bpm) * 0.5
	acierto = false
	paused = true
