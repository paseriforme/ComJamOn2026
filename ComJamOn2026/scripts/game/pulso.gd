extends Control
class_name Pulso


func set_pulso(pulso):
	print(pulso)
	for i in len(pulso):
		get_child(i).visible = pulso[i]
