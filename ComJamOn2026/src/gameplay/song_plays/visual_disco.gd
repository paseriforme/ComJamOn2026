extends Control
class_name Disco

@export var bpm : float = 120 # pulsos por minuto
@export var b_x_vuelta : float = 4 # pulsos por vuelta

var vel:float = 0
var pause := false

func _ready() -> void:
	vel = 0.1
	print(vel)

func set_vel(_vel:float) -> void:
	vel = _vel
	print(vel)

func end(score: int) -> void:
	#pause = true
	SoundSystem.play_sfx("scratch", 0.4)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(rotation), 1.5).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func(): Global.play_telon.emit(score))

func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(delta * vel)
