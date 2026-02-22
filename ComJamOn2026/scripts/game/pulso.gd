extends Control
class_name Pulso


func set_pulso(pulso):
	#print(pulso)
	for i in len(pulso):
		if pulso[i]:
			get_child(i).modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			get_child(i).modulate = Color(0.1,0.1,0.1,0.75)
		#get_child(i).visible = pulso[i]
