extends RigidBody2D
class_name NPC


func _on_body_entered(body: Node) -> void:
	var newpos = ((position - body.position) * body.speed)
	body.apply_impulse(newpos)
	print("CHOQUE", newpos)
