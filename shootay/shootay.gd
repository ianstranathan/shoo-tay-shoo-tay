extends Node2D


var vel: Vector2 = Vector2.ZERO
var accl: Vector2 = Vector2.ZERO

@onready var ray = $RayCast2D

func _ready() -> void:
	$Area2D.body_entered.connect( transmit_or_reflect )

func transmit_or_reflect( body ) -> void:
	if body.is_in_group( "reflect" ):
		vel = vel.bounce(ray.get_collision_normal())
