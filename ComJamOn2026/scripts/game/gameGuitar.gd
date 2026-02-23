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

# Ventana de tiempo asimétrica - MÁS PERMISIVO
@export var tiempo_anticipacion = 0.3  # Puede tocar 300ms ANTES
@export var tiempo_retardo = 0.2       # Puede tocar 200ms DESPUÉS
@export var perfe_time = 0.08          # Perfecto en ±80ms del beat exacto

var pulsed = false
var enable = false
var failed_this_beat = false
var correct_this_beat = false
var can_hit_this_beat = true

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

# Tiempo exacto del próximo beat
var next_beat_time : float = 0
var song_time : float = 0

var actual_cancion : float = 0
var pulses_to_start := 2
@export var ending_animator : AnimationPlayer 
@export var telon_izq : AnimationPlayer 
@export var telon_der : AnimationPlayer 
var ending = false

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
	can_hit_this_beat = true
	pulses_to_start = 2
	
	# reset tiempos
	elapsed_b_time = 0
	elapsed_sb_time = 0
	last_klk_time = 0
	song_time = 0
	next_beat_time = (60.0 / bpm) * 0.5  # Primer medio beat
	
	# reset visual
	disco.rotation = deg_to_rad(-90 + 150)
	
	# pre-cargar 3 pulsos visibles desde ese punto
	for i in range(8):
		var pulso_idx = (actual_pulso + i) % len(pool_pulsos)
		if i < len(Global.song):
			pool_pulsos[pulso_idx].set_pulso(Global.song[i])
	
	print("START")

func next_pulse(puls : Pulso):
	puls.set_pulso([false,false,false,false,false])
	
	# Si llegamos al siguiente beat sin haber acertado, es fallo (a menos que sea vacío)
	if can_hit_this_beat and not correct_this_beat and not _vacio_actual():
		fail()
	
	# avanzar el acorde
	actual_chord += 1
	next_beat_time += (60.0 / bpm) * 0.5
	
	await((60.0 / bpm) * 0.5)
	if actual_chord> len(Global.song):
		end()
		return
	puls.set_pulso(Global.song[actual_chord])
	
	# Reset de estados para el nuevo beat
	failed_this_beat = false
	correct_this_beat = false
	can_hit_this_beat = true

func get_nearest_pulse() -> Pulso:
	var puls = pool_pulsos[0]
	var last_n_pos = (pool_pulsos[0].global_position - trastes.global_position).length() 
	for p in pool_pulsos:
		if (p.global_position - trastes.global_position).length() < last_n_pos:
			last_n_pos = (p.global_position - trastes.global_position).length()
			puls = p
	return puls

func _matching_keys() -> bool:
	if actual_chord >= len(Global.song):
		return false
	for i in range(len(Global.trastes)):
		if Global.trastes[i] != Global.song[actual_chord][i]:
			return false
	return true

func _any_key_pressed() -> bool:
	for traste in Global.trastes:
		if traste:
			return true
	return false

	# Devuelve: 2 = perfecto, 1 = bien, 0 = fuera de ventana 
func _acertado_on_time() -> int:
	var time_diff = song_time - next_beat_time
	
	if time_diff < -tiempo_anticipacion or time_diff > tiempo_retardo:
		return 0  # Fuera de ventana completamente
	
	if abs(time_diff) < perfe_time:
		return 2  # PERFECTO
	else:
		return 1  # BIEN

func _vacio_actual() -> bool:
	if actual_chord >= len(Global.song):
		return false
	for traste in Global.song[actual_chord]:
		if traste:
			return false
	return true

func check_input():
	if not can_hit_this_beat:
		return
	
	# Si el acorde esta vacio esta bien
	if _vacio_actual():
		return
	
	if pulsed:
		var timing = _acertado_on_time()
		
		if timing > 0 and _matching_keys():
			# timing 2=perfecto, 1=bien
			correct(timing)
		else:
			# Mal timing
			fail()

func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	song_time += delta
	
	var beat_time = 60.0 / bpm
	elapsed_sb_time += delta
	
	if elapsed_sb_time >= beat_time * 0.5:
		elapsed_sb_time -= beat_time * 0.5
		next_pulse(get_nearest_pulse())
	
	# Verificar input continuamente
	if Input.is_action_just_pressed("rasgar", true):
		pulsed = true
		check_input()  # Verificar al momento de rasgar
	
	if Input.is_action_just_released("rasgar"):
		pulsed = false

func correct(timing_quality: int):
	if correct_this_beat:
		return
	
	correct_this_beat = true
	can_hit_this_beat = false
	
	# Mostrar pegatina segun calidad
	pegatina.visible = true
	match timing_quality:
		2:  # PERFECTO
			pegatina.texture = pegatinas[2]
			print("PERFECTO")
		1:  # BIEN
			pegatina.texture = pegatinas[1]
			print("BIEN")
	
	animator.play("pegar")
	
	# Reproducir sonido del acorde
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
			audio_player.stream = load("res://audio/sfx/SOL.wav")
			audio_player.play()
	
	failed_this_beat = false

func fail():
	if failed_this_beat:
		return
	
	print("FALLO")
	failed_this_beat = true
	can_hit_this_beat = false
	correct_this_beat = false
	
	# Mostrar pegatina de fallo
	pegatina.visible = true
	pegatina.texture = pegatinas[0]
	animator.play("pegar")
	

func end():
	ending = true
	disco.end()
	Global.sound.stop_bgm()
	if Global.npc_chocado == $"../../../../manager2":
		#TODO: telón final
#		ending_animator.play("end")
		await Global.timer(1.0)
		var time = 5.0
		var ini_pos_1 = telon_izq.position
		var ini_pos_2 = telon_der.position
		var offset = 1000
		var tween1 = get_tree().create_tween()
		tween1.set_ease(Tween.EASE_OUT)
		tween1.tween_property(telon_izq, "position", ini_pos_1 + Vector2(offset,0), time).set_trans(Tween.TRANS_ELASTIC)
		
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(telon_der, "position", ini_pos_2 - Vector2(offset,0), time).set_trans(Tween.TRANS_ELASTIC)
		tween2.finished.connect(func(): get_tree().quit())
		
		#get_tree().quit() #esto será callback on finished del tween 
		pass
