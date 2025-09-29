extends Node

class_name ShootayComponent

enum ShootayValues{
	REFLECT,
	TRANSMIT
}

var shootay_val

@export var reflect_col: Color = Color(1.0, 0.5, 0.25, 1.0)
@export var transmit_col: Color = Color(0.5, 1.0, 0.25, 1.0)
@export var sprite: Sprite2D

func _ready() -> void:
	assert(sprite)
