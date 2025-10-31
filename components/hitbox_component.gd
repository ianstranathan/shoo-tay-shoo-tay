extends Area2D

class_name HitboxComponent

signal was_hit( attack: AttackComponent)

func take_hit( attack :AttackComponent):
	emit_signal("was_hit", attack)
