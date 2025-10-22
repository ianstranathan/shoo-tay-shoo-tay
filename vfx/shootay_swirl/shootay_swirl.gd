extends Node2D

@export  var mechanics_color_data: Resource #preload("res://components/colors_reflect_transmit.tres")

func _ready():
	assert(mechanics_color_data)
	$MeshInstance2D.material.set_shader_parameter("reflect_col", mechanics_color_data.reflect_col)
	$MeshInstance2D.material.set_shader_parameter("transmit_col", mechanics_color_data.transmit_col)
