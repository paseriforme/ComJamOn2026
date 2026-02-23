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

var nearest_pulse_to_hit: Pulso = null
@export var rotation_to_check: float = 90.0  # Rotacion del punto de rasgueo

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

# Parametros de rotacion
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
	
	var duration = 60.0 / bpm  # Duracion de un beat
	var tween = create_tween()
	
	# Mover la rotacion de inicio a fin (2 beats)
	tween.tween_property(pl, "rotation_degrees", rotacion_final, duration * 4)
	
	# Al terminar: crear siguiente y destruir este
	tween.finished.connect(func():
		actual_chord += 1
		next_beat_time += duration * 4
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
	# Iniciar la creacion de pulsos
	_create_pulse()
	
	print("START")

func next_pulse():
	# Reset de estados para el nuevo beat
	failed_this_beat = false
	correct_this_beat = false
	can_hit_this_beat = true

func get_pulse_nearest_to_rotation(target_rotation: float = 90.0) -> Pulso:
	var nearest_pulse: Pulso = null
	var min_angle_diff = INF
	
	for child in get_children():
		if child is Pulso:
			# Calcular diferencia angular minima (considerando que es ciclico)
			var angle_diff = abs(child.rotation_degrees - target_rotation)
			if angle_diff > 180:
				angle_diff = 360 - angle_diff
			
			if angle_diff < min_angle_diff:
				min_angle_diff = angle_diff
				nearest_pulse = child
	
	return nearest_pulse

func get_nearest_pulse() -> Pulso:
	# Obtener el pulso que esta mas cerca de trastes
	var nearest_pulse: Pulso = null
	var min_distance = INF
	
	for child in get_children():
		if child is Pulso:
			var distance = (child.global_position - trastes.global_position).length()
			if distance < min_distance:
				min_distance = distance
				nearest_pulse = child
	
	return nearest_pulse

func _matching_keys_with_pulse(pulse: Pulso) -> bool:
	if not pulse:
		return false
	
	# Obtener datos del pulso - acceder a la variable pulso directamente
	var pulso_data = []
	if pulse.has_meta("pulso_data"):
		pulso_data = pulse.get_meta("pulso_data")
	elif "pulso" in pulse:
		pulso_data = pulse.pulso
	else:
		return false
	
	if pulso_data == null or len(pulso_data) == 0:
		return false
	
	# Verificar que los inputs coincidan
	for i in range(min(len(Global.trastes), len(pulso_data))):
		if Global.trastes[i] != pulso_data[i]:
			return false
	
	return true

func _is_pulse_empty(pulse: Pulso) -> bool:
	if not pulse:
		return true
	
	# Obtener datos del pulso
	var pulso_data = []
	if pulse.has_meta("pulso_data"):
		pulso_data = pulse.get_meta("pulso_data")
	elif "pulso" in pulse:
		pulso_data = pulse.pulso
	else:
		return true
	
	if pulso_data == null or len(pulso_data) == 0:
		return true
	
	for traste in pulso_data:
		if traste:
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

func check_input():
	if not can_hit_this_beat:
		return
	
	# Obtener el pulso mas cercano a la rotacion de rasgueo (90 grados)
	nearest_pulse_to_hit = get_pulse_nearest_to_rotation(rotation_to_check)
	
	# Si no hay pulso valido, no hacer nada
	if not nearest_pulse_to_hit:
		print_debug("No pulse found at rotation ", rotation_to_check)
		return
	
	# Si el pulso esta vacio, se considera correcto
	if _is_pulse_empty(nearest_pulse_to_hit):
		correct(1)
		return
	
	# Si se ha pulsado, verificar
	if pulsed:
		var timing = _acertado_on_time()
		
		if timing > 0 and _matching_keys_with_pulse(nearest_pulse_to_hit):
			# timing 2=perfecto, 1=bien
			correct(timing)
		elif timing > 0:
			# Buen timing pero inputs no coinciden
			fail()
		# Si timing <= 0, esperar a que se salga de ventana

func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	song_time += delta
	
	var beat_time = 60.0 / bpm
	elapsed_sb_time += delta
	
	if elapsed_sb_time >= beat_time * 0.5:
		elapsed_sb_time -= beat_time * 0.5
		next_pulse()
	
	# Actualizar referencia del pulso mas cercano al punto de rasgueo
	nearest_pulse_to_hit = get_pulse_nearest_to_rotation(rotation_to_check)
	
	# Verificar input cuando se rasguea
	if Input.is_action_just_pressed("rasgar", true):
		pulsed = true
		check_input()
	
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
	
	# Reproducir sonido del pulso mas cercano
	if nearest_pulse_to_hit:
		_play_sound_from_pulso(nearest_pulse_to_hit)
	
	failed_this_beat = false

func _play_sound_from_pulso(pulse: Pulso):
	var pulso_data = []
	if pulse.has_meta("pulso_data"):
		pulso_data = pulse.get_meta("pulso_data")
	elif "pulso" in pulse:
		pulso_data = pulse.pulso
	
	if not pulso_data or len(pulso_data) == 0:
		return
	
	# Mapear los trastes a notas (ajusta segun tu logica)
	match pulso_data:
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
