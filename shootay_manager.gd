extends Node2D

signal shootay_collided( pos, normal )
signal transmission_collided( pos )

var shootay_scene: PackedScene = preload("res://shootay/shootay.tscn")

var shootay_count: int = 0
var player_ref: Player
var cam_ref: Camera2D


@export var transmit_wrapping_buffer := 10.0


var last_transmission_shootay_fired: Shootay
func is_last_transmission_shootay_fired(shootay_1: Shootay, shootay_2: Shootay) -> bool:
	return shootay_1 == last_transmission_shootay_fired or shootay_2 == last_transmission_shootay_fired


func make_shootay(pos: Vector2, vel: Vector2, shootay_value:ShootayGlobals.ShootayValues):
	var shootay = shootay_scene.instantiate()
	# -- what things does it need to know about before starting tick?
	# -- it has to at least clear the shooting origin / player
	# -- it has to know about what the manager knows (its explosion id, wrapping bounds)
	shootay_count += 1
	shootay._id = shootay_count
	shootay.cam_ref = cam_ref
	shootay.player_ref = player_ref
	shootay.wrapping_buffer = transmit_wrapping_buffer
	# -- magic number is just to nudge it past where it needs to go
	var coll_shape_offset = 0.7 * shootay.get_node("Area2D/CollisionShape2D").shape.height / 2.0
	shootay.global_position = pos + vel.normalized() * coll_shape_offset
	
	# -- relay signal up
	shootay.shootay_collided.connect( func(p, normal): 
		emit_signal("shootay_collided", p, normal))
	shootay.transmission_collided.connect( func( A: Shootay, B: Shootay):
		if is_last_transmission_shootay_fired ( A, B ):
			var midpoint = (A.global_position + B.global_position) / 2.0 
			emit_signal("transmission_collided", midpoint))
	shootay.transmission_shot_wrapped.connect( func(a_shootay: Shootay):
		if a_shootay == last_transmission_shootay_fired:
			last_transmission_shootay_fired = null)
	add_child(shootay)
	
	shootay.shoot( vel, shootay_value)
	
	if shootay_value == ShootayGlobals.ShootayValues.TRANSMIT:
		last_transmission_shootay_fired = shootay
