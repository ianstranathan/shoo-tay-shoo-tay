extends Node

class_name ShootayColorComponent

@export  var mechanics_color_data: Resource #preload("res://components/colors_reflect_transmit.tres")
@onready var reflect_col: Color = mechanics_color_data.reflect_col
@onready var transmit_col: Color = mechanics_color_data.transmit_col

@export var sprite: Sprite2D
@export var mesh: MeshInstance2D


"""
Simple component to automate coloring scheme
Mesh vs Sprite is just accounting for arbitrarily making one or the other / forgetting
"""

func _ready() -> void:
	assert(mechanics_color_data and (sprite or mesh))


# -- so, this => all shaders that are shootay applicable (material is on something
#                that can interact with a shootay) must have src_col as a uniform
func set_shootay_visual(shootay_value: ShootayGlobals.ShootayValues):
	(sprite if sprite else mesh).material.set_shader_parameter(
		"src_col",
		reflect_col if shootay_value == ShootayGlobals.ShootayValues.REFLECT else transmit_col
	)
