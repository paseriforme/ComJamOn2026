extends TextureRect

@export var traste_spr : Texture2D
@export var traste_pulsado_spr : Texture2D
@export var traste : int = 0;

func _process(delta: float) -> void:
	var color = Color(1,1,1,1)
	if Global.trastes[traste]:
		self.texture = traste_pulsado_spr
		#ANDRES AQUI
		#color.i = 3
		self.modulate = color
		pass
	else:
		self.texture = traste_spr
		#color.i = 0
		self.modulate = color
		pass
	pass
