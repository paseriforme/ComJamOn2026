extends Control

@export var bpm : float = 120 # pulsos por minuto
@export var b_x_vuelta : float = 4 # pulsos por vuelta

var vel:float = 0

func _ready() -> void:
	vel =  360/ (b_x_vuelta / (bpm/60))
	print(vel)

func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(delta * vel)
	#print(rotation)
