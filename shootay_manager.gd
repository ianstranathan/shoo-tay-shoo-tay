extends Node2D

signal shootay_collided( pos, normal )
var shootay_scene: PackedScene = preload("res://shootay/shootay.tscn")

var shootay_count: int = 0
var wrapping_bounds: Vector2


func make_shootay(pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues):
	var shootay = shootay_scene.instantiate()
	
	# -- what things does it need to know about before starting tick?
	# -- it has to at least clear the shooting origin / player
	# -- it has to know about what the manager knows (its explosion id, wrapping bounds)
	shootay.wrapping_bounds = wrapping_bounds
	shootay_count += 1
	shootay.explosion_id = shootay_count
	
	# -- magic number is just to nudge it past where it needs to go
	var coll_shape_offset = 0.7 * shootay.get_node("Area2D/CollisionShape2D").shape.height / 2.0
	shootay.global_position = pos + dir.normalized() * coll_shape_offset
	
	# -- relay signal up
	shootay.shootay_collided.connect( func(pos, normal): 
		emit_signal("shootay_collided", pos, normal))
		
	add_child(shootay)
	
	shootay.shoot( dir, shootay_value)
