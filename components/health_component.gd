extends Node

class_name HealthComponent

signal health_depeleted
signal health_changed( ratio )

@export var MAX_HEALTH: float = 100.0
@onready var current_health: float = MAX_HEALTH

func take_damage(dmg: float):
	current_health -= dmg
	if current_health <= 0.0:
		current_health = 0.0
		emit_signal("health_depeleted")
	else:
		emit_signal("health_changed", current_health / MAX_HEALTH)
