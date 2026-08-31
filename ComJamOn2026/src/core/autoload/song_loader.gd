@tool
extends EditorScript

const BASE_PATH := "res://assets/songs/"
const AUDIO_EXTS := ["ogg", "mp3", "wav", "opus"]


func _run() -> void:
	var dir := DirAccess.open(BASE_PATH)
	if dir == null:
		push_error("No se pudo abrir: " + BASE_PATH)
		return

	var generadas := 0
	dir.list_dir_begin()
	var folder := dir.get_next()
	while folder != "":
		var chart_path := BASE_PATH.path_join(folder).path_join("notes.chart")
		if not dir.current_is_dir() or folder in [".", ".."] or not FileAccess.file_exists(chart_path):
			folder = dir.get_next()
			continue

		var carpeta := BASE_PATH.path_join(folder)
		var song := _parse(FileAccess.get_file_as_string(chart_path), carpeta)
		if song != null and song.name != "":
			var out := carpeta.path_join("song.tres")
			if ResourceSaver.save(song, out) == OK:
				print("Guardada: ", out)
				generadas += 1
			else:
				push_error("Error guardando " + out)
		folder = dir.get_next()
	dir.list_dir_end()

	print(">>> ", generadas, " canciones generadas. Refresca el FileSystem si no aparecen.")
	EditorInterface.get_resource_filesystem().scan()


# Devuelve [clave, valor] con edges limpios, o [] si la línea no tiene "="
func _kv(linea: String) -> Array:
	var p := linea.split("=", false, 1)
	if p.size() != 2:
		return []
	return [p[0].strip_edges(), p[1].strip_edges()]


# Primer archivo <prefijo>.<ext> que exista, o "" si ninguno
func _find_audio(path: String, prefijo: String) -> String:
	for ext in AUDIO_EXTS:
		var candidate := path.path_join(prefijo + "." + ext)
		if FileAccess.file_exists(candidate):
			return candidate
	return ""


func _parse(text: String, path: String) -> Song:
	var new_song := Song.new()
	new_song.difficulties = {}

	# Trocea el chart en secciones -> {nombre: [líneas]}
	var sec := {}
	var cur := ""
	for r in text.split("\n"):
		var linea := r.strip_edges()
		if linea.begins_with("[") and linea.ends_with("]"):
			cur = linea.substr(1, linea.length() - 2)
			sec[cur] = []
		elif cur != "" and linea != "" and linea != "{" and linea != "}":
			sec[cur].append(linea)

	# --- [Song] ---
	var res := 192
	if sec.has("Song"):
		for linea in sec["Song"]:
			var kv := _kv(linea)
			if kv.is_empty():
				continue
			match kv[0]:
				"Name": new_song.name = kv[1].trim_prefix('"').trim_suffix('"')
				"Resolution": res = kv[1].to_int()
		new_song.song_path = _find_audio(path, "song")
		new_song.guitar_path = _find_audio(path, "guitar")

	# --- [SyncTrack] ---
	var tempo := []
	if sec.has("SyncTrack"):
		for linea in sec["SyncTrack"]:
			var kv := _kv(linea)
			if not kv.is_empty() and kv[1].begins_with("B "):
				tempo.append({ "tick": kv[0].to_int(), "bpm": kv[1].substr(2).to_int() / 1000.0 })
		tempo.sort_custom(func(a, b): return a.tick < b.tick)
		if tempo.size() > 0:
			new_song.bpm = tempo[0].bpm

	var beat_2_sec := func(t: int) -> float:
		if tempo.is_empty(): return 0.0
		var time := 0.0
		var lt := 0
		var bpm: float = tempo[0].bpm
		for i in range(tempo.size()):
			var e = tempo[i]
			if e.tick >= t: break
			if i > 0:
				time += ((e.tick - lt) / float(res)) * (60.0 / bpm)
			lt = e.tick
			bpm = e.bpm
		time += ((t - lt) / float(res)) * (60.0 / bpm)
		return time

	# --- Dificultades ---
	for dificultad in ["Easy", "Medium", "Hard", "Expert"]:
		var nombre_sec = dificultad + "Single"
		if not sec.has(nombre_sec):
			continue
		var by_tick := {}
		var lengths := {}
		for linea in sec[nombre_sec]:
			var kv := _kv(linea)
			if kv.is_empty() or not kv[1].begins_with("N "):
				continue
			var tk = kv[0].to_int()
			var partes = kv[1].split(" ")
			var f = partes[1].to_int()
			var length = partes[2].to_int() if partes.size() > 2 else 0
			if f >= 0 and f <= 4:
				if not by_tick.has(tk): by_tick[tk] = []
				by_tick[tk].append(f)
				lengths[tk] = max(lengths.get(tk, 0), length)

		var arr: Array[NoteData] = []
		var keys := by_tick.keys()
		keys.sort()
		for tk in keys:
			var c: Array[bool] = [false, false, false, false, false]
			for f in by_tick[tk]:
				c[f] = true
			var n := NoteData.new()
			n.time = beat_2_sec.call(tk)
			n.chord = c
			var len_ticks: int = lengths[tk]
			if len_ticks > 0:
				n.type = NoteData.Type.HOLD
				n.duration = beat_2_sec.call(tk + len_ticks) - beat_2_sec.call(tk)
			arr.append(n)
		new_song.difficulties[dificultad] = arr

	return new_song
