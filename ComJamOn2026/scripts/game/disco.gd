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

func fail(pulso_rotation: float) -> void:
	pause = true
	
	var target_rotation = deg_to_rad(hit_zone_angle) - pulso_rotation
	
	# Normalizar a -2π a 2π para evitar giros innecesarios
	while target_rotation - rotation > PI:
		target_rotation -= TAU
	while target_rotation - rotation < -PI:
		target_rotation += TAU
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", target_rotation, 0.25).set_trans(Tween.TRANS_BOUNCE)
	
	tween.finished.connect(func(): _on_fail_tween_finished())

func _on_fail_tween_finished() -> void:
	var parent = get_parent()
	if parent.has_method("_recalcular_pulso_actual"):
		parent._recalcular_pulso_actual()

func correct() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "rotation", deg_to_rad(rad_to_deg(rotation) + 45), (60/bpm)*0.5)


func start() -> void:
	rotation = deg_to_rad(0)
	pause = true

func _physics_process(delta: float) -> void:
	if pause: return
	
	#rotation += deg_to_rad(delta * vel)
	#print(rotation)
