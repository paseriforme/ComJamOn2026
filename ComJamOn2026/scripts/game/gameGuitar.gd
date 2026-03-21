extends Control
class_name Game_Guitar

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

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var guitar_player: AudioStreamPlayer2D = $GuitarPlayer
@onready var disco: Disco = $"../Disco"
const PULSO = preload("res://scenes/Prefabs/pulso.tscn")

@export_group("Configuracion de cancion")
@export_subgroup("Dificultad")
@export var spawn_offset := 1.5        # en beats
var pulse_time := 0.0
@export var tiempo_anticipacion = 0.3  # 300ms antes
@export var tiempo_retardo = 0.2       # 200ms despues
@export var perfe_time = 0.08          # +-80ms del beat exacto
@export var dificulty = "Easy"
@export_subgroup("Visual de pulsos")
@export var rotacion_inicial: float = -180.0
@export var rotacion_final: float = 0.0
@export var scale_pulsos: Vector2 = Vector2(0.66, 0.66)
@export var off_position_pulsos: Vector2 = Vector2(0, 0)

# Cancion activa
var current_song: Song = null

var song_time := 0.0
var spawn_chord := 0   # indice de la proxima nota a spawnear

var enable := false
var ending := false
var rasgar_pressed := false

var calculo: float = 1.0
var notas_acertadas: float = 0.0
var notas_totales: float = 0.0

func _ready() -> void:
	Global.startSong.connect(start_song)

func start_song(song: String = "", _dificulty: String = "expert") -> void:
	if song == "" or song not in SongLoader.songs:
		print("Cancion: [", song, "] no es valida")
		return
	Global.sound.bgm.volume_db = -10000
	current_song = SongLoader.songs[song]
	dificulty = _dificulty
	pulse_time = spawn_offset * (60.0 / current_song.bpm)
	disco.set_vel((rotacion_final - rotacion_inicial) / pulse_time)
	spawn_chord = 0
	
	# porcentaje de perfeccion
	calculo = 1.0
	notas_acertadas = 0.0
	notas_totales = 0.0
	
	# banderas
	rasgar_pressed = false
	enable = true
	ending = false
	
	# Resetear estado de todas las notas
	for nota: Nota in current_song.difficulties[dificulty]:
		nota.hit = false
		nota.evaluated = false
		
	music_player.stream = load(current_song.song_path)
	guitar_player.stream = load(current_song.guitar_path)
	music_player.play()
	guitar_player.play()
	song_time = music_player.get_playback_position()
	print("Cancion: [", song, "] EMPIEZA")


func _create_pulse(nota: Nota) -> void:
	#print("PULSOOOOOOOOOO")
	var puls: Pulso = PULSO.instantiate()
	puls.set_pulso(nota.chord)
	add_child(puls)
	puls.global_position = global_position + off_position_pulsos
	puls.scale = scale_pulsos
	puls.rotation = deg_to_rad(rotacion_inicial)

	var tween = puls.create_tween()
	tween.tween_property(puls, "rotation", deg_to_rad(rotacion_final), pulse_time)
	tween.finished.connect(func():
		puls.queue_free()
	)


func get_judgeable_note() -> Nota:
	# Devuelve la nota no evaluada mas cercana al tiempo actual, o null si no hay ninguna en rango
	var best_note: Nota = null
	var best_diff := 999.0
	
	for nota: Nota in current_song.difficulties[dificulty]:
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

	nota.evaluated = true

	if not _is_correct(nota):
		fail()
		pegatina.texture = pegatinas[0]
		animator.play("pegar")
		return

	if abs_diff <= perfe_time:
		notas_acertadas += 1
		nota.hit = true
		correct(2, nota.chord)
	elif diff >= -tiempo_anticipacion and diff <= tiempo_retardo:
		notas_acertadas += 0.5
		nota.hit = true
		correct(1, nota.chord)
		pegatina.texture = pegatinas[1]
	else:
		nota.hit = false
		audio_player.volume_db = 0
		fail()


func _check_missed_notes() -> void:
	for i in range(spawn_chord):
		var nota: Nota = current_song.difficulties[dificulty][i]
		if nota.evaluated:
			continue
		if song_time > nota.time + tiempo_retardo:
			nota.evaluated = true
			nota.hit = false
			audio_player.volume_db = -10
			fail()

func _check_song_finished() -> void:
	if spawn_chord >= current_song.difficulties[dificulty].size():
		for nota: Nota in current_song.difficulties[dificulty]:
			if not nota.evaluated:
				return
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

	song_time = music_player.get_playback_position()

	# Spawn de pulsos con antelacion
	while spawn_chord < current_song.difficulties[dificulty].size():
		var nota: Nota = current_song.difficulties[dificulty][spawn_chord]
		if song_time >= nota.time - pulse_time:
			_create_pulse(nota)
			spawn_chord += 1
		else:
			#print("Aun no: ", spawn_chord, " || ", song_time,"-", nota.time - pulse_time)
			break

	_check_missed_notes()
	_check_song_finished()


func correct(time_quality: int, chord: Array) -> void:
	if not chord or chord.is_empty():
		return
	guitar_player.volume_db = 0
	
	pegatina.visible = true
	pegatina.texture = pegatinas[time_quality]
	animator.play("pegar")


func fail() -> void:
	print("FALLO")
	guitar_player.volume_db = -100000
	audio_player.stream = load("res://assets/audio/sfx/detuned.wav")
	audio_player.play()
	pegatina.visible = true
	pegatina.texture = pegatinas[0]
	animator.play("pegar")


func end() -> void:
	if ending:
		return
	Global.sound.bgm.volume_db = 0
	ending = true
	enable = false
	disco.end()
	Global.sound.stop_bgm()

	calculo = 0.0
	if current_song.difficulties[dificulty].size() > 0:
		calculo = notas_acertadas / current_song.difficulties[dificulty].size()
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
	if anim_name == "pegar" and ending:
		get_tree().quit()
