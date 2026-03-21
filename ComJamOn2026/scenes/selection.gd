extends Scene

func _on_aventura_pressed() -> void:
	Global.change_scene(Global.Scenes.CONTEXT)


func _on_libre_pressed() -> void:
	Global.change_scene(Global.Scenes.LIBRE)
