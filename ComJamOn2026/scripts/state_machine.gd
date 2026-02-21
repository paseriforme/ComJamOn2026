extends Node

@export var scenes: Array[PackedScene] = [] 
@onready var fade = $Fade

var actualScene : Scene

@onready var bgm: AudioStreamPlayer2D = $Sound/BGM
@onready var sfx: AudioStreamPlayer2D = $Sound/SFX
@onready var sound = $Sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## INICIALIZAR GLOBAL
	Global.sm = self
	Global.sfx = sfx
	Global.bgm = bgm
	Global.sound = sound
	
	## CONECTAR SEÑALES
	Global.on_transition_end.connect(_on_fade_end)
	Global.on_game_end.connect(_on_game_end)
	
	## PRIMER CAMBIO DE ESCENA
	Global.change_scene(Global.Scenes.CONTEXT)
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func _input(event):
	var scene = Global.Scenes.NULL;
	if event.is_action_pressed("1"):
		scene = Global.Scenes.CONTEXT
	if event.is_action_pressed("2"):
		scene = Global.Scenes.GAME
	#if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
	if (scene != Global.Scenes.NULL):
		Global.change_scene(scene)

func _on_game_end():
	pass

#func _on_transition(speed = 1.0) -> void: #fade in
	#fade.transition(speed)


func _on_fade_end() -> void: #justo antes del fadeout, la idea es que esto sea un switch
	# escena a apagar
	if actualScene:
		actualScene.on_disable()
		actualScene.queue_free()
	# escena a encender
	actualScene = scenes[Global.next_scene].instantiate()
	$Scenes.add_child(actualScene)
	actualScene.on_enable()
	
	# actualiza la musica segun la escena
	_update_bgm_for_scene()

func _update_bgm_for_scene() -> void:
	match Global.current_scene:
		Global.Scenes.CONTEXT:
			# Global.sound.play_bgm("intro_theme")
			Global.sound.stop_bgm()
		Global.Scenes.GAME:
			# sample de prueba luego se cambia por el real
			Global.sound.play_bgm("bgmusicSample")
		Global.Scenes.NULL:
			Global.sound.stop_bgm()
