extends Control
class_name Disco

@export var bpm : float = 120 # pulsos por minuto
@export var b_x_vuelta : float = 4 # pulsos por vuelta

var vel:float = 0
var pause := false
func _ready() -> void:
	vel =  360/ (b_x_vuelta / (bpm/60))
	print(vel)

func stop() -> void:
	pause = true

func fail() -> void:
	pause = true
	var rot = rad_to_deg(rotation)
	var tween = get_tree().create_tween()
	if rot < 45:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", deg_to_rad(0), 0.25).set_trans(Tween.TRANS_ELASTIC)
		#rotation = deg_to_rad(0)
	elif rot < 135:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", deg_to_rad(90), 0.25).set_trans(Tween.TRANS_ELASTIC)
		#rotation = deg_to_rad(90)
	elif rot < 225:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", deg_to_rad(180), 0.25).set_trans(Tween.TRANS_ELASTIC)
		#rotation = deg_to_rad(180)
	elif rot < 315:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", deg_to_rad(270), 0.25).set_trans(Tween.TRANS_ELASTIC)
		#rotation = deg_to_rad(270)
	else:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", deg_to_rad(0), 0.25).set_trans(Tween.TRANS_ELASTIC)
		#rotation = deg_to_rad(0)

func correct() -> void:
	pause = false
	

func start() -> void:
	pause = false

func _physics_process(delta: float) -> void:
	if pause: return
	
	rotation += deg_to_rad(delta * vel)
	#print(rotation)
