extends Area2D
class_name ShootayArea

signal shootay_collided_with_shoootay( a_shootay: Shootay )

@export var attack: AttackComponent

var has_left_player: bool # -- this is kinda hacky

func _ready() -> void:
	area_exited.connect( func(area):
		if area is HitboxComponent and area.get_parent() is Player:
			has_left_player = true)
	area_entered.connect( func(area):
		if area is ShootayArea:
			emit_signal("shootay_collided_with_shoootay", area.get_parent())
		elif area is HitboxComponent and has_left_player:
			area.take_hit( attack)
			queue_free())
