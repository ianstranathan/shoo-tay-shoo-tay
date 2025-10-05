extends Node

class_name ShootayCollisionComponent


@export var affected_physics_body: PhysicsBody2D

func _ready() -> void:
	assert(affected_physics_body)


func set_shootay_collision_mask(shootay_value: ShootayGlobals.ShootayValues):
	if shootay_value == ShootayGlobals.ShootayValues.REFLECT:
		affected_physics_body.set_collision_layer_value(ShootayGlobals.reflection_layer, true)
		affected_physics_body.set_collision_layer_value(ShootayGlobals.transmission_layer, false)
	elif shootay_value == ShootayGlobals.ShootayValues.TRANSMIT:
		affected_physics_body.set_collision_layer_value(ShootayGlobals.transmission_layer, true)
		affected_physics_body.set_collision_layer_value(ShootayGlobals.reflection_layer, false)
