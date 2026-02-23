extends Control
class_name Pulso

var pulso_data:Array

func set_pulso(pulso):
	pulso_data = pulso
	#print(pulso)
	for i in len(pulso):
		if pulso[i]:
			get_child(i).modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			get_child(i).modulate = Color(0.1,0.1,0.1,0.75)
		#get_child(i).visible = pulso[i]

func _get_pulse_data() -> Array:
	return pulso_data

func _is_pulse_empty() -> bool:
	if pulso_data == null or len(pulso_data) == 0:
		# Si no hay datos consideramos vacío (o inexistente)
		return true
	for p in pulso_data:
		if p:
			return false
	return true

func _matching_keys_with_pulse() -> bool:
	if pulso_data == null or len(pulso_data) == 0:
		return false
	# comparar hasta el mínimo de ambas longitudes
	for i in range(min(len(Global.trastes), len(pulso_data))):
		if Global.trastes[i] != pulso_data[i]:
			return false
	return true
