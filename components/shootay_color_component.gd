extends Node

class_name ShootayColorComponent

@export var sprite: Sprite2D
@export var reflect_col: Color = Color(1.0, 0.5, 0.25, 1.0)
@export var transmit_col: Color = Color(0.4, 0.7, 1.0, 1.0)

func _ready() -> void:
	assert(sprite)


# -- so, this => all shaders that are shootay applicable (material is on something
#                that can interact with a shootay) must have src_col as a uniform
func set_shootay_visual(shootay_value: ShootayGlobals.ShootayValues):
	sprite.material.set_shader_parameter(
		"src_col",
		reflect_col if shootay_value == ShootayGlobals.ShootayValues.REFLECT else transmit_col
	)
