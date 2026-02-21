extends Control
class_name pulso

func set_pulso(pulso):
	for i in len(pulso):
		get_child(i).turn_on(pulso[i])

func enter():
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", -45, 0.25)
