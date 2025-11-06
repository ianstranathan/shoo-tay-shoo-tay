extends Area2D

class_name ShootayArea

signal shootay_collided_with_shoootay( a_shootay: Shootay )

@export var attack: AttackComponent

func _ready() -> void:
	# --
	area_entered.connect( func(area):
		if area is ShootayArea:
			emit_signal("shootay_collided_with_shoootay", area.get_parent())
		elif area is HitboxComponent:
			area.take_hit( attack)
			queue_free())
