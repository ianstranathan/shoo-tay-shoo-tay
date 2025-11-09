extends Area2D

signal player_lost_found(lost_found)

func _on_body_entered(body):
	if body is Player:
		emit_signal("player_lost_found", "Found")


func _on_body_exited(body):
	if body is Player:
		emit_signal("player_lost_found", "Lost")
