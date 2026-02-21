extends Control
class_name pulso

func set_pulso(pulso):
	for i in len(pulso):
		get_child(i).turn_on(pulso[i])
