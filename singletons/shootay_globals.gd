extends Node

var wrapping_buffer = 20.0 # NOTE

var reflection_layer: int = 3
var transmission_layer: int = 4

var reflect_col: Color = Color(1.0, 0.5, 0.25, 1.0)
var transmit_col: Color = Color(0.4, 0.7, 1.0, 1.0)

enum ShootayValues{
	REFLECT,
	TRANSMIT
}

@onready var valid_shootay_vals = ShootayValues.values()


func get_col( shootay_type: ShootayValues) -> Color:
	if shootay_type == ShootayValues.REFLECT:
		return reflect_col
	return transmit_col
