extends Control
class_name Disco

@export var bpm : float = 120 # pulsos por minuto
@export var b_x_vuelta : float = 4 # pulsos por vuelta
@export var desfase: float = -30

var vel:float = 0
var pause := false
func _ready() -> void:
	vel =  360/ (b_x_vuelta / (bpm/60))
	print(vel)
	

func end() -> void:
	pause = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(rotation + desfase), 2).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func(): Global.end_song.emit())

func fail() -> void:
	pause = true
	#var rot = rad_to_deg(rotation)
	#var tween = get_tree().create_tween()
	#if rot < 45 + desfase:
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "rotation", deg_to_rad(0 + desfase), 0.25).set_trans(Tween.TRANS_BOUNCE)
		##rotation = deg_to_rad(0)
	#elif rot < 135 + desfase:
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "rotation", deg_to_rad(90 + desfase), 0.25).set_trans(Tween.TRANS_BOUNCE)
		##rotation = deg_to_rad(90)
	#elif rot < 225 + desfase:
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "rotation", deg_to_rad(180 + desfase), 0.25).set_trans(Tween.TRANS_BOUNCE)
		##rotation = deg_to_rad(180)
	#elif rot < 315 + desfase:
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "rotation", deg_to_rad(270 + desfase), 0.25).set_trans(Tween.TRANS_BOUNCE)
		##rotation = deg_to_rad(270)
	#else:
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "rotation", deg_to_rad(0 + desfase), 0.25).set_trans(Tween.TRANS_BOUNCE)
		##rotation = deg_to_rad(0)

func correct() -> void:
	pause = false

func start() -> void:
	pause = false

func _physics_process(delta: float) -> void:
	if pause: return
	
	rotation += deg_to_rad(delta * vel)
	#print(rotation)
