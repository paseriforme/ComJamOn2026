extends Node

var base_path : String = "res://assets/songs/"
var songs := {} # nombre -> Song

func _ready() -> void:
	var dir := DirAccess.open(base_path)
	if dir == null:
		push_error("No se pudo abrir: " + base_path)
		return
	dir.list_dir_begin()
	var folder := dir.get_next()
	while folder != "":
		if dir.current_is_dir() and folder != "." and folder != "..":
			var chart_path := base_path.path_join(folder).path_join("notes.chart")
			if FileAccess.file_exists(chart_path):
				var file := FileAccess.open(chart_path, FileAccess.READ)
				if file:
					_parse(file.get_as_text(), base_path.path_join(folder))
		folder = dir.get_next()
	dir.list_dir_end()

func _parse(text:String, path: String)->Song:
	var new_song:=Song.new(); new_song.difficulties={}
	var sec={}; var cur=""
	for r in text.split("\n"):
		var linea=r.strip_edges()
		if linea.begins_with("[") and linea.ends_with("]"):
			cur=linea.substr(1,linea.length()-2); sec[cur]=""
		elif cur!="" and linea!="" and linea!="{" and linea!="}":
			sec[cur]+=linea+"\n"

	var res:=120
	if sec.has("Song"):
		for linea in sec["Song"].split("\n"):
			var p = linea.split("=",false,1)
			if p.size()==2:
				var k=p[0].strip_edges(); var v=p[1].strip_edges()
				if k=="Name": new_song.name=v.trim_prefix('"').trim_suffix('"')
				elif k=="Resolution": res=v.to_int()
		# Buscar archivo de audio llamado "Song" con cualquier extension
		for ext in ["ogg", "mp3", "wav", "opus"]:
			var candidate := path.path_join("song." + ext)
			if FileAccess.file_exists(candidate):
				new_song.song_path = candidate
				break
		# Buscar archivo de audio llamado "Guitar" con cualquier extension
		for ext in ["ogg", "mp3", "wav", "opus"]:
			var candidate := path.path_join("guitar." + ext)
			if FileAccess.file_exists(candidate):
				new_song.guitar_path = candidate
				break
	
	print("parsing",new_song.name)
	var tempo=[]
	if sec.has("SyncTrack"):
		for linea in sec["SyncTrack"].split("\n"):
			var p=linea.split("=",false,1)
			if p.size()==2 and p[1].strip_edges().begins_with("B "):
				tempo.append({
					"tick":p[0].strip_edges().to_int(),
					"bpm":p[1].strip_edges().substr(2).to_int()/1000.0
				})
		tempo.sort_custom(func(a,b): return a.tick<b.tick)
		if tempo.size()>0: new_song.bpm=tempo[0].bpm

	var beat_2_sec = func(t:int)->float:
		if tempo.is_empty(): return 0.0
		var time:=0.0; var lt:=0; var bpm : float =tempo[0].bpm
		for i in range(tempo.size()):
			var e=tempo[i]
			if e.tick>=t: break
			if i>0:
				var dt=e.tick-lt
				time+=(dt/float(res))*(60.0/bpm)
				lt=e.tick; bpm=e.bpm
		time+=((t-lt)/float(res))*(60.0/bpm)
		return time

	for dificultad in ["Easy","Medium","Hard","Expert"]:
		var name=dificultad+"Single"
		if !sec.has(name): continue
		var by_tick={}
		for linea in sec[name].split("\n"):
			var p=linea.split("=",false,1)
			if p.size()==2 and p[1].strip_edges().begins_with("N "):
				var tk=p[0].strip_edges().to_int()
				var f=p[1].strip_edges().split(" ")[1].to_int()
				if f>=0 and f<=4:
					if !by_tick.has(tk): by_tick[tk]=[]
					by_tick[tk].append(f)
		var arr=[]
		var keys=by_tick.keys(); keys.sort()
		for tk in keys:
			var c=[false,false,false,false,false]
			for f in by_tick[tk]: c[f]=true
			arr.append(Nota.new(beat_2_sec.call(tk),c))
		new_song.difficulties[dificultad]=arr

	# Guardar en el mapa global
	if new_song.name!="":
		songs[new_song.name]=new_song

	return new_song
