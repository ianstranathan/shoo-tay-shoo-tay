extends Node2D

signal shootay_collided( pos, normal )
signal transmission_collided( pos )

var shootay_scene: PackedScene = preload("res://shootay/shootay.tscn")

var shootay_count: int = 0
var player_ref: Player
var cam_ref: Camera2D

# -- TODO
# -- change the explosion id to be just an id, it's doing double duty with
# -- the transmission mechanic now

@export var transmit_wrapping_buffer := 10.0

func make_shootay(pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues):
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
	shootay.global_position = pos + dir.normalized() * coll_shape_offset
	
	# -- relay signal up
	shootay.shootay_collided.connect( func(pos, normal): 
		emit_signal("shootay_collided", pos, normal))
	shootay.transmission_collided.connect( func( midpoint: Vector2):
		emit_signal("transmission_collided", midpoint)
	)
	
	add_child(shootay)
	
	shootay.shoot( dir, shootay_value)
