extends Control
class_name pulso

func set_pulso(pulso):
	for i in len(pulso):
		get_child(i).visible = pulso[i]
