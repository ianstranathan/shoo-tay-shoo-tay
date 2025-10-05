extends Node2D

class_name Shootay

var shootay_value: ShootayGlobals.ShootayValues

var vel: Vector2 = Vector2.ZERO
var dist: float = 0.0
@export var MAX_DISTANCE: float = 10000
@export var SHOOTING_SPEED: float = 600.0
@onready var ray = $RayCast2D


#func _ready() -> void:
	#$Area2D.area_entered.connect( on_area_entered )


func _physics_process(delta: float) -> void:
	var delta_pos = vel * delta
	dist += delta_pos.length()
	global_position += delta_pos
	if dist > MAX_DISTANCE:
		queue_free()

	if ray.is_colliding():
		vel = vel.bounce(ray.get_collision_normal())
		rotation_from_velocity_vector( vel )
		

#func on_area_entered( area: Area2D ):
	#if area.get_parent() is Shootay and area.get_parent().shootay_value != shootay_value:
		#explode()


func shoot(dir: Vector2, _shootay_val: ShootayGlobals.ShootayValues):
	shootay_value = _shootay_val
	$ShootayColorComponent.set_shootay_visual( shootay_value )
	set_shootay_collision_layer()
	vel = dir.normalized() * SHOOTING_SPEED
	rotation_from_velocity_vector( dir )


func rotation_from_velocity_vector(dir: Vector2):
	var angle = Vector2.RIGHT.angle_to( dir )
	global_rotation = angle


func set_shootay_collision_layer():
	var _layer_to_turn_on: ShootayGlobals.ShootayValues
	var _layer_to_turn_off: ShootayGlobals.ShootayValues
	
	if shootay_value == ShootayGlobals.ShootayValues.REFLECT:
		_layer_to_turn_on = ShootayGlobals.reflection_layer
		_layer_to_turn_off = ShootayGlobals.transmission_layer
	else:
		_layer_to_turn_on = ShootayGlobals.transmission_layer
		_layer_to_turn_off = ShootayGlobals.reflection_layer
		
	$Area2D.set_collision_layer_value(_layer_to_turn_on, true)
	$Area2D.set_collision_layer_value(_layer_to_turn_off, false)
	ray.set_collision_mask_value(_layer_to_turn_on, true)
	ray.set_collision_mask_value(_layer_to_turn_off, false)
	
#func resolve_raycast_collision(_collider: CollisionObject2D):
	# var _layer = _collider.collision_layer
	# -- if the shootay is a reflection shootay && the
	# -- coll object is a reflection object (color  and collision match the
	# -- shootay's, reflect, otherwise, transmit
	#if (shootay_value == ShootayGlobals.ShootayValues.REFLECT and
		#_layer == ShootayGlobals.reflection_layer):


func explode():
	pass
