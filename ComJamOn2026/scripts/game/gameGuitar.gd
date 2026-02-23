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
	if actual_chord >= last_chord or actual_chord > len(Global.song):
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

func start_song(start = 0, fin = len(Global.song)):

	
	enable = true
	
	var start_sec = Global.npc_chocado.firstChord * ((60/bpm) * 0.5)
	print(start_sec)
	Global.sound.play_bgm(Global.cancion, false, start_sec)
	
	# reset de indices
	actual_chord = Global.npc_chocado.firstChord
	last_chord = Global.npc_chocado.lastChord
	
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

func _any_key_pressed() -> bool:
	for traste in Global.trastes:
		if traste:
			return true
	return false
	
func _time_diff_for_pulse(pulse: Pulso) -> float:
	if not pulse:
		return 9999.0
	var total_duration = (60.0 / bpm) * 4.0
	var start_rot = rotacion_inicial
	var end_rot = rotacion_final
	var delta_rot = end_rot - start_rot
	var rot_speed = delta_rot / total_duration
	var angle_diff = rotation_to_check - pulse.rotation_degrees
	# normalizar a [-180,180]
	while angle_diff > 180.0:
		angle_diff -= 360.0
	while angle_diff < -180.0:
		angle_diff += 360.0
	# tiempo restante hasta target
	if abs(rot_speed) < 0.00001:
		return 9999.0
	var time_until_target = angle_diff / rot_speed
	# expected hit time = song_time + time_until_target
	var expected_hit_time = song_time + time_until_target
	var time_diff = song_time - expected_hit_time  # == -time_until_target
	#print_debug("pulse.angle=", pulse.rotation_degrees, "angle_diff=", angle_diff, "rot_speed=", rot_speed, "time_until=", time_until_target, "time_diff=", time_diff)
	return time_diff
	
# Devuelve: 2 = perfecto, 1 = bien, 0 = fuera de ventana.
func _acertado_on_time(pulse: Pulso) -> int:
	var time_diff = _time_diff_for_pulse(pulse)
	# fuera de ventana
	if time_diff < - tiempo_anticipacion or time_diff > tiempo_retardo:
		return 0
	# perfecto
	if abs(time_diff) < perfe_time:
		return 2
	# bien
	return 1

func _is_press_late(pulse: Pulso) -> bool:
	var time_diff = _time_diff_for_pulse(pulse)
	return time_diff > tiempo_retardo

func check_input():
	if not can_hit_this_beat:
		return
		
	nearest_pulse_to_hit = get_pulse_nearest_to_rotation(rotation_to_check)
	if not nearest_pulse_to_hit:
		return
		
	# Si se ha pulsado
	if pulsed:
		if nearest_pulse_to_hit._is_pulse_empty():
			print("FAIL PULSA EN VACIO")
			fail()
			return
		if _is_press_late(nearest_pulse_to_hit):
			print("FAIL PULSA TARDE")
			fail()
			return
		var timing = _acertado_on_time(nearest_pulse_to_hit)
		if timing > 0 and nearest_pulse_to_hit._matching_keys_with_pulse():
			# perfecto / bien
			correct(timing)
			return
		elif timing > 0:
			# buen timing pero combinacion incorrecta -> fallo
			print("FAIL COMBINACION NO COINCIDE")
			fail()
			return
		else:
			print("OTRO")
			return
var last_evaluated_pulse: Pulso = null
func _physics_process(delta: float) -> void:
	if not enable:
		return
	
	song_time += delta
	elapsed_sb_time += delta
	# Actualizar referencia del pulso mas cercano al punto de rasgueo
	nearest_pulse_to_hit = get_pulse_nearest_to_rotation(rotation_to_check)
	
	if nearest_pulse_to_hit \
	and not pulsed \
	and nearest_pulse_to_hit != last_evaluated_pulse:
		if not nearest_pulse_to_hit._is_pulse_empty():
			var time_diff = _time_diff_for_pulse(nearest_pulse_to_hit)
			if time_diff > tiempo_retardo:
				print("FAIL NO PULSA EN PULSO NO VACIO (UNA SOLA VEZ)")
				fail()
				last_evaluated_pulse = nearest_pulse_to_hit
		next_pulse()
	
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
	last_evaluated_pulse = nearest_pulse_to_hit
	
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
	var pulso_data = pulse.pulso_data
	
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
	#audio de fallo
	audio_player.stream = load("res://audio/sfx/detuned.wav")
	audio_player.play()
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
		Global.play_cardboard(0.2)
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(telon_der, "position", ini_pos_2 - Vector2(offset,0), time).set_trans(Tween.TRANS_ELASTIC)
		tween2.finished.connect(func(): get_tree().quit())
		Global.play_cardboard(0.2)
