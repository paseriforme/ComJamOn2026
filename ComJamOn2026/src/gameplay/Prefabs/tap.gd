extends Control
class_name Tap

static var active_color 	:= Color(1.0, 1.0, 1.0, 1.0)
static var idle_color 		:= Color(0.1,0.1,0.1,0.75)

const TAP = preload("uid://dlsillfjnepba")

static func create_tap(parent:Node, off_position: Vector2, off_rotation: float, off_scale: Vector2, config: Array) -> Tap :
	var tap = TAP.instantiate()
	parent.add_child(tap)
	tap.position = off_position
	tap.scale = off_scale
	tap.rotation = off_rotation
	
	#print(config)
	for i in len(config):
		tap.get_child(i).modulate = Tap.active_color if config[i] else Tap.idle_color
		#tap.get_child(i).visible = config[i]
	
	return tap
