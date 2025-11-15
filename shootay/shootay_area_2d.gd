extends Area2D
class_name ShootayArea

signal collided_with_shoootay( a_shootay: Shootay )
signal collided_with_hitbox
signal collided_with_not_hitbox
signal collided_with_body

@export var attack: AttackComponent

var has_left_player: bool # -- this is kinda hacky

func _ready() -> void:
	area_exited.connect( func(area):
		if area is HitboxComponent and area.get_parent() is Player:
			has_left_player = true)
	area_entered.connect( on_area_entered )
	body_entered.connect( on_body_entered )


func on_area_entered(area: Area2D):
	if area is ShootayArea:
		emit_signal("collided_with_shoootay", area.get_parent())
	elif area is HitboxComponent and has_left_player:
		area.take_hit( attack)
		emit_signal("collided_with_hitbox")
	else:
		emit_signal("collided_with_not_hitbox")


func on_body_entered( body ):
	if body is not Player:
		emit_signal("collided_with_body")
