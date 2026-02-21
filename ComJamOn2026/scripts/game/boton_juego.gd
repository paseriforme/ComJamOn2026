extends TextureRect
class_name boton_juego

func turn_on(e : bool = false):
	if e:
		modulate = Color(0.998, 0.998, 0.0, 1.0)
	else:
		modulate = Color(0.0, 0.0, 0.0, 0.694)
