extends Control
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

var pool_pulsos : Array[Node]= []
var actual_pulso := 0  
var actual_chord := 0
var last_chord := len(Global.song)
var last_klk_time : float = 0

@onready var audio_player: AudioStreamPlayer2D = $"../AudioPlayer"
@onready var pegatina: TextureRect = $Pegatina
@onready var animator: AnimationPlayer = $AnimationPlayer
@export var pegatinas : Array[Texture2D]
@onready var trastes: Control = $"../TextureRect/Trastes"

@export var bien_time = 0.15
@export var perfe_time = 0.1

var pulsed = false
var enable = false
var failed_this_beat = false
var correct_this_beat = false

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

var actual_cancion : float =0

var pulses_to_start := 2

func _ready() -> void:
	for i in range(8):
		var pulso = PULSO.instantiate()
		pulso.scale = Vector2(0.66, 0.66)
		disco.add_child(pulso)
		pool_pulsos.push_back(pulso)

func stop_song():
	enable = false

func start_song(start, fin):
	enable = true
	
	var start_sec = start * ((60/bpm) * 0.5)
	print(start_sec)
	Global.sound.play_bgm(Global.cancion, false, start_sec)
	
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
	failed_this_beat = false
	correct_this_beat = false
	pulses_to_start = 2
	
	# reset tiempos
	elapsed_b_time = 0
	elapsed_sb_time = 0
	last_klk_time = 0
	
	# reset visual
	disco.rotation = deg_to_rad(-90 + 150)
	
	# pre-cargar 3 pulsos visibles desde ese punto
	for i in range(3):
		var pulso_idx = (actual_pulso + i) % len(pool_pulsos)
		if i < len(Global.song):
			pool_pulsos[pulso_idx].set_pulso(Global.song[i])
	
	print("START")

func next_pulse(puls):
	puls.set_pulso([false,false,false,false,false])
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
	
	failed_this_beat = false
	correct_this_beat = false

func get_nearest_pulse() -> Pulso:
	var puls = pool_pulsos[0]
	var last_n_pos = (pool_pulsos[0].global_position - trastes.global_position).length() 
	for p in pool_pulsos:
		if  (p.global_position - trastes.global_position).length() < last_n_pos:
			last_n_pos = (p.global_position - trastes.global_position).length()
			puls = p
	return puls

func _matching_keys() -> bool:
	if actual_chord >= len(Global.song):
		return false
	for i in range(len(Global.trastes)):
		if Global.trastes[i] != Global.song[actual_chord][i]:
			print("_matching_keys: FALSE")
			return false
	return true

func _acertado_on_time(puls : Pulso) -> bool:
	pegatina.visible = true
	
	var dif = (puls.global_position - trastes.global_position).length()
	if dif < perfe_time:
		pegatina.texture = pegatinas[2]
		print("PERFECTO")
		return true
	elif dif < bien_time:
		pegatina.texture = pegatinas[1]
		print("BIEN")
		return true
	else:
		print("MAL")
		pegatina.texture = pegatinas[0]
	animator.play("pegar")
	return false

func _vacio(puls : Pulso) -> bool:
	if actual_chord >= len(Global.song):
		return false
	for traste in Global.song[actual_chord]:
		if traste:
			return false
	return true

func check() -> bool:
	var puls = get_nearest_pulse()
	var on_t = _acertado_on_time(puls)
	if _vacio(puls) or (pulsed and on_t and _matching_keys()):
		return true
	return false

func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	if actual_chord >= last_chord:
		disco.end()
		Global.sound.stop_bgm()
		if Global.npc_chocado == $"../../../../manager2":
			queue_free()
		return
	
	var beat_time = 60.0 / bpm
	elapsed_sb_time += delta
	if elapsed_sb_time >= beat_time * 0.5:
		elapsed_sb_time -= beat_time * 0.5
		next_pulse(get_nearest_pulse())
		if check():
			correct()
	
	if Input.is_action_just_pressed("rasgar", true):
		pulsed = true
	
	if Input.is_action_just_released("rasgar"):
		pulsed = false

func correct():
	if correct_this_beat:
		return
	correct_this_beat = true
	
	#print("CORRECTO, ", Global.song[actual_chord])
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
	

func fail():
	if failed_this_beat:
		return
	
	Global.sound.stop_bgm()
	failed_this_beat = true
	correct_this_beat = false
