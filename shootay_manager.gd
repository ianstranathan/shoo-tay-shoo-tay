extends Node2D

var shootay_scene: PackedScene = preload("res://shootay/shootay.tscn")

var shootay_count: int = 0
var wrapping_bounds: Vector2


func make_shootay(pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues):
	var shootay = shootay_scene.instantiate()
	shootay.wrapping_bounds = wrapping_bounds
	add_child(shootay)
	shootay_count += 1
	shootay.explosion_id = shootay_count
	shootay.global_position = pos
	shootay.shoot( dir, shootay_value)
