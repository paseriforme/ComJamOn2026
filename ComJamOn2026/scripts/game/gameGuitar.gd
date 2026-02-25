extends Control

@export_group("Referencias a escenas")
@onready var audio_player: AudioStreamPlayer2D = $"../AudioPlayer"
@onready var animator: AnimationPlayer = $"../AnimationPlayer"
@onready var pegatina: TextureRect = $"../Pegatina"
@export var pegatinas : Array[Texture2D]
@onready var trastes: Control = $"../TextureRect/Trastes"
@export var telon_izq : TextureRect
@export var telon_der : TextureRect
@export var porcentaje_animator: AnimationPlayer
@export var porcentaje_label: Label

@onready var disco: Disco = $"../Disco"
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

@export_group("Configuracion de cancion")
@export_subgroup("Dificultad")
@export var spawn_offset := 1.5        # en beats
var pulse_time := 0.0
@export var bpm: float = 120
@export var tiempo_anticipacion = 0.3  # 300ms antes
@export var tiempo_retardo = 0.2       # 200ms despues
@export var perfe_time = 0.08          # +-80ms del beat exacto
@export_subgroup("Visual de pulsos")
@export var rotacion_inicial: float = -180.0
@export var rotacion_final: float = 0.0
@export var scale_pulsos: Vector2 = Vector2(0.66, 0.66)
@export var off_position_pulsos: Vector2 = Vector2(0,0)

var song_time := 0.0
var spawn_chord := 0   # indice de la proxima nota a spawnear

var enable := false
var ending := false
var rasgar_pressed := false

var calculo: float = 1.0
var notas_acertadas: float = 0.0
var notas_totales: float = 0.0

func start_song(_bpm: float = 120) -> void:
	bpm = _bpm
	pulse_time = spawn_offset * (60.0 / bpm)
	disco.set_vel((rotacion_final - rotacion_inicial)/pulse_time)
	spawn_chord = 0
	# porcentaje de perfeccion
	calculo = 1
	notas_acertadas = 0.0
	notas_totales = 0.0
	# banderas
	rasgar_pressed = false
	enable = true
	ending = false
	
	# Resetear estado de todas las notas
	for nota in Global.song:
		nota.hit = false
		nota.evaluated = false
	
	Global.sound.play_bgm(Global.cancion)
	song_time = Global.sound.bgm.get_playback_position()
	print("START")

func _create_pulse(nota: Nota) -> void:
	var puls: Pulso = PULSO.instantiate()
	puls.set_pulso(nota.chord)
	add_child(puls)
	# asignaciones del pulso
	puls.global_position = global_position + off_position_pulsos
	puls.scale = scale_pulsos
	puls.rotation = deg_to_rad(rotacion_inicial)
	# tween de movimiento
	var tween = puls.create_tween()
	tween.tween_property(puls, "rotation", deg_to_rad(rotacion_final), pulse_time)
	tween.finished.connect(func(): 
		puls.queue_free() # se elimina cuando termina
		)

func get_judgeable_note() -> Nota:
	# Buscamos la nota no evaluada mas cercana al tiempo de la cancion
	# si no hay una nota en rango devuelve null
	var best_note: Nota = null
	var best_diff := 999.0
	
	for nota in Global.song:
		if nota.evaluated:
			continue
		var diff: float = song_time - nota.time
		var abs_diff: float = abs(diff)
		if abs_diff <= tiempo_anticipacion and abs_diff < best_diff:
			best_diff = abs_diff
			best_note = nota
	
	return best_note

func _is_correct(nota: Nota) -> bool:
	for i in Global.trastes.size():
		if nota.chord[i] != Global.trastes[i]:
			return false
	return true

func check_input() -> void:
	var nota: Nota = get_judgeable_note()
	if nota == null:
		return
	
	var diff: float = song_time - nota.time
	var abs_diff: float = abs(diff)
	
	# Marcar como evaluada
	nota.evaluated = true
	
	# es correcto el acorde?
	if not _is_correct(nota):
		fail()
		pegatina.texture = pegatinas[0]
		animator.play("pegar")
		return
	# comprobar con respecto al tiempo
	if abs_diff <= perfe_time:
		# perfecto
		notas_acertadas += 1
		nota.hit = true
		correct(2,nota.chord)
	elif diff >= -tiempo_anticipacion and diff <= tiempo_retardo:
		# bien
		notas_acertadas += 0.5
		nota.hit = true
		correct(1, nota.chord)
		pegatina.texture = pegatinas[1]
	else:
		# Mal
		nota.hit = false
		audio_player.volume_db = 0
		fail()
	

func _check_missed_notes() -> void:
	# Solo revisar notas que ya han sido spawneadas (indice < spawn_chord)
	for i in range(spawn_chord):
		var nota: Nota = Global.song[i]
		if nota.evaluated: continue
		
		# si no ha sido evaluada y se ha pasado el tiempo maximo, es un fallo
		if song_time > nota.time + tiempo_retardo:
			nota.evaluated = true
			nota.hit = false
			audio_player.volume_db = -10
			fail()

func _check_song_finished() -> void:
	# Todas las notas evaluadas y la cancion ha terminado
	if spawn_chord >= Global.song.size():
		var todas_evaluadas := true
		for nota in Global.song:
			if not nota.evaluated:
				todas_evaluadas = false
				break
		if todas_evaluadas:
			end()

func _input(event: InputEvent) -> void:
	if not enable:
		return
	if event.is_action_pressed("rasgar") and not rasgar_pressed:
		rasgar_pressed = true
		check_input()
	if event.is_action_released("rasgar"):
		rasgar_pressed = false

func _process(_delta: float) -> void:
	if not enable or ending:
		return
	
	song_time = Global.sound.bgm.get_playback_position()
	
	# Spawn de pulsos con antelacion
	while spawn_chord < Global.song.size():
		var nota: Nota = Global.song[spawn_chord]
		if song_time >= nota.time - pulse_time:
			_create_pulse(nota)
			spawn_chord += 1
		else:
			break  
	
	_check_missed_notes()
	_check_song_finished()

func correct(time_quality:int, chord: Array) -> void:
	if not chord or len(chord) == 0:
		return
	audio_player.volume_db = 0
	# Mapear los trastes a notas
	match chord:
		Global.DO:
			audio_player.stream = load("res://assets/audio/sfx/DO.wav")
			audio_player.play()
		Global.RE:
			audio_player.stream = load("res://assets/audio/sfx/RE.wav")
			audio_player.play()
		Global.MI:
			audio_player.stream = load("res://assets/audio/sfx/MI.wav")
			audio_player.play()
		Global.SOL:
			audio_player.stream = load("res://assets/audio/sfx/SOL.wav")
			audio_player.play()
	
	pegatina.visible = true
	pegatina.texture = pegatinas[time_quality]
	animator.play("pegar")

func fail() -> void:
	print("FALLO")
	#audio de fallo
	audio_player.stream = load("res://assets/audio/sfx/detuned.wav")
	audio_player.play()
	pegatina.visible = true
	pegatina.texture = pegatinas[0]
	animator.play("pegar")

func end() -> void:
	if ending:
		return
	ending = true
	enable = false
	disco.end()
	Global.sound.stop_bgm()
	
	calculo = 0.0
	if Global.song.size() > 0:
		calculo = notas_acertadas /  Global.song.size()
	print("RESULTADO: ", int(calculo * 100), "%")

	if Global.npc_chocado == $"../../../../manager2":
		await Global.timer(1.0)
		var anim_time := 5.0
		var ini_pos_1 := telon_izq.position
		var ini_pos_2 := telon_der.position
		var offset := 1000.0
		
		var tween1 = get_tree().create_tween()
		tween1.set_ease(Tween.EASE_OUT)
		tween1.tween_property(telon_izq, "position", ini_pos_1 + Vector2(offset, 0), anim_time)\
			.set_trans(Tween.TRANS_ELASTIC)
		Global.play_cardboard(0.2)
		
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(telon_der, "position", ini_pos_2 - Vector2(offset, 0), anim_time)\
			.set_trans(Tween.TRANS_ELASTIC)
		tween2.finished.connect(func():
			porcentaje_label.text = str(int(calculo * 100)) + "%"
			Global.sound.play_sfx("duct_tape1", 0.2)
			porcentaje_animator.play("pegar")
		)
		Global.play_cardboard(0.2)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Solo salir al terminar la animacion del porcentaje final, no la de pegatinas
	if anim_name == "pegar" and ending:
		get_tree().quit()
