extends Control
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

var pulsos : Array[Node] = []
var actual_pulso := 0  
var actual_chord := 0
var last_chord := len(Global.song)
var last_klk_time : float = 0

@onready var audio_player: AudioStreamPlayer2D = $"../AudioPlayer"
@onready var pegatina: TextureRect = $"../Pegatina"
@onready var animator: AnimationPlayer = $"../AnimationPlayer"
@export var pegatinas : Array[Texture2D]
@onready var trastes: Control = $"../TextureRect/Trastes"

@export var tiempo_anticipacion = 0.3  # 300ms antes
@export var tiempo_retardo = 0.2       # 200ms despues
@export var perfe_time = 0.08          # +-80ms del beat exacto

var pulsed = false
var enable = false
var failed_this_beat = false
var correct_this_beat = false
var can_hit_this_beat = true

@onready var disco: Disco = $"../Disco"

@export var bpm :float = 120
var elapsed_b_time :float = 0
var elapsed_sb_time :float = 0

# Tiempo exacto del proximo beat
var next_beat_time : float = 0
var song_time : float = 0

var actual_cancion : float = 0
var pulses_to_start := 2
@export var ending_animator : AnimationPlayer 
@export var telon_izq : AnimationPlayer 
@export var telon_der : AnimationPlayer 
var ending = false

# Parámetros de rotación
@export var num_pulsos : int = 8
@export var rotacion_inicial : float = -180.0
@export var rotacion_final : float = 0.0
@export var escala_pulsos : Vector2 = Vector2(0.66, 0.66)

func _ready() -> void:
	pass

func stop_song():
	enable = false

func _create_pulse():
	if actual_chord >= last_chord:
		if not ending: 
			end()
		return
	
	var pl: Pulso = PULSO.instantiate()
	add_child(pl)
	pl.set_pulso(Global.song[actual_chord])
	
	# configurar posicion inicial
	pl.rotation_degrees = rotacion_inicial
	pl.scale = escala_pulsos
	pl.set_pulso(Global.song[actual_chord])
	
	var duration = 60.0 / bpm  # Duracion de un beat
	var tween = create_tween()
	tween.tween_property(pl, "rotation_degrees", rotacion_final, duration *4)
	# crear siguiente y destruir este
	tween.finished.connect(func():
		actual_chord += 1
		next_beat_time += duration *4
		_create_pulse()
		pl.queue_free()
	)

func start_song(start, fin):
	enable = true
	
	var start_sec = start * ((60/bpm) * 0.5)
	print(start_sec)
	Global.sound.play_bgm(Global.cancion, false, start_sec)
	
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
	position = Vector2(695.522, 898.507)
	
	# Iniciar la creación de pulsos
	_create_pulse()
	
	print("START")

func next_pulse():
	# Reset de estados para el nuevo beat
	failed_this_beat = false
	correct_this_beat = false
	can_hit_this_beat = true

func get_nearest_pulse() -> Pulso:
	# Obtener el pulso que está más cerca de trastes
	var nearest_pulse: Pulso = null
	var min_distance = INF
	
	for child in get_children():
		if child is Pulso:
			var distance = (child.global_position - trastes.global_position).length()
			if distance < min_distance:
				min_distance = distance
				nearest_pulse = child
	
	return nearest_pulse

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
		next_pulse()
	
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
		#TODO: telon final
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
		
		#get_tree().quit() #esto sera callback on finished del tween 
		pass
