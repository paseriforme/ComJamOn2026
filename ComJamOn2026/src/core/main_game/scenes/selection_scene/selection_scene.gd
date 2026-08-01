extends Scene

func _on_aventura_pressed() -> void:
	$"../..".change_scene("context_scene")

func _on_libre_pressed() -> void:
	$"../..".change_scene("JuegoLibre")
