extends TextureRect

@export var traste_spr : Texture2D
@export var traste_pulsado_spr : Texture2D
@export var traste : int = 0;

func _process(delta: float) -> void:
	if Global.trastes[traste] == 1:
		self.texture = traste_pulsado_spr
		pass
	else:
		self.texture = traste_spr
		pass
	pass