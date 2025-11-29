extends Area2D

class_name HitboxComponent


signal was_hit( attack: AttackComponent)


func take_hit( attack :AttackComponent):
	emit_signal("was_hit", attack)


func make_invulnerable(b):
	$CollisionPolygon2D.set_deferred("disabled", b)
