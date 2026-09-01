extends Node
class_name TapsManager

@export var disco_parent	: Control

@export_subgroup("Visual de pulsos")
@export var off_scale		: Vector2 = Vector2(0.66, 0.66)
@export var off_position	: Vector2 = Vector2(0, 0)

var end_rotation	: float = 90.0
var start_rotation	: float = -180.0

# --- Helpers de pulsos --------------------------------------------------------
func spawn_pulse(nota: Note, song_time: float, pulse_time: float) -> void:
	var latency: float = AudioServer.get_output_latency() # sumamos latencia de audio por dispositivo
	var lead: float = nota.time - song_time + latency
	var progress: float = clamp(1.0 - lead / pulse_time, 0.0, 1.0)
	
	var start_rot = deg_to_rad(lerp(start_rotation, end_rotation, progress))	
	var tap: Tap = Tap.create_tap(disco_parent, off_position, start_rot, off_scale, nota.chord)
	
	var tween = tap.create_tween()
	tween.tween_property(tap, "rotation", deg_to_rad(end_rotation), max(lead, 0.01))
	tween.finished.connect(func(): tap.queue_free())
