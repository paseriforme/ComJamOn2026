extends Scene
@onready var juego: Control = $CanvasLayer/Control
@onready var songs: VBoxContainer = $CanvasLayer/Songs/VBoxContainer
#const SONG_OPTION = preload("uid://s5nsitwp0j1u")

func _ready() -> void:
	juego.visible = false
	songs.visible = true
	for s in SongLoader.songs.keys():
		for d in SongLoader.songs[s].difficulties.keys():
			pass
			#var song : Button= SONG_OPTION.instantiate();
			#song.text = s + "|" + d
			#songs.add_child(song)
	Global.startSong.connect(setup_song_context)

func setup_song_context(song : String = "", difficulty : String = "") -> void:
	if song == "" or song not in SongLoader.songs:
		print("Cancion: [", song, "] no es valida")
		return
	print("Change scene to play[",song,"]")
	juego.visible = true
	songs.visible = false
