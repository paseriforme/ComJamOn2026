extends Control
class_name Disco

@export var bpm : float = 120 # pulsos por minuto
@export var b_x_vuelta : float = 4 # pulsos por vuelta
@export var desfase: float = 0
@export var hit_zone_angle: float = 90

var vel:float = 0
var pause := false
func _ready() -> void:
	vel =  360/ (b_x_vuelta / (bpm/60))
	print(vel)

func end() -> void:
	#pause = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(rotation + desfase), 1.5).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func(): Global.end_song.emit())
 
func start() -> void:
	rotation = deg_to_rad(0)
	pause = true

func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(delta * vel)
	#print(rotation)
