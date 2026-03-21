extends Button

func _on_pressed() -> void:
	if text == "":
		return
	var Dif_Son := text.split("|")
	Global.startSong.emit(Dif_Son[0], Dif_Son[1])
	pass # Replace with function body.
